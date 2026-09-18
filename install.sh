#!/usr/bin/env bash
# ==============================================================================
# Arch Linux Application & System Setup Script
# Configured for: Aryan (Dotfiles & System Recreation)
# Compatible with: Vanilla Arch, EndeavourOS, CachyOS, Omarchy
# ==============================================================================

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES_DIR="${SCRIPT_DIR}/packages"

# Colors for terminal output
BOLD="\033[1m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
CYAN="\033[0;36m"
NC="\033[0m" # No Color

log_info()    { echo -e "${BLUE}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[OK]${NC} $*"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $*"; }
log_step()    { echo -e "\n${BOLD}${CYAN}==> $*${NC}"; }

# Check not running as root directly
if [[ $EUID -eq 0 ]]; then
    log_error "Please do not run this script as root or with sudo directly."
    log_error "The script will prompt for sudo credentials when required."
    exit 1
fi

DRY_RUN=false
INSTALL_CLI=false
INSTALL_DESKTOP=false
INSTALL_DEV=false
INSTALL_APPS=false
INSTALL_AUR=false
INSTALL_INTEL=false
INSTALL_OMARCHY=false
SETUP_SERVICES=false
SETUP_SHELL=false
SETUP_DOTFILES=false
SETUP_MISE=false

print_usage() {
    cat <<EOF
${BOLD}Usage:${NC} $(basename "$0") [OPTIONS]

${BOLD}Options:${NC}
  --all            Install everything (CLI, Desktop, Dev, Apps, AUR, Intel, Services, Shell, Mise)
  --cli            Install base CLI utilities and shell essentials
  --desktop        Install Hyprland, Wayland ecosystem, fonts, and audio
  --dev            Install development runtimes, Docker, K8s, Cloud CLIs, Editors
  --apps           Install GUI daily-driver applications (official repos)
  --aur            Install AUR applications (Brave, Chrome, VS Code, Spotify, etc.)
  --intel          Install Intel CPU/GPU drivers & microcode
  --omarchy        Install Omarchy-specific packages & repo (optional)
  --services       Enable and start systemd services (NetworkManager, Bluetooth, etc.)
  --shell          Setup Zsh, Oh My Zsh, and plugins
  --mise           Setup Mise toolchain (Node, GitHub CLI, Codex, Gemini)
  --dotfiles       Symlink custom bin scripts and configs
  --dry-run        Print packages and planned actions without installing
  -h, --help       Show this help message

Running with no options will launch an interactive menu.
EOF
}

# Parse command-line arguments
if [[ $# -gt 0 ]]; then
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --all)
                INSTALL_CLI=true
                INSTALL_DESKTOP=true
                INSTALL_DEV=true
                INSTALL_APPS=true
                INSTALL_AUR=true
                INSTALL_INTEL=true
                SETUP_SERVICES=true
                SETUP_SHELL=true
                SETUP_DOTFILES=true
                SETUP_MISE=true
                shift
                ;;
            --cli)
                INSTALL_CLI=true; shift ;;
            --desktop)
                INSTALL_DESKTOP=true; shift ;;
            --dev)
                INSTALL_DEV=true; shift ;;
            --apps)
                INSTALL_APPS=true; shift ;;
            --aur)
                INSTALL_AUR=true; shift ;;
            --intel)
                INSTALL_INTEL=true; shift ;;
            --omarchy)
                INSTALL_OMARCHY=true; shift ;;
            --services)
                SETUP_SERVICES=true; shift ;;
            --shell)
                SETUP_SHELL=true; shift ;;
            --mise)
                SETUP_MISE=true; shift ;;
            --dotfiles)
                SETUP_DOTFILES=true; shift ;;
            --dry-run)
                DRY_RUN=true; shift ;;
            -h|--help)
                print_usage; exit 0 ;;
            *)
                log_error "Unknown option: $1"
                print_usage
                exit 1
                ;;
        esac
    done
else
    # Interactive menu
    echo -e "${BOLD}${CYAN}"
    echo "========================================================"
    echo "     Arch Linux Application & Setup Installer           "
    echo "========================================================"
    echo -e "${NC}"
    echo "Select components to install / configure:"
    echo

    read -rp "Install All (complete recreation)? [y/N]: " ans_all
    if [[ "$ans_all" =~ ^[Yy]$ ]]; then
        INSTALL_CLI=true
        INSTALL_DESKTOP=true
        INSTALL_DEV=true
        INSTALL_APPS=true
        INSTALL_AUR=true
        INSTALL_INTEL=true
        SETUP_SERVICES=true
        SETUP_SHELL=true
        SETUP_DOTFILES=true
        SETUP_MISE=true
    else
        read -rp "1) Core CLI & Shell essentials? [Y/n]: " ans; [[ "$ans" =~ ^[Nn]$ ]] || INSTALL_CLI=true
        read -rp "2) Hyprland Desktop, Wayland, Audio & Fonts? [Y/n]: " ans; [[ "$ans" =~ ^[Nn]$ ]] || INSTALL_DESKTOP=true
        read -rp "3) Development Tools (Docker, K8s, Cloud, Editors)? [Y/n]: " ans; [[ "$ans" =~ ^[Nn]$ ]] || INSTALL_DEV=true
        read -rp "4) GUI Applications (Firefox, Obsidian, MPV, etc.)? [Y/n]: " ans; [[ "$ans" =~ ^[Nn]$ ]] || INSTALL_APPS=true
        read -rp "5) AUR Packages (Brave, Chrome, VS Code, Spotify, etc.)? [Y/n]: " ans; [[ "$ans" =~ ^[Nn]$ ]] || INSTALL_AUR=true
        read -rp "6) Intel Hardware Drivers & Power (IdeaPad / Intel GPU)? [Y/n]: " ans; [[ "$ans" =~ ^[Nn]$ ]] || INSTALL_INTEL=true
        read -rp "7) Omarchy Ecosystem Packages (optional)? [y/N]: " ans; [[ "$ans" =~ ^[Yy]$ ]] && INSTALL_OMARCHY=true
        read -rp "8) Enable System Services (NetworkManager, Tailscale, etc.)? [Y/n]: " ans; [[ "$ans" =~ ^[Nn]$ ]] || SETUP_SERVICES=true
        read -rp "9) Setup Zsh, Oh My Zsh, and plugins? [Y/n]: " ans; [[ "$ans" =~ ^[Nn]$ ]] || SETUP_SHELL=true
        read -rp "10) Setup Mise developer runtimes (Node, gh, etc.)? [Y/n]: " ans; [[ "$ans" =~ ^[Nn]$ ]] || SETUP_MISE=true
        read -rp "11) Link Dotfiles & helper scripts (~/.local/bin)? [Y/n]: " ans; [[ "$ans" =~ ^[Nn]$ ]] || SETUP_DOTFILES=true
    fi
fi

# Function to read package file, filtering comments and empty lines
read_packages() {
    local file="$1"
    if [[ -f "$file" ]]; then
        grep -E -v '^[[:space:]]*#' "$file" | grep -E -v '^[[:space:]]*$' || true
    fi
}

# Ensure AUR helper (yay or paru)
AUR_HELPER=""
check_aur_helper() {
    if command -v yay >/dev/null 2>&1; then
        AUR_HELPER="yay"
    elif command -v paru >/dev/null 2>&1; then
        AUR_HELPER="paru"
    else
        log_step "Installing AUR helper (yay)..."
        if $DRY_RUN; then
            log_info "[DRY-RUN] Would clone and build yay-bin from AUR."
            AUR_HELPER="yay"
            return
        fi

        sudo pacman -S --needed --noconfirm git base-devel
        local tmp_dir
        tmp_dir=$(mktemp -d)
        git clone https://aur.archlinux.org/yay-bin.git "$tmp_dir/yay-bin"
        (cd "$tmp_dir/yay-bin" && makepkg -si --noconfirm)
        rm -rf "$tmp_dir"
        AUR_HELPER="yay"
        log_success "yay installed successfully."
    fi
}

install_pkg_list() {
    local title="$1"
    local file="$2"

    if [[ ! -f "$file" ]]; then
        log_warn "Package file not found: $file"
        return
    fi

    local pkgs
    mapfile -t pkgs < <(read_packages "$file")

    if [[ ${#pkgs[@]} -eq 0 ]]; then
        return
    fi

    log_step "Installing ${title} (${#pkgs[@]} packages)..."

    if $DRY_RUN; then
        log_info "[DRY-RUN] Would install: ${pkgs[*]}"
        return
    fi

    $AUR_HELPER -S --needed --noconfirm "${pkgs[@]}"
    log_success "${title} installed."
}

# Verify network connectivity
log_info "Verifying internet connectivity..."
if ! ping -c 1 -W 3 archlinux.org >/dev/null 2>&1 && ! ping -c 1 -W 3 1.1.1.1 >/dev/null 2>&1; then
    log_error "No internet connection detected. Please connect to a network first."
    exit 1
fi
log_success "Internet connection is active."

# Ensure AUR helper is ready
check_aur_helper

# 1. Core CLI
if $INSTALL_CLI; then
    install_pkg_list "Core CLI & Utilities" "${PACKAGES_DIR}/core-cli.txt"
fi

# 2. Desktop & Hyprland
if $INSTALL_DESKTOP; then
    install_pkg_list "Hyprland Desktop & Wayland Ecosystem" "${PACKAGES_DIR}/desktop-hyprland.txt"
fi

# 3. Development
if $INSTALL_DEV; then
    install_pkg_list "Development Runtimes & Toolchain" "${PACKAGES_DIR}/development.txt"
fi

# 4. GUI Applications
if $INSTALL_APPS; then
    install_pkg_list "GUI Applications" "${PACKAGES_DIR}/apps-gui.txt"
fi

# 5. AUR Packages
if $INSTALL_AUR; then
    install_pkg_list "AUR Packages" "${PACKAGES_DIR}/aur.txt"
fi

# 6. Intel Hardware
if $INSTALL_INTEL; then
    install_pkg_list "Intel Hardware & Drivers" "${PACKAGES_DIR}/intel-hardware.txt"
fi

# 7. Omarchy Packages
if $INSTALL_OMARCHY; then
    install_pkg_list "Omarchy Ecosystem Packages" "${PACKAGES_DIR}/omarchy.txt"
fi

# 8. Setup Services
if $SETUP_SERVICES; then
    log_step "Configuring and enabling system services..."
    SERVICES=(
        NetworkManager.service
        bluetooth.service
        tailscaled.service
        ufw.service
        sddm.service
        power-profiles-daemon.service
        avahi-daemon.service
    )

    if $DRY_RUN; then
        log_info "[DRY-RUN] Would enable system services: ${SERVICES[*]}"
        log_info "[DRY-RUN] Would enable user services: pipewire, pipewire-pulse, wireplumber"
    else
        for s in "${SERVICES[@]}"; do
            if systemctl list-unit-files "$s" >/dev/null 2>&1; then
                sudo systemctl enable "$s" || log_warn "Failed to enable $s"
                sudo systemctl start "$s" 2>/dev/null || true
                log_success "Enabled: $s"
            fi
        done

        # User-level audio services
        systemctl --user enable --now pipewire pipewire-pulse wireplumber 2>/dev/null || true
        log_success "Enabled user audio services (PipeWire / WirePlumber)."
    fi
fi

# 9. Shell Setup (Oh My Zsh + Plugins)
if $SETUP_SHELL; then
    log_step "Setting up Zsh and Oh My Zsh..."
    if $DRY_RUN; then
        log_info "[DRY-RUN] Would install Oh My Zsh, plugins (fzf-tab, zsh-autosuggestions, zsh-syntax-highlighting), and set zsh as default."
    else
        # Change default shell to zsh if needed
        ZSH_PATH="$(which zsh 2>/dev/null || echo "/bin/zsh")"
        if [[ "$SHELL" != "$ZSH_PATH" ]]; then
            log_info "Setting default shell to $ZSH_PATH..."
            chsh -s "$ZSH_PATH" || log_warn "Could not change shell with chsh; run 'chsh -s $ZSH_PATH' manually."
        fi

        # Oh My Zsh
        if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
            log_info "Installing Oh My Zsh..."
            RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        fi

        ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
        # zsh-autosuggestions
        if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
            log_info "Installing zsh-autosuggestions..."
            git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
        fi

        # zsh-syntax-highlighting
        if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
            log_info "Installing zsh-syntax-highlighting..."
            git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
        fi

        # fzf-tab
        if [[ ! -d "$ZSH_CUSTOM/plugins/fzf-tab" ]]; then
            log_info "Installing fzf-tab..."
            git clone --depth=1 https://github.com/Aloxaf/fzf-tab "$ZSH_CUSTOM/plugins/fzf-tab"
        fi
        log_success "Shell and Oh My Zsh plugins configured."
    fi
fi

# 10. Mise Setup
if $SETUP_MISE; then
    log_step "Configuring Mise developer runtimes..."
    if $DRY_RUN; then
        log_info "[DRY-RUN] Would install Node.js, GitHub CLI, Codex, Gemini via Mise."
    else
        if command -v mise >/dev/null 2>&1; then
            mkdir -p "$HOME/.config/mise"
            if [[ ! -f "$HOME/.config/mise/config.toml" ]]; then
                cat <<'EOF' > "$HOME/.config/mise/config.toml"
[tools]
codex = "latest"
gemini = { version = "latest", allow_builds = ["@github/keytar", "node-pty"] }
gh = "latest"
node = "latest"

[settings.upgrade]
auto_prune = false
EOF
            fi
            mise install
            log_success "Mise tools installed."
        else
            log_warn "Mise command not found. Ensure 'mise' is installed first."
        fi
    fi
fi

# 11. Dotfiles and Custom Scripts
if $SETUP_DOTFILES; then
    log_step "Installing custom user scripts & configuring environment..."
    if $DRY_RUN; then
        log_info "[DRY-RUN] Would link scripts in ${SCRIPT_DIR}/bin to ~/.local/bin."
    else
        mkdir -p "$HOME/.local/bin"

        # Copy/Link helper scripts
        if [[ -d "${SCRIPT_DIR}/bin" ]]; then
            for script in "${SCRIPT_DIR}/bin"/*; do
                if [[ -f "$script" ]]; then
                    cp "$script" "$HOME/.local/bin/"
                    chmod +x "$HOME/.local/bin/$(basename "$script")"
                    log_success "Installed script: $(basename "$script") to ~/.local/bin"
                fi
            done
        fi

        # Lenovo battery conservation shortcut
        if [[ -f "$HOME/.local/bin/battery-conservation" ]]; then
            ln -sf "$HOME/.local/bin/battery-conservation" "$HOME/.local/bin/battery-limit"
        fi

        # Tailscale Taildrop user service setup
        if [[ -d "${SCRIPT_DIR}/systemd/user" ]]; then
            mkdir -p "$HOME/.config/systemd/user"
            cp "${SCRIPT_DIR}/systemd/user"/* "$HOME/.config/systemd/user/"
            systemctl --user daemon-reload 2>/dev/null || true
            if command -v tailscale >/dev/null 2>&1; then
                systemctl --user enable --now taildrop-receive.service 2>/dev/null || true
                log_success "Enabled Taildrop background receiver service."
            fi
        fi

        # Add user to docker group if docker is installed
        if command -v docker >/dev/null 2>&1; then
            sudo usermod -aG docker "$USER" 2>/dev/null || true
            log_success "Added $USER to docker group."
        fi

        # VS Code extensions install
        if command -v code >/dev/null 2>&1; then
            log_info "Installing VS Code extensions..."
            VS_EXTENSIONS=(
                vscodevim.vim
                catppuccin.catppuccin-vsc
                enkia.tokyo-night
                arcticicestudio.nord-visual-studio-code
                qufiwefefwoyn.kanagawa
                tahayvr.matteblack
                oldjobobo.retro-82-theme
                rikkarth.ship-at-sea
            )
            for ext in "${VS_EXTENSIONS[@]}"; do
                code --install-extension "$ext" --force >/dev/null 2>&1 || true
            done
            log_success "VS Code extensions installed."
        fi
    fi
fi

echo
log_step "Installation & Setup Complete! 🎉"
echo -e "You may need to log out and back in for group memberships (e.g. docker) and shell changes to take effect."
