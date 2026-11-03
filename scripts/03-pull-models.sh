#!/usr/bin/env bash
# Pull one or more models.
# Usage: ./scripts/03-pull-models.sh                 # pulls the default starter set
#        ./scripts/03-pull-models.sh mistral gemma3:4b
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
. "$DIR/lib.sh"

have ollama || die "Ollama is not installed. Run scripts/02-install-ollama.sh first."

DEFAULT_MODELS=("deepseek-r1:1.5b" "smollm2:1.7b" "mistral")
if [ "$#" -gt 0 ]; then MODELS=("$@"); else MODELS=("${DEFAULT_MODELS[@]}"); fi

for m in "${MODELS[@]}"; do
  info "Pulling $m ..."
  if ollama pull "$m"; then
    ok "$m ready."
  else
    warn "Could not pull $m (check the name at https://ollama.com/library)."
  fi
done

echo
info "Installed models:"
ollama list
