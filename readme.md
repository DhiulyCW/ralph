# Ralph — Multi-Agent Task Runner for Claude Code CLI

Ralph is a lightweight orchestrator that turns a PRD (Product Requirements Document) into working code by dispatching tasks to specialized [Claude Code CLI subagents](https://code.claude.com/docs/en/sub-agents).

You write the plan. You define the agents. Ralph loops through the tasks, picks the right agent for each one, and gets it done — while you sleep.

![Ralph Wiggum, Senior Software Engineer](ralph.png)

## How It Works

Each iteration has two phases:

1. **Dispatch** — Claude reads `PRD.md` + `progress.txt`, identifies the next incomplete task (respecting dependencies), and determines the responsible agent.
2. **Execute** — Ralph calls `claude --agent <name>` with the registered subagent, which implements the task, runs tests, commits, and updates `progress.txt`.

```
PRD.md + progress.txt
        |
        v
  Dispatch (claude -p)
  "Next task: 1.2 | Agent: backend"
        |
        v
  Validate .claude/agents/backend.md exists
        |
        v
  Execute (claude --agent backend)
  Implements, tests, commits, updates progress
        |
        v
  Loop or stop
```

## Prerequisites

- [Claude Code CLI](https://code.claude.com/docs/en/overview) installed and authenticated

## Project Structure

```
your-project/
├── .claude/
│   └── agents/          # Your subagent definitions (you create these)
│       ├── backend.md
│       ├── devops.md
│       └── ...
├── PRD.md               # Your task plan with agent assignments
├── progress.txt         # Auto-updated log of completed tasks
├── gen-prd.sh           # Optional: generate PRD with Claude
├── ralph-once.sh        # Run one task
└── ralph-afk.sh         # Run N tasks in a loop
```

## Quick Start

### 1. Write your PRD

Create a `PRD.md` with a task table. Each task must have a **Responsavel** (or Responsible) column indicating which agent handles it:

```markdown
| #   | Task                      | Responsavel  | Estimate | Depends on |
|-----|---------------------------|--------------|----------|------------|
| 1.1 | Create docker-compose.yml | **DevOps**   | 4h       | -          |
| 1.2 | Setup FastAPI project      | **Backend**  | 3h       | 1.1        |
| 1.3 | Setup Next.js project      | **Frontend** | 3h       | 1.1        |
| 1.4 | Validate environment       | **QA**       | 2h       | 1.1-1.3    |
```

Or use `gen-prd.sh` to generate one (edit the prompt inside first):

```bash
./gen-prd.sh
```

### 2. Create your agents

For each role in your PRD, create a file in `.claude/agents/` following the [Claude Code CLI subagent format](https://code.claude.com/docs/en/sub-agents):

```markdown
---
name: backend
description: Use this agent for backend tasks
model: inherit
permissionMode: bypassPermissions
---

You are a Senior Backend Engineer.
Implement the assigned task fully, run tests, commit with prefix [backend],
and update progress.txt.
```

The `name` must match the role from your PRD, normalized to lowercase with hyphens (e.g., "DevOps" becomes `devops`, "Front-End" becomes `front-end`).

### 3. Run

**One task at a time** (babysitting mode):

```bash
./ralph-once.sh
```

**N tasks in a loop** (AFK mode):

```bash
./ralph-afk.sh 50
```

Ralph stops automatically when all tasks are complete.

## Scripts Reference

| Script | Description |
|--------|-------------|
| `gen-prd.sh` | Generates a PRD using Claude in plan mode. Edit the prompt inside for your project. |
| `ralph-once.sh` | Dispatches and executes exactly one task. Exits with 0 if all tasks are done. |
| `ralph-afk.sh <N>` | Runs up to N iterations. Stops early if the PRD is complete. Retries on dispatch parse failures. |

## Error Handling

- **Agent not found** — If a task's agent doesn't have a matching `.claude/agents/{name}.md` file, Ralph stops with a clear error message.
- **Parse failure** — If the dispatch output can't be parsed, `ralph-once.sh` exits with error; `ralph-afk.sh` retries on the next iteration.
- **All tasks complete** — Ralph exits cleanly with a success message.

## Tips

- Keep tasks small and specific. Ralph works best with well-scoped units of work.
- Watch the first few runs with `ralph-once.sh` to make sure dispatch picks tasks correctly.
- Use `git log` to follow progress — commits are prefixed with the agent name (e.g., `[backend]`, `[devops]`).
- Tailor each agent's system prompt to your stack. The more specific the agent, the better the output.

## License

MIT License

Copyright (c) 2026 luisbebop

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
