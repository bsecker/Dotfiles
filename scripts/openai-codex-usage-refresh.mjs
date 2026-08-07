import { mkdir, readFile, rename, writeFile } from "node:fs/promises";
import { homedir } from "node:os";
import { dirname, join } from "node:path";

const authFile = join(homedir(), ".pi", "agent", "auth.json");
const cacheFile = join(process.env.XDG_CACHE_HOME ?? join(homedir(), ".cache"), "openai-codex", "usage.json");

function windowsFromResponse(response) {
	return [response.rate_limit?.primary_window, response.rate_limit?.secondary_window]
		.filter(Boolean)
		.map((window) => ({
			label: `${Math.round((window.limit_window_seconds ?? 0) / 3_600)}h`,
			usedPercent: Math.round(window.used_percent ?? 0),
			resetAt: new Date((window.reset_at ?? 0) * 1_000).toISOString(),
		}));
}

async function main() {
	const auth = JSON.parse(await readFile(authFile, "utf8"))["openai-codex"];
	if (!auth?.access || !auth?.accountId) throw new Error("Pi is not signed in to Codex");

	const response = await fetch("https://chatgpt.com/backend-api/wham/usage", {
		headers: {
			Authorization: `Bearer ${auth.access}`,
			"ChatGPT-Account-Id": auth.accountId,
		},
	});
	if (!response.ok) throw new Error(`Usage request failed (${response.status})`);

	const usage = await response.json();
	const payload = {
		codex: {
			fetchedAt: Date.now(),
			usage: {
				provider: "codex",
				displayName: usage.plan_type ? `Codex ${usage.plan_type}` : "Codex",
				windows: windowsFromResponse(usage),
			},
		},
	};

	await mkdir(dirname(cacheFile), { recursive: true });
	const temporaryFile = `${cacheFile}.${process.pid}.tmp`;
	await writeFile(temporaryFile, JSON.stringify(payload, null, 2));
	await rename(temporaryFile, cacheFile);
}

main().catch((error) => {
	console.error(error instanceof Error ? error.message : "Could not refresh Codex usage");
	process.exitCode = 1;
});
