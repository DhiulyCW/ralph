# Ralph Wiggum, Senior Software Engineer 🧑‍💻

Meet Ralph Wiggum — Senior Software Engineer, 15+ years of experience, expert in cloud-native paste-eating architectures, former Staff Engineer at Crayons.io, and current holder of the world record for "most consecutive all-nighters without ever asking for a promotion."

While real senior devs are busy:
- Writing 47-page design docs nobody reads
- Arguing about dependency injection in Slack
- Quietly pushing `console.log("works on my machine")` to production
- Demanding bonus and unlimited PTO

Ralph just **loops**.  
Fail → fix → fail → fix → commit → repeat.  
No ego. No standups. No "let me circle back on that."  
Just pure, adorable, unstoppable persistence powered by Claude and a couple of bash scripts.

This is the **original external Ralph Loop** — the one that keeps sessions fresh, avoids context drift, and turns your AI into a gremlin that codes while you sleep. Because why pay a senior six figures when Ralph will do it for API credits and a gold star?

![Ralph Wiggum, Senior Software Engineer](ralph.png)

## What's Inside?

- **`gen-prd.sh`** – Ralph writes a beautiful PRD (usually better than the ones from your last architecture review).
- **`PRD.md`** – The single source of truth. Ralph treats it like his Valentine from Lisa. Must include a task table with a **Responsável** (responsible agent) column.
- **`progress.txt`** – Ralph's little diary: "Today I made the button work. I'm special!"
- **`ralph-once.sh`** – Dispatch one task to the right agent. Perfect for watching Ralph think.
- **`ralph-afk.sh`** – Fire and forget. Give it a number and go touch grass. Ralph doesn't need breaks.

## How It Works (Multi-Agent Dispatch)

Ralph reads your PRD, finds the next task, identifies the responsible agent, and calls `claude --agent <name>` to execute it. Each agent is a registered Claude Code CLI subagent.

```
1. PRD.md + progress.txt
         |
         v
2. Dispatch: Claude identifies next task + responsible agent
         |
         v
3. Validates that .claude/agents/{agent}.md exists
         |
         v
4. Execute: claude --agent {agent} implements, tests, commits
         |
         v
5. Updates progress.txt
         |
         v
6. Loop (ralph-afk.sh) or stop (ralph-once.sh)
```

### PRD Task Table Format

Your PRD must have a task table with a **Responsável** (or Responsible) column. The agent name will be normalized to lowercase with hyphens. Example:

```markdown
| #   | Task                          | Responsável  | Estimate | Depends on |
|-----|-------------------------------|--------------|----------|------------|
| 1.1 | Create docker-compose.yml     | **DevOps**   | 4h       | -          |
| 1.2 | Setup FastAPI project          | **Backend**  | 3h       | 1.1        |
| 1.3 | Setup Next.js project          | **Frontend** | 3h       | 1.1        |
```

### Setting Up Agents

Before running Ralph, you must create your agents in `.claude/agents/` using the Claude Code CLI subagent format. Each agent is a Markdown file with YAML frontmatter:

```markdown
---
name: backend
description: Use this agent for backend tasks (APIs, database, Python)
model: inherit
permissionMode: bypassPermissions
---

You are a Senior Backend Engineer. Implement the assigned task fully.
After completing, commit with prefix [backend] and update progress.txt.
```

The `name` field must match the normalized agent name from your PRD (e.g., "DevOps" in the PRD → `devops` → `.claude/agents/devops.md` with `name: devops`).

## Quick Start

1. Make sure you have the [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) installed and an API key.

2. Create your agents in `.claude/agents/` (one `.md` file per role in your PRD).

3. Generate the PRD:
   ```bash
   ./gen-prd.sh
   ```
   (Edit the prompt inside for your own project — Ralph is very flexible.)

4. Try one step (babysitting mode):
   ```bash
   ./ralph-once.sh
   ```
   Watch Ralph dispatch the task to the right agent, implement it, commit, and update progress.

5. Go full Ralph (AFK mode):
   ```bash
   ./ralph-afk.sh 50
   ```
   Come back later to a (hopefully) finished app. When all tasks are done, Ralph stops automatically!

## Tips for Maximum Ralph

- Write a rock-solid PRD first. Chat with Claude normally, then paste the final version.
- Make sure the PRD task table has a clear **Responsável** column — Ralph uses it to pick the agent.
- Create your `.claude/agents/` files before running. Ralph will error out if an agent is missing.
- Keep tasks tiny and testable — that's how Ralph stays on track.
- Watch the first few runs with `ralph-once.sh`. If Ralph starts writing placeholder code, gently remind him in the PRD.
- Use `git log` to see Ralph's heroic journey — commits are prefixed with the agent name.
- Unlike certain senior engineers, Ralph actually reads the error messages.

Ralph may not be the smartest dev on the block, but he **never gives up**.  
And honestly? That's more than you can say for half the staff+ titles out there.

Happy looping! 🎉

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