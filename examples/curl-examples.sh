#!/usr/bin/env bash
# Handy Ollama API calls. Run them one at a time.
OLLAMA_URL="${OLLAMA_URL:-http://127.0.0.1:11434}"

# Version
curl -s "$OLLAMA_URL/api/version"

# List installed models
curl -s "$OLLAMA_URL/api/tags"

# One-shot generation (non-streaming)
curl -s "$OLLAMA_URL/api/generate" -d '{
  "model": "smollm2:1.7b",
  "prompt": "Explain what a container is in two sentences.",
  "stream": false
}'

# Chat
curl -s "$OLLAMA_URL/api/chat" -d '{
  "model": "mistral",
  "messages": [{"role": "user", "content": "Give me 3 Linux troubleshooting tips."}],
  "stream": false
}'
