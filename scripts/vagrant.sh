#!/bin/bash -eux

# Installing vagrant keys
echo '>>>> Installing vagrant keys'
mkdir /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
cd /home/vagrant/.ssh
curl -L 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub' -o authorized_keys
chmod 600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant /home/vagrant/.ssh
chmod -R go-rwsx /home/vagrant/.ssh

# Install NFS for Vagrant
echo '>>>> Installing NFS'
apt-get -y update
apt-get -y install nfs-common
