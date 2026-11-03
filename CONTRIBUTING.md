# Contributing

Thanks for helping! Quick rules:

1. Fork, create a branch (`feat/ubuntu-support`), open a pull request.
2. Run `make lint` (ShellCheck) before committing; CI runs it too.
3. Keep scripts idempotent: safe to run twice.
4. Test on a clean RHEL-family VM when changing install logic.
5. Update `README.md`, `CHANGELOG.md` and the interactive guide (`docs/index.html`) when behaviour changes.

Ideas welcome: Debian/Ubuntu scripts, GPU setup guide, Ansible playbook, more model profiles.
