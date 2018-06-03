#!/bin/bash


export DEBIAN_FRONTEND=noninteractive
apt-get --yes install libpam-ldap nscd
wget https://raw.githubusercontent.com/Tedtanium/nti-310-linux-enterprise-applications/master/ldap_debconf

while read line; do echo "$line" | debconf-set-selections; done < ldap_debconf

apt-get install -y libpam-ldap nscd

sed -i 's/compat/compat ldap/g' /etc/nsswitch.conf

sed -i 's/PasswordAuthentication no/PasswordAuthentication Yes/g' /etc/ssh/sshd_config

/etc/init.d/nscd restart

export DEBIAN_FRONTEND=interactive

#Just in case.
sed -i 's,uri ldapi:///,uri ldap://LDAPIP,g' /etc/ldap.conf
sed -i 's/base dc=example,dc=net/base dc=nti310,dc=local/g' /etc/ldap.conf
#To test: Go into the client and use [getent passwd | grep thetrashman].

#NFS client starts here.

apt-get install nfs-client -y
yum install nfs-client -y
mkdir /mnt/test 
echo "NFSIP:/var/nfsshare/testing        /mnt/test       nfs     defaults 0 0" >> /etc/fstab
# ^ Might cause issues; the IP may need to be escaped to be read in as a variable.
