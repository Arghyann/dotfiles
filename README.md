# Dotfiles & System Setup

Personal configuration, theming, and installation scripts for Arch Linux (Hyprland Wayland environment).

## 🚀 Fresh Installation Guide

On a fresh Arch Linux (or Arch-based distribution like Omarchy, EndeavourOS, CachyOS):

```bash
# 1. Clone the repository
git clone https://github.com/Arghyann/dotfiles.git ~/Projects/dotfiles
cd ~/Projects/dotfiles

# 2. Run the installer interactively
./install.sh

# Or run full unattended setup
./install.sh --all

# Or preview actions without installing
./install.sh --dry-run --all
```

### Modular Options
- `./install.sh --cli`: Core terminal utilities (zsh, fzf, ripgrep, bat, eza, starship, tmux, etc.)
- `./install.sh --desktop`: Hyprland, Wayland ecosystem, fonts, audio (PipeWire), SDDM
- `./install.sh --dev`: Compilers, Docker, Kubernetes, Cloud CLIs, Neovim, Mise
- `./install.sh --apps`: Daily GUI apps (Browsers, Obsidian, Typora, LibreOffice, Media)
- `./install.sh --aur`: AUR packages (Brave, Google Chrome, VS Code, Spotify, LocalSend)
- `./install.sh --intel`: Intel CPU/GPU drivers, microcode, thermald
- `./install.sh --services`: Enable essential systemd services (NetworkManager, Bluetooth, Tailscale, UFW)
- `./install.sh --shell`: Configure Zsh, Oh My Zsh, and plugins (`fzf-tab`, `autosuggestions`, `syntax-highlighting`)
- `./install.sh --mise`: Configure and install developer runtimes (`node`, `gh`, `codex`, `gemini`)

---

## 📦 Package Structure

Packages are modularized under the `packages/` directory:
- [`packages/core-cli.txt`](packages/core-cli.txt) – Base command-line utilities and shell tools
- [`packages/desktop-hyprland.txt`](packages/desktop-hyprland.txt) – Hyprland compositor, audio stack, display manager, fonts
- [`packages/development.txt`](packages/development.txt) – Development languages, container engines, cloud CLIs, editors
- [`packages/apps-gui.txt`](packages/apps-gui.txt) – Native official repository desktop applications
- [`packages/aur.txt`](packages/aur.txt) – AUR applications and binaries
- [`packages/intel-hardware.txt`](packages/intel-hardware.txt) – Intel 12th Gen / IdeaPad drivers and power management
- [`packages/omarchy.txt`](packages/omarchy.txt) – Omarchy ecosystem utilities and packages

---

## 🔧 Helper Scripts (`bin/`)

- `battery-conservation`: Battery conservation mode manager for Lenovo laptops (caps charge at 80% to prolong battery life).
  ```bash
  battery-conservation on    # Cap charge at 80%
  battery-conservation off   # Allow 100% charge
  battery-conservation status
  ```
- `sync-nightlight`: Self-healing Hyprsunset screen temperature sync based on time of day.
- `taildrop-receive` (aliased as `omarchy-tailscale-receive`): Background daemon that automatically receives Tailscale Taildrop files into a safe staging directory, atomically moves them to `~/Downloads` without collisions, and sends a desktop notification. Managed via user systemd service:
  ```bash
  systemctl --user status taildrop-receive.service
  ```
