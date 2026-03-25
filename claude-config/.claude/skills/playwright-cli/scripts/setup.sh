#!/usr/bin/env bash
set -euo pipefail

if command -v playwright-cli &>/dev/null; then
  echo "playwright-cli is already installed: $(playwright-cli --version)"
  exit 0
fi

echo "Installing @playwright/cli globally..."
npm install -g @playwright/cli@latest

echo "Installing browser binaries..."
playwright-cli install

echo "Done. Verify with: playwright-cli --help"
