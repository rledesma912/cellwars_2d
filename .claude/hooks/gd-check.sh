#!/usr/bin/env bash
# Formatea y lintea cada .gd que el agente escribe. Exit 2 devuelve los errores al agente.
set -uo pipefail
file=$(jq -r '.tool_input.file_path // empty')
[[ "$file" == *.gd ]] || exit 0
gdformat "$file" >/dev/null 2>&1
if ! out=$(gdlint "$file" 2>&1); then
  echo "$out" >&2
  exit 2
fi
exit 0
