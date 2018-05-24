#!/bin/bash

if [ -e /django-server-auto.sh ]; then exit 0; fi


############# GCLOUDAPI ###################
#Gets GCloud ready to go.
gcloud init
1
nti-310-200201


################# GIT ####################
#Pulls down repository.
yum install git -y
git clone https://github.com/Tedtanium/nti-310-linux-enterprise-applications.git


################ LDAP #####################
#Target file: automated-network/ldap-server
#A variable will be collected: $LDAPIP

#Execution line.
gcloud compute instances create ldap-server	--metadata-from-file startup-script=nti-310-linux-enterprise-applications/automated-network/ldap-server.sh --image-family centos-7 --tags http-server --zone us-east1-b --machine-type f1-micro 	--scopes cloud-platform 
# ^ Needs a few things: Paths to file, type of instance (need to make it a micro), firewall rules.

LDAP=$(getent hosts ldap-server.c.nti-310-200201.internal | awk '{ print $1 }')





################ NFS ######################
#Secondly, the NFS server needs to be made.
#Target file: automated-network/nfs-server
#A variable will be needed: $LDAPIP
#A variable will be collected: $NFSIP

#sed line - should replace all instances of LDAPIP with $LDAPIP.

#Execution line.

NFS=$(getent hosts nfs-server.c.nti-310-200201.internal | awk '{ print $1 }')




############## CLIENT #####################
#Third comes the LDAP/NFS client.
#Target file: automated-network/client
#Variables needed: $LDAPIP, $NFSIP


#Note to self: Debconf MUST be integrated into client install! Made independently of the LDAP server.
#sed line - should replace all instances of LDAPIP with $LDAPIP.
#sed line - should replace all instances of NFSIP with $NFSIP.

#Execution line.


############ POSTGRES ####################
#Fourth is a Postgres server.
#Target file: automated-network/postgres
#A variable will be collected: $POSTGRESIP

#Execution line.

POSTGRESIP=$(getent hosts postgres.c.nti-310-200201.internal | awk '{ print $1 }')


########### DJANGO ######################
#Fifth and finally, a Django server.
#Target file: automated-network/django
#A variable will be needed: $POSTGRESIP

#Additional edits will have to be made to this script (settings.py cannot rely on external file).
#sed line - should replace all instances of POSTGRESIP with $POSTGRESIP.

#Execution line.
