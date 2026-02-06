#!/bin/bash
set -e

# ============================================================
# ralph-afk.sh — AFK loop: dispatch + execute N tasks
# Uses registered Claude Code CLI agents from .claude/agents/
# ============================================================

if [ -z "$1" ]; then
  echo "Usage: $0 <iterations>"
  exit 1
fi

for ((i=1; i<=$1; i++)); do
  echo ""
  echo "========================================"
  echo "[ralph] Iteration $i of $1"
  echo "========================================"

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
    echo "[ralph] PRD complete after $i iterations."
    exit 0
  fi

  # --- Validate parsed values ---
  if [ -z "$RALPH_TASK_ID" ] || [ -z "$RALPH_AGENT" ] || [ -z "$RALPH_DESCRIPTION" ]; then
    echo "[ralph] ERROR: Could not parse dispatch output. Retrying..."
    continue
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
done

echo ""
echo "[ralph] Finished $1 iterations. PRD may not be complete yet."
