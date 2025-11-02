#!/usr/bin/env bash

# Git Helper Script - Generates conventional commit messages using Gemini
# Usage: git-helper.sh

set -euo pipefail

# Check if there are staged changes
if git diff --cached --quiet; then
    echo "No staged changes found. Use 'git add' to stage changes first." >&2
    exit 1
fi

echo "Analyzing staged changes..." >&2

# Get Git diff and pipe to Gemini to generate the commit message
git diff --cached | gemini --yolo "You are a Git assistant specialized in writing high-quality, conventional commit messages. Your job is to generate concise, clear, and meaningful commit messages based on the provided git diff. Follow these rules:
- Write in the imperative mood (e.g., 'Add', 'Fix', 'Update' — not 'Added' or 'Fixed').
- Keep the commit summary under 80 characters if possible.
- Only output the commit message.
- Add a short description after the summary, separated by a blank line, if the change needs further context."