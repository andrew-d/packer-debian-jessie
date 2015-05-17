#!/bin/bash -eux

# Clean up
echo '>>>> Removing unnecessary packages'
apt-get -y remove linux-headers-$(uname -r) build-essential
apt-get -y purge $(dpkg --list |grep '^rc' |awk '{print $2}')

echo '>>>> Autoremoving and cleaning apt'
apt-get -y autoremove
apt-get -y clean
apt-get -y autoclean

# TODO: what does this do?
#apt-get -y purge $(dpkg --list |egrep 'linux-image-[0-9]' |awk '{print $3,$2}' |sort -nr |tail -n +2 |grep -v $(uname -r) |awk '{ print $2}')

# Cleanup Virtualbox
echo '>>>> Removing VirtualBox ISOs'
rm -rf VBoxGuestAdditions_*.iso VBoxGuestAdditions_*.iso.?

# Removing leftover leases and persistent rules
echo '>>>> Cleaning up DHCP leases'
rm /var/lib/dhcp/*

# Make sure Udev doesn't block our network
echo '>>>> Fixing udev'
mkdir /etc/udev/rules.d/70-persistent-net.rules
rm /lib/udev/rules.d/75-persistent-net-generator.rules
rm -rf /dev/.udev/ /var/lib/dhcp3/*
echo "pre-up sleep 2" >> /etc/network/interfaces

echo '>>>> Adding a 2 sec delay to the interface up, to make dhclient happy'
echo "pre-up sleep 2" >> /etc/network/interfaces

echo '>>>> Removing unused locales'
DEBIAN_FRONTEND=noninteractive apt-get -y install localepurge
sed -i -e 's|^USE_DPKG|#USE_DPKG|' /etc/locale.nopurge
localepurge
apt-get -y purge localepurge

# Zero out the free space to save space in the final image, blocking 'til
# written otherwise, the disk image won't be zeroed, and/or Packer will try to
# kill the box while the disk is still full and that's bad.  The dd will run
# 'til failure, so (due to the 'set -e' above), ignore that failure.  Also,
# really make certain that both the zeros and the file removal really sync; the
# extra sleep 1 and sync shouldn't be necessary, but...)
echo '>>>> Zeroing device to make space...'
dd if=/dev/zero of=/EMPTY bs=1M || true; sync; sleep 1; sync
rm -f /EMPTY; sync; sleep 1; sync

echo '>>>> Done'
