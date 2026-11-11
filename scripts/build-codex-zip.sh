#!/bin/sh
# Builds the ZIP for the OpenAI plugin portal (Codex format):
# .codex-plugin/plugin.json, .mcp.json, skills/, assets/, README.md, LICENSE.
# Files for other clients (.claude-plugin, .cursor-plugin, mcp.json) are left out.
set -eu
cd "$(dirname "$0")/.."
version=$(sed -n 's/^  "version": "\(.*\)",$/\1/p' .codex-plugin/plugin.json)
out="dist/snaprender-codex-plugin-$version.zip"
mkdir -p dist
rm -f "$out"
zip -r -X "$out" .codex-plugin/plugin.json .mcp.json skills assets README.md LICENSE -x '*.DS_Store'
echo "Built $out"
