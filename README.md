<div align="center">

# 🚀 OllamaLaunchpad

**Your private AI lab in minutes: Docker + Ollama + Open WebUI on a RHEL-family VM.**

[![Lint](https://github.com/YOUR-USERNAME/ollama-launchpad/actions/workflows/lint.yml/badge.svg)](https://github.com/YOUR-USERNAME/ollama-launchpad/actions)
![License](https://img.shields.io/badge/license-MIT-green)
![Platform](https://img.shields.io/badge/platform-Rocky%20%7C%20Alma%20%7C%20CentOS%20%7C%20RHEL%20%7C%20Fedora-blue)

[▶ Watch the video](https://www.youtube.com/watch?v=FH99iG9lA8A&t=12s) ·
[💾 Download the ready-made VM](https://drive.google.com/file/d/19JDeNlybMz2gbcl1vizZWhcYbH14ScEZ/view?usp=sharing) ·
[🧭 Start here: bit.ly/VMSnAI](https://bit.ly/VMSnAI) ·
[🖱 Interactive guide](docs/index.html)

</div>

---

## What you get

| Piece | Role |
|---|---|
| **Docker** | Runs the web interface in a container |
| **Ollama** | Downloads and runs LLMs locally (no cloud, no API keys) |
| **Open WebUI** | A ChatGPT-style browser interface for your local models |
| **Models** | `deepseek-r1:1.5b`, `smollm2:1.7b`, `mistral` (starter set), plus any model from the [Ollama library](https://ollama.com/library) |

## Three ways to start

### 1. Use the ready-made VM (fastest)
Download the VM from [Google Drive](https://drive.google.com/file/d/19JDeNlybMz2gbcl1vizZWhcYbH14ScEZ/view?usp=sharing), import it into VirtualBox/VMware, boot it, then follow the [video](https://www.youtube.com/watch?v=FH99iG9lA8A&t=12s). Docker, Ollama and the models are pre-installed. Find the VM's IP with `hostname -I` and browse to `http://<VM-IP>:8080/`.

### 2. Interactive installer (on your own RHEL-family machine)
```bash
git clone https://github.com/YOUR-USERNAME/ollama-launchpad.git
cd ollama-launchpad
./install.sh            # menu-driven
# or unattended-ish:
./install.sh --all
```

### 3. Docker Compose (if Docker and Ollama are already installed)
```bash
cp .env.example .env
./scripts/02-install-ollama.sh --expose   # let the container reach Ollama
docker compose up -d
# UI: http://localhost:3000
```
No Ollama on the host? Run it in a container too: `docker compose --profile bundled up -d` (set `OLLAMA_BASE_URL=http://ollama:11434` in `.env`).

## Requirements

- RHEL-family Linux (Rocky, AlmaLinux, CentOS Stream, RHEL, Fedora) with `dnf`
- 4 GB RAM minimum for the small models, 8 GB+ recommended for `mistral`
- 10+ GB free disk, internet access
- sudo rights

Ubuntu/Debian? See [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md#debian--ubuntu).

## Two UI modes

| | **host** (default) | **bridge** |
|---|---|---|
| Port | 8080 | 3000 |
| Docker flag | `--network=host` | `-p 3000:8080` |
| Ollama URL | `http://127.0.0.1:11434` | `http://host.docker.internal:11434` |
| Needs Ollama exposed? | No | Yes (`--expose`) |
| Isolation | Lower | Higher |

```bash
./scripts/04-run-open-webui.sh host      # http://<VM-IP>:8080
./scripts/04-run-open-webui.sh bridge    # http://<VM-IP>:3000
```
The first account you register in Open WebUI becomes the admin.

## Manual commands (what the scripts do)

```bash
# Docker
sudo dnf install -y dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable --now docker
sudo usermod -aG docker $USER        # log out/in afterwards

# Ollama (needs tar + zstd)
sudo dnf install -y tar zstd
curl -fsSL https://ollama.com/install.sh | sh

# Models
ollama pull deepseek-r1:1.5b
ollama pull smollm2:1.7b
ollama pull mistral

# Open WebUI
docker run -d --network=host -v open-webui:/app/backend/data \
  -e OLLAMA_BASE_URL=http://127.0.0.1:11434 \
  --name open-webui --restart always ghcr.io/open-webui/open-webui:main

# Firewall
sudo firewall-cmd --permanent --add-port=8080/tcp --add-service=http && sudo firewall-cmd --reload
```

## Repository layout

```
ollama-launchpad/
├── install.sh              # interactive menu installer
├── scripts/                # modular, re-runnable steps (docker, ollama, models, webui, firewall, health, uninstall)
├── docker-compose.yml      # Open WebUI (+ optional bundled Ollama)
├── docs/
│   ├── index.html          # interactive guide + command generator (GitHub Pages ready)
│   ├── MODELS.md           # which model to pick
│   ├── SECURITY.md         # hardening notes
│   ├── TROUBLESHOOTING.md  # fixes for common errors
│   └── ORIGINAL-NOTES.txt  # the source notes this repo grew from
├── examples/               # Python chat client, curl calls, custom Modelfile
├── Makefile                # shortcuts: make install / health / lint
└── .github/                # CI, issue + PR templates
```

## Health check & cleanup
```bash
./scripts/healthcheck.sh
./scripts/99-uninstall.sh
```

## Publish the interactive guide
Push the repo, then **Settings → Pages → Deploy from branch → `main` / `/docs`**. The guide appears at `https://YOUR-USERNAME.github.io/ollama-launchpad/`.

## Contributing & license
See [CONTRIBUTING.md](CONTRIBUTING.md). Released under the [MIT License](LICENSE).
