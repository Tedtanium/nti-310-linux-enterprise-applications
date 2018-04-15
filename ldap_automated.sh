#!/bin/bash
yum install git -y
git clone https://github.com/nic-instruction/NTI-310.git

yum install -y openldap-servers openldap-clients

cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG
chown ldap. /var/lib/ldap/DB_CONFIG

systemctl enable slapd
systemctl start slapd

yum install httpd -y
yum install epel-release -y
yum install phpldapadmin -y

#SELinux statement. Allows an exception.
setsebool -P httpd_can_connect_ldap on

sed -i 's,Require local,#Require local\n   Require all granted,g' /etc/httpd/conf.d/phpldapadmin.conf

cp NTI-310/config/config.php /etc/phpldapadmin/config.php
chown ldap:apache /etc/phpldapadmin/config.php

systemctl restart httpd.service

echo "phpldapadmin is now up and running!"
echo "Preparing to take over the world..."

#Password generation.

newsecret=$)slappasswd -g)
newhash=$(slappasswd -s "$newsecret")
echo -n "$newsecret" > /root/ldap_admin_pass
chmod 0600 /root/ldap_admin_pass

echo "dn: olcDatabase={2}hdb,cn=config
changetype: modify
replace: olcSuffix
olcSuffix: dc=nti310,dc=local

dn: olcDatabase={2}hdb,cn=config
changetype: modify
replace: olcRootDN
olcRootDN: cn=ldapadm,dc=nti310,dc=local

dn: olcDatabase={2}hdb,cn=config
changetype: modify
replace: olcRootPW
olcRootPW: $newhash" >> db.ldif

$Auth restriction.

echo 'dn: olcDatabase={1}monitor,cn=config
changetype: modify
replace: olcAccess
olcAccess: {0}to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external, cn=auth" read by dn.base="cn=ldapadm,dc=nti310,dc=local" read by * none' > monitor.ldif

ldapmodify -Y EXTERNAL  -H ldapi:/// -f monitor.ldif

#Certgen.

openssl req -new -x509 -nodes -out /etc/openldap/certs/nti310ldapcert.pem -keyout /etc/openldap/certs/nti310ldapkey.pem -days 365 -subj "/C=US/ST=WA/L=Seattle/O=SCC/OU=IT/CN=nti310.local"

chown -R ldap. /etc/openldap/certs/nti*.pem

echo "dn: cn=config
changetype: modify
replace: olcTLSCertificateFile
olcTLSCertificateFile: /etc/openldap/certs/nti310ldapcert.pem
dn: cn=config
changetype: modify
replace: olcTLSCertificateKeyFile
olcTLSCertificateKeyFile: /etc/openldap/certs/nti310ldapkey.pem" > certs.ldif

ldapmodify -Y EXTERNAL  -H ldapi:/// -f certs.ldif

unalias cp


ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/nis.ldif 
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif

#Adds base group and people structure.

echo "dn: dc=nti310,dc=local
dc: nti310
objectClass: top
objectClass: domain
dn: cn=ldapadm ,dc=nti310,dc=local
objectClass: organizationalRole
cn: ldapadm
description: LDAP Manager
dn: ou=People,dc=nti310,dc=local
objectClass: organizationalUnit
ou: People
dn: ou=Group,dc=nti310,dc=local
objectClass: organizationalUnit
ou: Group" > base.ldif

ldapadd -x -W -D "cn=ldapadm,dc=nti310,dc=local" -f base.ldif -y /root/ldap_admin_pass
