#!/bin/bash

if [ -e /etc/ldap.conf ]; then exit 0; fi

export DEBIAN_FRONTEND=noninteractive
apt-get --yes install libpam-ldap nscd

echo -e "ldap-auth-config        ldap-auth-config/rootbindpw     password
ldap-auth-config        ldap-auth-config/bindpw password
ldap-auth-config        ldap-auth-config/override       boolean true
ldap-auth-config        ldap-auth-config/ldapns/base-dn string  dc=nti310,dc=local
ldap-auth-config        ldap-auth-config/ldapns/ldap_version    select  3
ldap-auth-config        ldap-auth-config/binddn string  cn=proxyuser,dc=example,dc=net
ldap-auth-config        ldap-auth-config/dbrootlogin    boolean false
ldap-auth-config        ldap-auth-config/pam_password   select  md5
ldap-auth-config        ldap-auth-config/rootbinddn     string  cn=manager,dc=example,dc=net
ldap-auth-config        ldap-auth-config/ldapns/ldap-server     string  ldap://LDAPIP
ldap-auth-config        ldap-auth-config/move-to-debconf        boolean true
ldap-auth-config        ldap-auth-config/dblogin        boolean false" > ldap_debconf

while read line; do echo "$line" | debconf-set-selections; done < ldap_debconf

sed -i 's/compat/compat ldap/g' /etc/nsswitch.conf

sed -i 's/PasswordAuthentication no/PasswordAuthentication Yes/g' /etc/ssh/sshd_config

/etc/init.d/nscd restart

export DEBIAN_FRONTEND=interactive

sed -i 's,uri ldapi:///,uri ldap://LDAPIP,g' /etc/ldap.conf
sed -i 's/base dc=example,dc=net/base dc=nti310,dc=local/g' /etc/ldap.conf
#To test: Go into the client and use [getent passwd | grep 500].

#NFS client starts here.

apt-get install nfs-client -y
yum install nfs-client -y
mkdir /mnt/test 
echo "NFSIP:/var/nfsshare/testing        /mnt/test       nfs     defaults 0 0" >> /etc/fstab
