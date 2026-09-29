#!/usr/bin/env bash

set -euo pipefail

packages=(
  "npm:pi-web-access"
  "npm:@upstash/context7-pi"
  "npm:pi-chrome"
  "/Users/daniel/.config/nono/packages/nolabs-ai/pi"
  "npm:context-mode"
  "npm:pi-mcp-adapter"
  "npm:pi-open-tui"
  "npm:pi-acp"
  "npm:pi-matt-pocock-skills"
  "npm:pi-claude-bridge"
  "npm:pi-subagents"
)

for package in "${packages[@]}"; do
  echo "Installing pi package: $package"
  pi install "$package"
done
