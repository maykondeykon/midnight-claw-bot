#!/bin/bash
# Midnight Claw - Daily Backup Script
# Runs during the night to backup workspace configuration

set -e

BACKUP_DIR="/home/maykon/.midnight-backup"
SOURCE_DIR="/home/maykon/.openclaw"
TOKEN_FILE="$BACKUP_DIR/.github-token"
REPO_URL="git@github.com:maykondeykon/midnight-claw-bot.git"

# Load token
if [ -f "$TOKEN_FILE" ]; then
    TOKEN=$(cat "$TOKEN_FILE")
else
    echo "ERROR: Token file not found at $TOKEN_FILE"
    exit 1
fi

cd "$BACKUP_DIR"

# Copy workspace files
echo "Copying workspace files..."
cp -f "$SOURCE_DIR/workspace/AGENTS.md" workspace/ 2>/dev/null || true
cp -f "$SOURCE_DIR/workspace/SOUL.md" workspace/ 2>/dev/null || true
cp -f "$SOURCE_DIR/workspace/IDENTITY.md" workspace/ 2>/dev/null || true
cp -f "$SOURCE_DIR/workspace/USER.md" workspace/ 2>/dev/null || true
cp -f "$SOURCE_DIR/workspace/HEARTBEAT.md" workspace/ 2>/dev/null || true
cp -f "$SOURCE_DIR/workspace/TOOLS.md" workspace/ 2>/dev/null || true
cp -f "$SOURCE_DIR/workspace/MEMORY.md" workspace/ 2>/dev/null || true

# Copy memory files
echo "Copying memory files..."
mkdir -p workspace/memory
cp -f "$SOURCE_DIR"/workspace/memory/*.md workspace/memory/ 2>/dev/null || true

# Copy main config
echo "Copying openclaw.json..."
cp -f "$SOURCE_DIR/openclaw.json" . 2>/dev/null || true

# Check for changes
if git diff --quiet && git diff --cached --quiet; then
    echo "No changes to commit."
    exit 0
fi

# Commit and push
echo "Committing changes..."
git add -A
DATE=$(date '+%Y-%m-%d %H:%M:%S')
git commit -m "chore: daily backup - $DATE"

echo "Pushing to GitHub..."
git push https://$TOKEN@github.com/maykondeykon/midnight-claw-bot.git main 2>&1 | grep -v "github_pat" || true

echo "Backup completed successfully!"
