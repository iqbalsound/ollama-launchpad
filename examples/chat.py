#!/usr/bin/env python3
"""Minimal streaming chat client for a local Ollama server (standard library only).

Usage:
    python3 examples/chat.py                      # uses mistral
    python3 examples/chat.py deepseek-r1:1.5b     # pick a model
    OLLAMA_URL=http://192.168.10.4:11434 python3 examples/chat.py
"""
import json
import os
import sys
import urllib.request

URL = os.environ.get("OLLAMA_URL", "http://127.0.0.1:11434")
MODEL = sys.argv[1] if len(sys.argv) > 1 else "mistral"


def chat(messages):
    body = json.dumps({"model": MODEL, "messages": messages, "stream": True}).encode()
    req = urllib.request.Request(f"{URL}/api/chat", data=body,
                                 headers={"Content-Type": "application/json"})
    reply = ""
    with urllib.request.urlopen(req) as resp:
        for line in resp:
            if not line.strip():
                continue
            chunk = json.loads(line)
            piece = chunk.get("message", {}).get("content", "")
            print(piece, end="", flush=True)
            reply += piece
            if chunk.get("done"):
                break
    print()
    return reply


def main():
    print(f"Chatting with {MODEL} at {URL}. Type 'exit' to quit.\n")
    history = []
    while True:
        try:
            user = input("You: ").strip()
        except (EOFError, KeyboardInterrupt):
            print()
            break
        if user.lower() in {"exit", "quit"}:
            break
        if not user:
            continue
        history.append({"role": "user", "content": user})
        print(f"{MODEL}: ", end="")
        history.append({"role": "assistant", "content": chat(history)})


if __name__ == "__main__":
    main()
