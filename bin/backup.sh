#! /bin/bash

rm -rf var/cache/*
tar --exclude='var/lib/libvirt/images' \
    --exclude='usr/src' \
    --exclude='tmp/*' \
    --exclude='var/db/repos' \
    --exclude='var/db/pkg' \
    -cvf $(cat etc/hostname)-rootfs-$(date +%Y%m%d).tar \
    bin boot dev etc lib lib64 media mnt opt proc root run sbin swapfile sys tmp usr var
