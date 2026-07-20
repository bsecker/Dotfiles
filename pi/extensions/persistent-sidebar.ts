import type { ExtensionAPI, ExtensionContext, Theme } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth, type TUI } from "@earendil-works/pi-tui";
import { mkdir, readFile, rename, writeFile } from "node:fs/promises";
import { homedir } from "node:os";
import { dirname, join } from "node:path";

type LimitWindow = {
	label: string;
	usedPercent: number;
	resetAt: number;
};

type SidebarState = {
	cwd: string;
	model?: string;
	contextTokens: number | null;
	contextWindow?: number;
	contextPercent: number | null;
	plan?: string;
	user?: string;
	limits: LimitWindow[];
	usageError?: string;
	fetchedAt?: number;
};

type UsageResponse = {
	email?: string;
	plan_type?: string;
	rate_limit?: {
		primary_window?: ApiWindow | null;
		secondary_window?: ApiWindow | null;
	};
};

type ApiWindow = {
	used_percent?: number;
	limit_window_seconds?: number;
	reset_at?: number;
};

const CACHE_FILE = join(homedir(), ".pi", "agent", "cache", "pi-usage", "cache.json");
const REFRESH_MS = 60_000;

function formatTokens(tokens: number | null): string {
	if (tokens === null) return "calculating…";
	return tokens >= 1_000_000 ? `${(tokens / 1_000_000).toFixed(1)}m` : tokens >= 1_000 ? `${(tokens / 1_000).toFixed(1)}k` : String(tokens);
}

function formatDuration(seconds: number): string {
	if (seconds <= 0) return "now";
	const days = Math.floor(seconds / 86_400);
	const hours = Math.floor((seconds % 86_400) / 3_600);
	return days > 0 ? `${days}d ${hours}h` : hours > 0 ? `${hours}h` : `${Math.ceil((seconds % 3_600) / 60)}m`;
}

function decodeJwtPayload(token: string): Record<string, unknown> | undefined {
	try {
		const payload = token.split(".")[1];
		if (!payload) return undefined;
		return JSON.parse(Buffer.from(payload, "base64url").toString("utf8"));
	} catch {
		return undefined;
	}
}

function getAccountId(token: string): string | undefined {
	const claims = decodeJwtPayload(token);
	const auth = claims?.["https://api.openai.com/auth"] as Record<string, unknown> | undefined;
	return typeof auth?.chatgpt_account_id === "string" ? auth.chatgpt_account_id : undefined;
}

function windowsFromResponse(response: UsageResponse): LimitWindow[] {
	const rateLimit = response.rate_limit;
	if (!rateLimit) return [];
	return [rateLimit.primary_window, rateLimit.secondary_window]
		.filter((window): window is ApiWindow => Boolean(window))
		.map((window) => ({
			label: `${Math.round((window.limit_window_seconds ?? 0) / 3_600)}h`,
			usedPercent: Math.round(window.used_percent ?? 0),
			resetAt: (window.reset_at ?? 0) * 1_000,
		}));
}

async function readCachedUsage(): Promise<Partial<SidebarState> | undefined> {
	try {
		const cache = JSON.parse(await readFile(CACHE_FILE, "utf8")) as { codex?: { fetchedAt?: number; usage?: { displayName?: string; windows?: Array<{ label?: string; usedPercent?: number; resetAt?: string }> } } };
		const codex = cache.codex;
		if (!codex?.usage) return undefined;
		return {
			plan: codex.usage.displayName,
			fetchedAt: codex.fetchedAt,
			limits: (codex.usage.windows ?? []).map((window) => ({
				label: window.label ?? "limit",
				usedPercent: window.usedPercent ?? 0,
				resetAt: window.resetAt ? Date.parse(window.resetAt) : 0,
			})),
		};
	} catch {
		return undefined;
	}
}

async function writeCachedUsage(state: SidebarState): Promise<void> {
	const payload = {
		codex: {
			fetchedAt: state.fetchedAt,
			usage: {
				provider: "codex",
				displayName: state.plan ?? "Codex",
				windows: state.limits.map((limit) => ({
					label: limit.label,
					usedPercent: limit.usedPercent,
					resetAt: new Date(limit.resetAt).toISOString(),
				})),
			},
		},
	};
	try {
		await mkdir(dirname(CACHE_FILE), { recursive: true });
		const temp = `${CACHE_FILE}.${process.pid}.tmp`;
		await writeFile(temp, JSON.stringify(payload, null, 2));
		await rename(temp, CACHE_FILE);
	} catch {
		// A sidebar must never affect an agent session if its optional cache cannot be written.
	}
}

class Sidebar {
	constructor(
		private readonly state: SidebarState,
		private readonly theme: Theme,
		private readonly tui: TUI,
	) {}

	render(width: number): string[] {
		const inner = Math.max(1, width - 2);
		const border = (text: string) => this.theme.fg("borderMuted", text);
		const pad = (text: string) => {
			const clipped = truncateToWidth(text, inner);
			return clipped + " ".repeat(Math.max(0, inner - visibleWidth(clipped)));
		};
		const row = (text = "") => border("│") + pad(text) + border("│");
		const title = (text: string) => this.theme.fg("accent", this.theme.bold(text));
		const dim = (text: string) => this.theme.fg("dim", text);
		const lines = [border(`╭${"─".repeat(inner)}╮`), row(` ${title("pi sidebar")}`)];

		lines.push(row(), row(` ${title("Directory")}`), row(` ${dim(truncateToWidth(this.state.cwd, Math.max(1, inner - 1)))}`));
		lines.push(row(), row(` ${title("Context")}`));
		const context = this.state.contextWindow
			? `${formatTokens(this.state.contextTokens)} / ${formatTokens(this.state.contextWindow)}${this.state.contextPercent === null ? "" : ` (${this.state.contextPercent.toFixed(1)}%)`}`
			: "unavailable";
		lines.push(row(` ${context}`));
		if (this.state.model) lines.push(row(` ${dim(truncateToWidth(this.state.model, Math.max(1, inner - 1)))}`));

		lines.push(row(), row(` ${title("Codex limits")}`));
		if (this.state.plan) lines.push(row(` ${dim(truncateToWidth(this.state.plan, Math.max(1, inner - 1)))}`));
		if (this.state.user) lines.push(row(` ${dim(truncateToWidth(this.state.user, Math.max(1, inner - 1)))}`));
		if (this.state.limits.length > 0) {
			for (const limit of this.state.limits) {
				const reset = limit.resetAt ? ` · ${formatDuration(Math.ceil((limit.resetAt - Date.now()) / 1_000))}` : "";
				const color = limit.usedPercent >= 90 ? "error" : limit.usedPercent >= 70 ? "warning" : "success";
				lines.push(row(` ${limit.label}  ${this.theme.fg(color, `${limit.usedPercent}%`)}${dim(reset)}`));
			}
		} else {
			lines.push(row(` ${dim(this.state.usageError ?? "Not signed in to Codex")}`));
		}
		const updated = this.state.fetchedAt
			? `${formatDuration(Math.ceil((Date.now() - this.state.fetchedAt) / 1_000))} ago`
			: "loading…";
		// Fill the viewport so the overlay's border reaches the terminal bottom.
		const targetHeight = Math.max(lines.length + 2, this.tui.terminal.rows);
		while (lines.length < targetHeight - 2) lines.push(row());
		lines.push(row(" " + dim(`updated ${updated}`)), border(`╰${"─".repeat(inner)}╯`));
		return lines.map((line) => truncateToWidth(line, width, ""));
	}

	invalidate(): void {}
}

export default function (pi: ExtensionAPI) {
	let refreshTimer: ReturnType<typeof setInterval> | undefined;
	let requestRender: (() => void) | undefined;
	let state: SidebarState | undefined;

	const updateContext = (ctx: ExtensionContext) => {
		if (!state) return;
		const usage = ctx.getContextUsage();
		state.cwd = ctx.cwd;
		state.model = ctx.model ? `${ctx.model.provider}/${ctx.model.id}` : undefined;
		state.contextTokens = usage?.tokens ?? null;
		state.contextWindow = usage?.contextWindow ?? ctx.model?.contextWindow;
		state.contextPercent = usage?.percent ?? null;
		requestRender?.();
	};

	const refreshUsage = async (ctx: ExtensionContext) => {
		if (!state) return;
		try {
			const token = await ctx.modelRegistry.getApiKeyForProvider("openai-codex");
			const accountId = token && getAccountId(token);
			if (!token || !accountId) throw new Error("Not signed in to Codex");
			const response = await fetch("https://chatgpt.com/backend-api/wham/usage", {
				headers: { Authorization: `Bearer ${token}`, "ChatGPT-Account-Id": accountId },
			});
			if (!response.ok) throw new Error(`Usage request failed (${response.status})`);
			const usage = (await response.json()) as UsageResponse;
			state.user = usage.email;
			state.plan = usage.plan_type ? `Codex ${usage.plan_type}` : "Codex";
			state.limits = windowsFromResponse(usage);
			state.usageError = state.limits.length ? undefined : "No periodic limits reported";
			state.fetchedAt = Date.now();
			await writeCachedUsage(state);
		} catch (error) {
			state.usageError = error instanceof Error ? error.message : "Could not load Codex limits";
		}
		requestRender?.();
	};

	pi.on("session_start", async (_event, ctx) => {
		if (ctx.mode !== "tui") return;
		state = {
			cwd: ctx.cwd,
			contextTokens: null,
			contextPercent: null,
			limits: [],
			...(await readCachedUsage()),
		};
		updateContext(ctx);
		void ctx.ui
			.custom<void>(
			(tui, theme, _keybindings, _done) => {
				requestRender = () => tui.requestRender();
				return new Sidebar(state!, theme, tui);
			},
			{
				overlay: true,
				overlayOptions: { anchor: "top-right", width: 34, margin: 0, nonCapturing: true, visible: (w) => w >= 100 },
			}, 
			)
			.catch(() => undefined);
		void refreshUsage(ctx);
		refreshTimer = setInterval(() => void refreshUsage(ctx), REFRESH_MS);
	});

	for (const event of ["turn_start", "turn_end", "message_end", "model_select", "session_compact"] as const) {
		pi.on(event, (_event, ctx) => updateContext(ctx));
	}

	pi.registerCommand("sidebar-refresh", {
		description: "Refresh the persistent sidebar's Codex limits",
		handler: async (_args, ctx) => {
			updateContext(ctx);
			await refreshUsage(ctx);
		},
	});

	pi.on("session_shutdown", () => {
		if (refreshTimer) clearInterval(refreshTimer);
		refreshTimer = undefined;
		requestRender = undefined;
		state = undefined;
	});
}
