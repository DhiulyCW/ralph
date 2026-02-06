#!/bin/bash
set -e

# ============================================================
# ralph-once.sh — Execute one task using multi-agent dispatch
# Phase 1: Dispatch (identify next task + responsible agent)
# Phase 2: Execute (run claude --agent to implement the task)
# ============================================================

# --- Phase 1: Dispatch ---
echo "[ralph] Phase 1: Dispatching next task..."

dispatch=$(claude --dangerously-skip-permissions -p "@PRD.md @progress.txt \
You are a task dispatcher. Read the PRD and progress file. \
Identify the next incomplete task that has all its dependencies satisfied. \
Normalize the agent name to lowercase with hyphens (e.g. 'DevOps' becomes 'devops', 'Front-End' becomes 'front-end'). \
Output EXACTLY 3 lines in this format and nothing else: \
RALPH_TASK_ID=<task id> \
RALPH_AGENT=<agent name lowercase> \
RALPH_DESCRIPTION=<task description> \
If ALL tasks are complete, output only: \
RALPH_TASK_ID=COMPLETE")

echo "$dispatch"

# --- Parse dispatch output ---
RALPH_TASK_ID=$(echo "$dispatch" | grep '^RALPH_TASK_ID=' | head -1 | cut -d'=' -f2-)
RALPH_AGENT=$(echo "$dispatch" | grep '^RALPH_AGENT=' | head -1 | cut -d'=' -f2-)
RALPH_DESCRIPTION=$(echo "$dispatch" | grep '^RALPH_DESCRIPTION=' | head -1 | cut -d'=' -f2-)

# --- Check if complete ---
if [ "$RALPH_TASK_ID" = "COMPLETE" ]; then
  echo "[ralph] All tasks are complete!"
  exit 0
fi

# --- Validate parsed values ---
if [ -z "$RALPH_TASK_ID" ] || [ -z "$RALPH_AGENT" ] || [ -z "$RALPH_DESCRIPTION" ]; then
  echo "[ralph] ERROR: Could not parse dispatch output."
  echo "[ralph] Expected RALPH_TASK_ID, RALPH_AGENT, and RALPH_DESCRIPTION."
  exit 1
fi

# --- Validate agent exists ---
if [ ! -f ".claude/agents/${RALPH_AGENT}.md" ]; then
  echo "[ralph] ERROR: Agent '${RALPH_AGENT}' not found at .claude/agents/${RALPH_AGENT}.md"
  echo "[ralph] Please create the agent file before running Ralph."
  exit 1
fi

echo "[ralph] Task: $RALPH_TASK_ID | Agent: $RALPH_AGENT"
echo "[ralph] Description: $RALPH_DESCRIPTION"

# --- Phase 2: Execute ---
echo "[ralph] Phase 2: Executing with agent '$RALPH_AGENT'..."

claude --agent "$RALPH_AGENT" --dangerously-skip-permissions -p "@PRD.md @progress.txt \
Your assigned task: $RALPH_TASK_ID - $RALPH_DESCRIPTION \
1. Implement the task fully. \
2. Run tests and type checks. \
3. Commit your changes with prefix [$RALPH_AGENT]. \
4. Update progress.txt with what you did. \
ONLY WORK ON THIS SINGLE TASK."

echo "[ralph] Task $RALPH_TASK_ID completed by agent '$RALPH_AGENT'."
