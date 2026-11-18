#!/usr/bin/env bash
# ============================================================================
#  File name   : docker.sh
#  Author      : Abdul Sattar <abdul.linuxdev@gmail.com>
#  Repository  : https://github.com/A4sa/dotforge.git
#  Description : Detect the Linux distribution and install Docker Engine
#                using the official method for that distro/version.
#
#  SUPPORTED DISTROS
#  -----------------
#    Ubuntu  22.04+ and derivatives (Linux Mint, Pop!_OS, elementary, ...)
#    Debian  11+ and derivatives
#    Fedora  (dnf4 and dnf5 — Fedora 41+)
#    Arch Linux and derivatives (Manjaro, EndeavourOS)
#
#  USAGE
#  -----
#    chmod +x docker.sh
#    ./docker.sh
#
#  WHAT THIS SCRIPT DOES
#  ---------------------
#    1. Detect distro and version from /etc/os-release
#    2. Verify the distro is supported
#    3. Install Docker Engine using the official Docker repository
#    4. Add the current user to the docker group (no sudo needed after)
#       NOTE: the docker group is root-equivalent on this machine.
#    5. Enable and start the Docker service
#    6. Verify the installation with 'docker run hello-world'
#
#  WHY NOT 'sudo apt install docker.io'?
#  --------------------------------------
#    docker.io is the Ubuntu-packaged version — often months behind.
#    This script installs from Docker's own APT/DNF/pacman repository,
#    which always gives you the latest stable Docker Engine.
#
# ============================================================================

set -euo pipefail

# ── Colors ────────────────────────────────────────────────────────────────────

RESET='\033[0m'
BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'

info()    { echo -e "${CYAN}[docker-install]${RESET} $*"; }
success() { echo -e "${GREEN}[docker-install]${RESET} $*"; }
warn()    { echo -e "${YELLOW}[docker-install]${RESET} $*"; }
error()   { echo -e "${RED}[docker-install] ERROR:${RESET} $*" >&2; exit 1; }
step()    { echo -e "\n${BOLD}── $* ${RESET}"; }


# ── Detect Linux distro ───────────────────────────────────────────────────────

detect_distro() {
    if [ ! -f /etc/os-release ]; then
        error "/etc/os-release not found. Cannot detect Linux distribution."
    fi

    # Source the file to get ID, VERSION_ID, VERSION_CODENAME
    # shellcheck disable=SC1091
    . /etc/os-release

    DISTRO_ID="${ID:-unknown}"
    DISTRO_VERSION="${VERSION_ID:-unknown}"
    DISTRO_CODENAME="${VERSION_CODENAME:-unknown}"
    DISTRO_NAME="${PRETTY_NAME:-unknown}"

    # Map derivatives onto the distro whose Docker repository they use.
    # Docker publishes repos for ubuntu/debian/fedora only, so Mint must use
    # 'ubuntu' with the Ubuntu codename it is based on (UBUNTU_CODENAME).
    DOCKER_DISTRO="$DISTRO_ID"
    case "$DISTRO_ID" in
        ubuntu|debian|fedora|arch) ;;
        *)
            case " ${ID_LIKE:-} " in
                *" ubuntu "*)
                    DOCKER_DISTRO=ubuntu
                    DISTRO_CODENAME="${UBUNTU_CODENAME:-$DISTRO_CODENAME}" ;;
                *" debian "*)
                    DOCKER_DISTRO=debian
                    DISTRO_CODENAME="${DEBIAN_CODENAME:-$DISTRO_CODENAME}" ;;
                *" fedora "*) DOCKER_DISTRO=fedora ;;
                *" arch "*)   DOCKER_DISTRO=arch ;;
            esac
            ;;
    esac

    case "$DOCKER_DISTRO" in
        ubuntu|debian|fedora|arch) ;;
        *)
            error "Unsupported distro: '${DISTRO_ID}' (${DISTRO_NAME})
Supported: Ubuntu, Debian, Fedora, Arch Linux (and their derivatives)
Manual install: https://docs.docker.com/engine/install/"
            ;;
    esac

    info "Detected: ${BOLD}${DISTRO_NAME}${RESET}"
    info "ID: ${DISTRO_ID}  |  Version: ${DISTRO_VERSION}  |  Codename: ${DISTRO_CODENAME}  |  Docker repo: ${DOCKER_DISTRO}"
}


# ── Check: already installed ──────────────────────────────────────────────────

check_already_installed() {
    if command -v docker &>/dev/null; then
        local version
        version=$(docker --version 2>/dev/null)
        warn "Docker is already installed: ${version}"
        read -rp "  Reinstall / upgrade? [y/N] " confirm
        [[ "$confirm" =~ ^[Yy]$ ]] || { info "Nothing changed. Exiting."; exit 0; }
    fi
}


# ── Check: running as root or with sudo ──────────────────────────────────────

check_sudo() {
    if [ "$EUID" -eq 0 ]; then
        warn "Running as root. Docker group step will be skipped."
        RUNNING_AS_ROOT=true
    else
        RUNNING_AS_ROOT=false
        info "Checking sudo access..."
        sudo -v || error "sudo access required. Run as a user with sudo privileges."
    fi
}


# ── Install: Ubuntu / Debian ──────────────────────────────────────────────────
#
# Method: Docker's official APT repository
# Docs:   https://docs.docker.com/engine/install/ubuntu/

install_ubuntu_debian() {
    step "Installing Docker on ${DISTRO_NAME}"

    # Remove old/conflicting packages
    info "Removing old Docker packages (if any)..."
    local old_pkgs=(
        docker.io docker-doc docker-compose docker-compose-v2
        podman-docker containerd runc
    )
    sudo apt-get remove -y "${old_pkgs[@]}" 2>/dev/null || true

    # Install prerequisites
    info "Installing prerequisites..."
    # WHY '|| warn': third-party repos on the machine (AnyDesk, Chrome, ...)
    # may have expired GPG keys, and apt-get update fails for ANY repo error,
    # which would kill this script via 'set -e'. We tolerate errors here,
    # then do a targeted update of Docker's repo, which must succeed.
    sudo apt-get update -qq || warn "apt-get update reported errors — continuing"
    sudo apt-get install -y --no-install-recommends \
        ca-certificates curl gnupg lsb-release

    # Add Docker's official GPG key
    info "Adding Docker GPG key..."
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL "https://download.docker.com/linux/${DOCKER_DISTRO}/gpg" \
        | sudo gpg --dearmor --yes -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    # A very new release may not have a Docker repository yet. Say so now,
    # instead of failing later with a confusing apt 404.
    if ! curl -fsI "https://download.docker.com/linux/${DOCKER_DISTRO}/dists/${DISTRO_CODENAME}/Release" >/dev/null; then
        error "Docker has no repository for ${DOCKER_DISTRO} '${DISTRO_CODENAME}' yet.
Check https://download.docker.com/linux/${DOCKER_DISTRO}/dists/ for supported releases."
    fi

    # Add Docker's APT repository
    info "Adding Docker APT repository..."
    echo \
        "deb [arch=$(dpkg --print-architecture) \
signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/${DOCKER_DISTRO} \
${DISTRO_CODENAME} stable" \
        | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Update only Docker's repo to verify it works — targeted, not global
    info "Refreshing Docker repository..."
    sudo apt-get update -qq \
        -o Dir::Etc::sourcelist="sources.list.d/docker.list" \
        -o Dir::Etc::sourceparts="-" \
        -o APT::Get::List-Cleanup="0"

    # Install Docker Engine
    info "Installing Docker Engine..."
    sudo apt-get install -y \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin
}


# ── Install: Fedora ───────────────────────────────────────────────────────────
#
# Method: Docker's official DNF repository
# Docs:   https://docs.docker.com/engine/install/fedora/

install_fedora() {
    step "Installing Docker on ${DISTRO_NAME}"

    # Remove old packages
    info "Removing old Docker packages (if any)..."
    sudo dnf remove -y docker docker-client docker-client-latest \
        docker-common docker-latest docker-latest-logrotate \
        docker-logrotate docker-selinux docker-engine-selinux \
        docker-engine 2>/dev/null || true

    # Add Docker's DNF repository
    info "Adding Docker DNF repository..."
    sudo dnf install -y dnf-plugins-core
    # dnf5 (Fedora 41+) changed the config-manager syntax.
    if dnf --version 2>/dev/null | grep -q '^dnf5'; then
        sudo dnf config-manager addrepo --overwrite \
            --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo
    else
        sudo dnf config-manager --add-repo \
            https://download.docker.com/linux/fedora/docker-ce.repo
    fi

    # Install Docker Engine
    info "Installing Docker Engine..."
    sudo dnf install -y \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin
}


# ── Install: Arch Linux ───────────────────────────────────────────────────────
#
# Method: Official Arch repos — no extra repository needed
# Note:   Arch ships a recent Docker version in the official repos.

install_arch() {
    step "Installing Docker on ${DISTRO_NAME}"

    # -Syu, never -Sy: a sync without upgrading is a partial upgrade, which
    # Arch does not support and can break shared libraries.
    info "Installing Docker via pacman..."
    sudo pacman -Syu --needed --noconfirm docker docker-compose docker-buildx
}


# ── Post-install: common steps for all distros ────────────────────────────────

post_install() {
    step "Post-install configuration"

    # Enable and start Docker service
    info "Enabling Docker service..."
    sudo systemctl enable --now docker

    # Add current user to docker group
    # WHY: Without this, every docker command needs sudo.
    #      After adding to the group, the user can run docker directly.
    # NOTE: Group membership takes effect on next login.
    #       Or run 'newgrp docker' immediately without re-login.
    if [ "$RUNNING_AS_ROOT" = false ]; then
        sudo groupadd -f docker
        info "Adding '${USER}' to the docker group..."
        sudo usermod -aG docker "${USER}"
        warn "Group change requires re-login to take effect."
        warn "Or run now: newgrp docker"
    fi

    # Verify installation
    step "Verifying installation"
    info "Running hello-world container..."
    if [ "$RUNNING_AS_ROOT" = true ]; then
        docker run --rm hello-world
    else
        sg docker -c "docker run --rm hello-world" 2>/dev/null || \
            sudo docker run --rm hello-world
    fi
}


# ── Print summary ─────────────────────────────────────────────────────────────

print_summary() {
    local docker_version
    docker_version=$(docker --version 2>/dev/null || echo "unknown")

    echo ""
    echo -e "${GREEN}${BOLD}============================================${RESET}"
    echo -e "${GREEN}${BOLD}  Docker installed successfully            ${RESET}"
    echo -e "${GREEN}${BOLD}============================================${RESET}"
    echo ""
    echo -e "  ${BOLD}Version :${RESET} ${docker_version}"
    echo -e "  ${BOLD}Distro  :${RESET} ${DISTRO_NAME}"
    echo ""
    echo -e "  ${BOLD}Next steps:${RESET}"
    if [ "$RUNNING_AS_ROOT" = false ]; then
    echo "    newgrp docker              # activate group now (no re-login)"
    fi
    echo "    docker --version           # confirm version"
    echo "    docker compose version     # confirm compose plugin"
    echo "    docker run hello-world     # smoke test"
    echo ""
    echo -e "  ${BOLD}Docs:${RESET} https://docs.docker.com/engine/install/"
    echo ""
}


# ── Main ──────────────────────────────────────────────────────────────────────

main() {
    echo ""
    echo -e "${BOLD}dotforge — Docker Engine Installer${RESET}"
    echo -e "────────────────────────────────────"
    echo ""

    detect_distro
    check_already_installed
    check_sudo

    # Route to the correct installer based on detected distro
    case "${DOCKER_DISTRO}" in
        ubuntu|debian)
            install_ubuntu_debian
            ;;
        fedora)
            install_fedora
            ;;
        arch)
            install_arch
            ;;
        *)
            error "Unsupported distro: '${DISTRO_ID}' (${DISTRO_NAME})
Supported: Ubuntu, Debian, Fedora, Arch Linux (and their derivatives)
Manual install: https://docs.docker.com/engine/install/"
            ;;
    esac

    post_install
    print_summary
}

main "$@"
