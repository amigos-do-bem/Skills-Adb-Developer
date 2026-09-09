#!/usr/bin/env bash
# Instala/atualiza as skills ADB como skills pessoais do Claude Code (~/.claude/skills).
# Alternativa recomendada: usar como plugin (ver README.md).
set -euo pipefail
DEST="${HOME}/.claude/skills"
AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p "$DEST"
for d in "$AQUI"/skills/*/; do
  nome="$(basename "$d")"
  rm -rf "$DEST/$nome"
  cp -rL "$d" "$DEST/$nome"
  echo "✔ $nome"
done
echo "Pronto. Reinicie a sessão do Claude Code para as skills aparecerem no Skill tool."
