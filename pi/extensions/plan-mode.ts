import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

/** Read-only tools may still be used while planning. */
const WRITE_TOOLS = new Set(["edit", "write"]);

interface PlanModeState {
  mode: "plan" | "build";
  toolsBeforePlan?: string[];
}

function isReadOnlyCommand(command: string): boolean {
  // Plan mode deliberately accepts a small command language rather than trying
  // to identify every destructive shell command.
  const safeStart =
    /^\s*(?:cat|head|tail|grep|rg|find|fd|ls|eza|pwd|stat|file|wc|sort|uniq|diff|sed\s+-n|awk|jq|git\s+(?:status|log|diff|show|branch|remote|config\s+--get)|npm\s+(?:list|ls|view|info|search|outdated|audit)|which|whereis|type|env|printenv|uname|whoami|id|date|ps|du|df|tree)\b/i;
  const shellMutation = /(?:^|[;&|])\s*(?:rm|rmdir|mv|cp|mkdir|touch|chmod|chown|tee|truncate|dd|shred|git\s+(?:add|commit|push|pull|merge|rebase|reset|checkout|stash|cherry-pick|revert)|npm\s+(?:install|update|uninstall|publish)|pnpm\s+(?:add|install|remove)|yarn\s+(?:add|install|remove)|sudo|su|kill|systemctl|service)\b|(?<!<)>{1,2}|\$\(|`/i;

  return safeStart.test(command) && !shellMutation.test(command);
}

export default function planMode(pi: ExtensionAPI): void {
  let mode: "plan" | "build" = "build";
  let toolsBeforePlan: string[] | undefined;

  function updateUi(ctx: ExtensionContext): void {
    const label = mode === "plan" ? "plan" : "build";
    const color = mode === "plan" ? "warning" : "success";
    ctx.ui.setStatus("plan-mode", ctx.ui.theme.fg(color, `◌ ${label}`));
  }

  function persist(): void {
    pi.appendEntry("plan-mode", { mode, toolsBeforePlan } satisfies PlanModeState);
  }

  function setMode(nextMode: "plan" | "build", ctx: ExtensionContext): void {
    if (nextMode === mode) return;

    if (nextMode === "plan") {
      toolsBeforePlan ??= pi.getActiveTools();
      pi.setActiveTools(toolsBeforePlan.filter((name) => !WRITE_TOOLS.has(name)));
      mode = "plan";
      ctx.ui.notify("Plan mode enabled: changes and non-read-only bash commands are blocked.", "info");
    } else {
      pi.setActiveTools(toolsBeforePlan ?? pi.getActiveTools());
      toolsBeforePlan = undefined;
      mode = "build";
      ctx.ui.notify("Build mode enabled: full tool access restored.", "info");
    }

    updateUi(ctx);
    persist();
  }

  function toggle(ctx: ExtensionContext): void {
    setMode(mode === "plan" ? "build" : "plan", ctx);
  }

  pi.registerCommand("plan", {
    description: "Switch to read-only plan mode",
    handler: async (_args, ctx) => setMode("plan", ctx),
  });
  pi.registerCommand("build", {
    description: "Switch to build mode with write access",
    handler: async (_args, ctx) => setMode("build", ctx),
  });
  pi.registerCommand("mode", {
    description: "Show or switch mode: /mode [plan|build]",
    handler: async (args, ctx) => {
      const requested = args.trim().toLowerCase();
      if (requested === "plan" || requested === "build") {
        setMode(requested, ctx);
      } else if (!requested) {
        ctx.ui.notify(`Current mode: ${mode}`, "info");
      } else {
        ctx.ui.notify("Usage: /mode [plan|build]", "warning");
      }
    },
  });

  // Shift+Tab is intentionally the default mode switch, matching OpenCode.
  pi.registerShortcut("shift+tab", {
    description: "Cycle plan/build mode",
    handler: async (ctx) => toggle(ctx),
  });

  // setActiveTools is UI state, not an access-control boundary. Keep this gate
  // so a model cannot write if another extension re-enables a tool mid-plan.
  pi.on("tool_call", (event) => {
    if (mode !== "plan") return;
    if (WRITE_TOOLS.has(event.toolName)) {
      return { block: true, reason: "Plan mode is read-only. Press Shift+Tab or use /build to make changes." };
    }
    if (event.toolName === "bash" && !isReadOnlyCommand(event.input.command as string)) {
      return { block: true, reason: "Plan mode only permits read-only bash commands. Use /build to run this command." };
    }
  });

  pi.on("before_agent_start", (event) => {
    if (mode !== "plan") return;
    return {
      systemPrompt: `${event.systemPrompt}\n\n[PLAN MODE ACTIVE]\nExplore and analyze only. Do not make changes. Use the available read-only tools to gather context, then give a concise implementation plan with numbered steps. Ask clarifying questions when needed. To make changes, tell the user to switch to build mode with Shift+Tab or /build.`,
    };
  });

  pi.on("session_start", (_event, ctx) => {
    const entry = ctx.sessionManager
      .getEntries()
      .filter((item: { type: string; customType?: string }) => item.type === "custom" && item.customType === "plan-mode")
      .pop() as { data?: PlanModeState } | undefined;

    if (entry?.data?.mode === "plan" || entry?.data?.mode === "build") {
      mode = entry.data.mode;
      toolsBeforePlan = entry.data.toolsBeforePlan;
    }
    if (mode === "plan") {
      toolsBeforePlan ??= pi.getActiveTools();
      pi.setActiveTools(toolsBeforePlan.filter((name) => !WRITE_TOOLS.has(name)));
    }
    updateUi(ctx);
  });
}
