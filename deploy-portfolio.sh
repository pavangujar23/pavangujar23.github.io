#!/bin/bash
# =============================================================
#  deploy-portfolio.sh
#  Deploys your portfolio (index.html) to GitHub Pages.
#
#  Usage:
#    ./deploy-portfolio.sh              # auto commit message
#    ./deploy-portfolio.sh "my message" # custom commit message
#
#  First-time setup — set your token once in your shell profile:
#    echo 'export GITHUB_TOKEN="ghp_your_token_here"' >> ~/.zshrc
#    source ~/.zshrc
# =============================================================

set -e  # exit on any error

# ── CONFIG ────────────────────────────────────────────────────
GITHUB_USERNAME="pavangujar23"
GITHUB_EMAIL="pratheek98876@gmail.com"
# Token is read from environment — never hardcode secrets in scripts
if [ -z "$GITHUB_TOKEN" ]; then
  echo "✗ GITHUB_TOKEN environment variable is not set."
  echo "  Run:  export GITHUB_TOKEN=\"ghp_your_token_here\""
  echo "  Or add that line to your ~/.zshrc to make it permanent."
  exit 1
fi
REPO_NAME="pavangujar23.github.io"
REMOTE_URL="https://${GITHUB_USERNAME}:${GITHUB_TOKEN}@github.com/${GITHUB_USERNAME}/${REPO_NAME}.git"

# Source portfolio file (edit this if you rename/move the file)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_HTML="$SCRIPT_DIR/pavan-gujar-portfolio.html"

# Local working directory for the repo
WORK_DIR="$HOME/.portfolio-deploy/${REPO_NAME}"
# ── END CONFIG ────────────────────────────────────────────────

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Colour

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🚀  Portfolio Deploy Script"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 1. Check source file exists
if [ ! -f "$SOURCE_HTML" ]; then
  echo -e "${RED}✗ Source file not found: $SOURCE_HTML${NC}"
  echo "  Make sure pavan-gujar-portfolio.html is in the same folder as this script."
  exit 1
fi
echo -e "${GREEN}✓ Source file found${NC}: $SOURCE_HTML"

# 2. Set up or update local repo clone
if [ ! -d "$WORK_DIR/.git" ]; then
  echo ""
  echo "  First run — cloning repo..."
  mkdir -p "$WORK_DIR"
  git clone "$REMOTE_URL" "$WORK_DIR" 2>/dev/null || {
    # Repo is empty, init fresh
    git init "$WORK_DIR"
    cd "$WORK_DIR"
    git remote add origin "$REMOTE_URL"
  }
  echo -e "${GREEN}✓ Repo ready${NC}"
else
  echo -e "${GREEN}✓ Local repo exists${NC}, pulling latest..."
  cd "$WORK_DIR"
  git remote set-url origin "$REMOTE_URL"
  git pull origin main --rebase 2>/dev/null || true
fi

cd "$WORK_DIR"

# 3. Configure git identity
git config user.name  "$GITHUB_USERNAME"
git config user.email "$GITHUB_EMAIL"

# 4. Copy updated portfolio as index.html
cp "$SOURCE_HTML" index.html

# Ensure .nojekyll exists (required for plain HTML — disables Jekyll)
touch .nojekyll

# 5. Check if anything actually changed
if git diff --quiet index.html 2>/dev/null && git ls-files --error-unmatch index.html &>/dev/null; then
  echo ""
  echo -e "${YELLOW}⚠  No changes detected in index.html — nothing to deploy.${NC}"
  echo "   Edit pavan-gujar-portfolio.html and re-run this script."
  echo ""
  exit 0
fi

# 6. Commit with message
COMMIT_MSG="${1:-"Update portfolio - $(date '+%Y-%m-%d %H:%M')"}"
git add index.html .nojekyll
git commit -m "$COMMIT_MSG"

# 7. Push
echo ""
echo "  Pushing to GitHub..."
git branch -M main
git push -u origin main 2>&1 | grep -v "^remote:" | grep -v "^hint:" || true

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  ✅  Deployed successfully!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "  🌐  Live URL  : https://pavangujar23.github.io"
echo "  📦  Repo      : https://github.com/pavangujar23/pavangujar23.github.io"
echo "  ⏱   GitHub Pages rebuilds in ~30–60 seconds."
echo ""
