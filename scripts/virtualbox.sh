#!/bin/bash -eux


# Without libdbus virtualbox would not start automatically after compile
echo '>>>> Installing libdbus'
apt-get -y install --no-install-recommends libdbus-1-3

# The netboot installs the VirtualBox support (old) so we have to remove it
echo '>>>> Removing any old VirtualBox modules'
/etc/init.d/virtualbox-ose-guest-utils stop
rmmod vboxguest
apt-get -y purge virtualbox-ose-guest-x11 virtualbox-ose-guest-dkms virtualbox-ose-guest-utils

# TODO: we might want to install DKMS here, so upgrading the kernel is easier.
# However, I don't upgrade Vagrant machines, instead just blowing them away and
# re-installing them.
###apt-get -y install dkms

# Save the list of packages that we have installed now
dpkg --get-selections > /tmp/installed-packages.txt

# Install necessary packages for building
echo '>>>> Preparing for kernel module build'
apt-get -y install module-assistant
yes | DEBIAN_FRONTEND=noninteractive module-assistant prepare

# Install the VirtualBox guest additions
echo '>>>> Installing VirtualBox guest additions'
VBOX_VERSION=$(cat /home/vagrant/.vbox_version)
VBOX_ISO=VBoxGuestAdditions_$VBOX_VERSION.iso
mount -o loop $VBOX_ISO /mnt
yes | sh /mnt/VBoxLinuxAdditions.run
umount /mnt

# Cleanup VirtualBox
rm $VBOX_ISO

# Cleanup packages that we installed for building.
echo '>>>> Cleaning up packages'
dpkg --get-selections > /tmp/new-packages.txt
diff --unchanged-line-format="" /tmp/installed-packages.txt /tmp/new-packages.txt | cut -f1 | xargs apt-get remove -y
