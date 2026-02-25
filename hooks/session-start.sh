#!/bin/bash
# Session Start Hook - ML/AI Operations
# Detects project context and configures the session

LOG_DIR="$(dirname "$0")/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/session-$(date +%Y%m%d-%H%M%S).log"

log() {
  echo "[$(date +%H:%M:%S)] $1" >> "$LOG_FILE"
}

log "Session started"
log "Working directory: $(pwd)"

# Detect ML/AI Operations context
detect_context() {
  local indicators=0
  
  
  [ -f "requirements.txt" ] && grep -q "torch\|tensorflow\|sklearn" requirements.txt 2>/dev/null && indicators=$((indicators + 1))
  [ -f "MLproject" ] && indicators=$((indicators + 1))
  [ -d "models/" ] && indicators=$((indicators + 1))
  [ -d "data/" ] && indicators=$((indicators + 1))
  [ -f "dvc.yaml" ] && indicators=$((indicators + 1))
  [ -d "notebooks/" ] && indicators=$((indicators + 1))

  
  echo "$indicators"
}

CONTEXT_SCORE=$(detect_context)
log "Context score: $CONTEXT_SCORE"

if [ "$CONTEXT_SCORE" -gt 0 ]; then
  log "ML/AI Operations project detected"
  echo "[ML/AI Operations] Project context detected. Relevant plugins activated."
else
  log "No ML/AI Operations context found"
fi

# Check for project-specific configuration
if [ -f "CLAUDE.md" ]; then
  log "Found project CLAUDE.md"
fi

if [ -f ".claude/settings.json" ]; then
  log "Found Claude settings"
fi

log "Session start hook complete"
