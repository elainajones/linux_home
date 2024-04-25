#! /bin/bash
#
# I reference the Gentoo chroot wiki for this 
# far too often and typing it out is a hassle.

# Mount host system dirs to chroot.
mount --rbind /dev /mnt/chroot/dev
mount --make-rslave /mnt/chroot/dev
mount -t proc /proc /mnt/chroot/proc
mount --rbind /sys /mnt/chroot/sys
mount --make-rslave /mnt/chroot/sys
mount --rbind /tmp /mnt/chroot/tmp
mount --bind /run /mnt/chroot/run

cp --dereference /etc/resolv.conf /mnt/chroot/etc
