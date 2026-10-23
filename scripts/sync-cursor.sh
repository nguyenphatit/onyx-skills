#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR="${1:-.}"
RULES_DIR="$TARGET_DIR/.cursor/rules"

mkdir -p "$RULES_DIR"

# Copy global principles as base rule
cp .rules/global-principles.md "$RULES_DIR/00-global-principles.mdc"

# Sync individual skills
for skill_dir in skills/*; do
  if [ -d "$skill_dir" ] && [ -f "$skill_dir/SKILL.md" ]; then
    skill_name=$(basename "$skill_dir")
    cp "$skill_dir/SKILL.md" "$RULES_DIR/${skill_name}.mdc"
  fi
done

echo "Successfully exported skills to: $RULES_DIR"