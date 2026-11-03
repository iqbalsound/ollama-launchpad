# Troubleshooting

Start with `./scripts/healthcheck.sh`.

## `permission denied` talking to Docker
You are not in the `docker` group yet. Run `sudo usermod -aG docker $USER`, then log out and in (or `newgrp docker`). Quick fix: prefix commands with `sudo`.

## Open WebUI loads but shows no models
- Is Ollama up? `curl http://127.0.0.1:11434/api/version`
- Any models? `ollama list`
- **Bridge mode (:3000):** Ollama must listen on all interfaces: `./scripts/02-install-ollama.sh --expose`. The URL must be `http://host.docker.internal:11434`. The old notes used `http://docker.internal`, which is wrong.
- Check the connection in *Admin Panel → Settings → Connections*.

## Cannot open the page from another computer
```bash
sudo firewall-cmd --list-all
./scripts/05-firewall.sh 8080     # or 3000 for bridge mode
```
Find the VM IP with `hostname -I`. If the VM runs in VirtualBox, use **Bridged Adapter** networking so it gets an address on your LAN.

## Ollama installer fails with "zstd" or "tar" errors
`sudo dnf install -y tar zstd`

## Container keeps restarting
`docker logs --tail 100 open-webui`. First boot downloads embedding data and can take a minute.

## Model download is slow or stalls
Re-run `ollama pull <model>`; it resumes. Check disk space with `df -h`.

## Out of memory / system freezes
Use a smaller model (`deepseek-r1:1.5b`, `smollm2:1.7b`), give the VM more RAM, or add swap.

## Port already in use
`sudo ss -ltnp | grep -E ':(8080|3000)'` then stop the conflicting service or use the other mode.

## Debian / Ubuntu
The scripts target `dnf`. On Ubuntu, install Docker via the official apt repo (https://docs.docker.com/engine/install/ubuntu/), then Ollama with `curl -fsSL https://ollama.com/install.sh | sh`. After that, `scripts/03-pull-models.sh` and `scripts/04-run-open-webui.sh` work unchanged. Pull requests for native apt support are welcome.

## Update everything
```bash
curl -fsSL https://ollama.com/install.sh | sh     # updates Ollama
./scripts/04-run-open-webui.sh host               # pulls newest Open WebUI image
```
