#! /usr/bin/env bash

declare base=(
    # Network sharing
    "net-fs/cifs-utils"
    # Archive tools
    "app-arch/unzip"
    "app-arch/zip"
    # Developer tools
    "app-editors/vim"
    "dev-vcs/git"
    "app-text/dos2unix"
    "dev-util/ctags" # ctags needed for jump to definition in vim
    # dev-lang/go
    # Networking
    "net-analyzer/netcat"
    "net-analyzer/arp-scan"
    "net-analyzer/nmap"
    # System/Admin tools
    "app-misc/tmux"
    "sys-process/htop"
    "sys-apps/pciutils"
    "sys-apps/usbutils"
    "app-portage/gentoolkit" # 'equery uses <package>' to see available use flags
    # Bash tools
    "app-admin/sudo"
    "app-shells/bash-completion"
)

declare desktop=(
    # Fonts
    "media-fonts/noto-emoji"
    "media-fonts/noto"
    "media-fonts/fontawesome"
    "media-fonts/liberation-fonts"
    "media-fonts/dejavu"
)

emerge --ask ${base[@]}

emerge --oneshot --ask \
    app-portage/cpuid2cpuflags
