#!/bin/bash


export DEBIAN_FRONTEND=noninteractive
apt-get --yes install libpam-ldap nscd
wget https://raw.githubusercontent.com/Tedtanium/nti-310-linux-enterprise-applications/master/ldap_debconf

while read line; do echo "$line" | debconf-set-selections; done < ldap_debconf

apt-get install -y libpam-ldap nscd

sed -i 's/compat/compat ldap/g' /etc/nsswitch.conf

/etc/init.d/nscd restart

sed -i 's/PasswordAuthentication no/PasswordAuthentication Yes/g' /etc/ssh/sshd_config

/etc/init.d/ssh restart

export DEBIAN_FRONTEND=interactive

#Just in case.
#sed -i 's,uri ldapi:///,uri ldap://10.142.0.2,g' /etc/ldap.conf
#sed -i 's/base dc=example,dc=net/base dc=nti310,dc=local/g' /etc/ldap.conf
#To test: Go into the client and use [getent passwd | grep thetrashman].
