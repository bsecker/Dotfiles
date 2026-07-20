import type { ExtensionAPI, ExtensionCommandContext } from "@earendil-works/pi-coding-agent";
import { constants, existsSync, promises as fs } from "node:fs";
import * as path from "node:path";
import { randomUUID } from "node:crypto";

function shellQuote(value: string): string {
  if (value.length === 0) return "''";
  return `'${value.replace(/'/g, `'"'"'`)}'`;
}

function getPiInvocationParts(): string[] {
  const currentScript = process.argv[1];
  if (currentScript && existsSync(currentScript)) {
    return [process.execPath, currentScript];
  }

  const executable = path.basename(process.execPath).toLowerCase();
  if (!/^(node|bun)(\.exe)?$/.test(executable)) {
    return [process.execPath];
  }

  return ["pi"];
}

function buildPiStartupCommand(sessionFile: string | undefined, prompt: string): string {
  const command = getPiInvocationParts();

  if (sessionFile) command.push("--session", sessionFile);
  if (prompt) command.push("--", prompt);

  return command.map(shellQuote).join(" ");
}

async function createForkedSession(ctx: ExtensionCommandContext): Promise<string | undefined> {
  const sessionFile = ctx.sessionManager.getSessionFile();
  if (!sessionFile) return undefined;

  const timestamp = new Date().toISOString();
  const sessionId = randomUUID();
  const forkedSessionFile = path.join(
    path.dirname(sessionFile),
    `${timestamp.replace(/[:.]/g, "-")}_${sessionId}.jsonl`,
  );
  const header = ctx.sessionManager.getHeader();
  const forkedHeader = {
    type: "session",
    version: header?.version ?? 3,
    id: sessionId,
    timestamp,
    cwd: header?.cwd ?? ctx.cwd,
    parentSession: sessionFile,
  };
  const contents = [
    JSON.stringify(forkedHeader),
    ...ctx.sessionManager.getBranch().map((entry) => JSON.stringify(entry)),
  ].join("\n") + "\n";

  await fs.mkdir(path.dirname(forkedSessionFile), { recursive: true });
  await fs.writeFile(forkedSessionFile, contents, "utf8");
  return forkedSessionFile;
}

async function findExecutable(name: string): Promise<string | undefined> {
  for (const directory of (process.env.PATH ?? "").split(path.delimiter)) {
    if (!directory) continue;
    const candidate = path.join(directory, name);
    try {
      await fs.access(candidate, constants.X_OK);
      return candidate;
    } catch {
      // Try the next PATH entry.
    }
  }
  return undefined;
}

export default function (pi: ExtensionAPI): void {
  pi.registerCommand("split-fork", {
    description: "Fork this session into pi in a new Kitty window managed by niri. Usage: /split-fork [optional prompt]",
    handler: async (args, ctx) => {
      if (ctx.mode !== "tui") {
        ctx.ui.notify("/split-fork requires interactive TUI mode.", "warning");
        return;
      }

      const kitty = await findExecutable("kitty");
      if (!kitty) {
        ctx.ui.notify("Cannot find kitty in PATH.", "error");
        return;
      }

      const wasBusy = !ctx.isIdle();
      const prompt = args.trim();
      const forkedSessionFile = await createForkedSession(ctx);
      const startupCommand = buildPiStartupCommand(forkedSessionFile, prompt);
      const result = await pi.exec("niri", [
        "msg", "action", "spawn", "--",
        kitty, "--directory", ctx.cwd, "--hold", "sh", "-lc", startupCommand,
      ]);

      if (result.code !== 0) {
        const reason = result.stderr.trim() || result.stdout.trim() || "unknown niri error";
        ctx.ui.notify(`Failed to launch Kitty through niri: ${reason}`, "error");
        if (forkedSessionFile) ctx.ui.notify(`Forked session was created: ${forkedSessionFile}`, "info");
        return;
      }

      if (!forkedSessionFile) {
        ctx.ui.notify("Opened a Kitty window through niri (the current session is not persisted).", "warning");
        return;
      }

      const suffix = prompt ? " and sent prompt" : "";
      ctx.ui.notify(`Forked to ${path.basename(forkedSessionFile)} in a new Kitty window${suffix}.`, "info");
      if (wasBusy) {
        ctx.ui.notify("Forked from committed state; the in-flight turn continues in the original session.", "info");
      }
    },
  });
}
