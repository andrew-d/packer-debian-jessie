#!/bin/bash -eux

echo ''
echo '>>>> Updating apt'
apt-get -y update
apt-get -y install ca-certificates curl

echo '>>>> Setting up sudo'
grep -q 'secure_path' /etc/sudoers || sed -i -e '/Defaults\s\+env_reset/a Defaults\tsecure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"' /etc/sudoers
sed -i -e 's/^%sudo.*/%sudo ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers

echo '>>>> Adding "vagrant" user to suoders'
( cat <<'EOP'
vagrant ALL=(ALL) NOPASSWD: ALL
EOP
) > /tmp/vagrant
chmod 0440 /tmp/vagrant
mv /tmp/vagrant /etc/sudoers.d/

# Tweak sshd to prevent DNS resolution (speed up logins)
echo '>>>> Tweaking sshd'
echo "UseDNS no" >> /etc/ssh/sshd_config
echo "GSSAPIAuthentication no" >> /etc/ssh/sshd_config

# Remove 5s grub timeout to speed up booting
echo '>>>> Removing grub timeout'
cat <<EOF > /etc/default/grub
# If you change this file, run 'update-grub' afterwards to update
# /boot/grub/grub.cfg.

GRUB_DEFAULT=0
GRUB_TIMEOUT=0
GRUB_DISTRIBUTOR=`lsb_release -i -s 2> /dev/null || echo Debian`
GRUB_CMDLINE_LINUX_DEFAULT="quiet"
GRUB_CMDLINE_LINUX="debian-installer=en_US"
EOF

update-grub

echo '>>>> Setting MOTD'
echo 'Welcome to your Vagrant-built virtual machine!' > /etc/motd
