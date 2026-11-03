# Choosing a model

Sizes are approximate downloads for the default quantisation; check the [Ollama library](https://ollama.com/library) for current tags.

| Model | Pull command | Size | RAM (min) | Good for |
|---|---|---|---|---|
| DeepSeek-R1 1.5B | `ollama pull deepseek-r1:1.5b` | ~1.1 GB | 4 GB | Light reasoning demos, weak hardware |
| SmolLM2 1.7B | `ollama pull smollm2:1.7b` | ~1.8 GB | 4 GB | Fast, simple chat and summaries |
| Llama 3.2 3B | `ollama pull llama3.2:3b` | ~2 GB | 6 GB | General chat |
| Gemma 3 4B | `ollama pull gemma3:4b` | ~3.3 GB | 8 GB | Multilingual, balanced |
| Mistral 7B | `ollama pull mistral` | ~4.1 GB | 8 GB | Strong all-rounder |
| Qwen2.5-Coder 7B | `ollama pull qwen2.5-coder:7b` | ~4.7 GB | 8 GB | Coding help |

**Rule of thumb:** model file size + 2-3 GB must fit in free RAM (or VRAM on a GPU). On CPU-only VMs, stay at or below 7B.

Useful commands:
```bash
ollama list              # installed models
ollama run mistral       # chat in the terminal
ollama ps                # what is loaded in memory
ollama rm <model>        # delete a model
```
