#! /usr/bin/env bash

emerge --ask \
    app-arch/unzip \
    app-arch/zip \
    app-editors/vim \
    app-admin/sudo \
    app-misc/tmux \
    dev-vcs/git \
    app-shells/bash-completion \
    sys-process/htop \
    net-analyzer/netcat \
    net-analyzer/nmap \
    app-text/dos2unix \
    app-portage/gentoolkit \
    dev-util/ctags
    # dev-lang/go

emerge --oneshot --ask \
    app-portage/cpuid2cpuflags


