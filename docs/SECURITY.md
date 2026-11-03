# Security notes

1. **Do not `chmod 666 /var/run/docker.sock`.** It gives every local user root-equivalent control. Use `sudo usermod -aG docker $USER` instead (the repo does this by default; `--insecure-socket` restores the old behaviour for throwaway labs).
2. **Never expose port 11434 (Ollama API) to the internet.** It has no authentication. Only bridge mode needs it listening on `0.0.0.0`, so keep the firewall closed for that port.
3. **Open WebUI**: the first registered user becomes admin. Register immediately, then disable open sign-ups in *Admin Panel → Settings → General*.
4. **Public access**: put a reverse proxy with HTTPS (Caddy, Nginx) in front, or use a VPN such as WireGuard or Tailscale.
5. **Keep images updated**: `docker pull ghcr.io/open-webui/open-webui:main` and re-run `scripts/04-run-open-webui.sh`. Your data volume survives.
6. **Review remote scripts**: `curl ... | sh` runs code from the internet. Read https://ollama.com/install.sh first if that matters to you.
