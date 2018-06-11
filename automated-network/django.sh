#!/bin/bash

if [ -e opt/myproject/myproject/settings.py ]; then exit 0; fi

yum install python-pip wget telnet -y
pip install virtualenv
pip install --upgrade pip
pip install django psycopg2

mkdir /opt/myproject
virtualenv /opt/myproject/myprojectenv
source /opt/myproject/myprojectenv/bin/activate
django-admin.py startproject myproject /opt/myproject

#vim myproject/settings.py
#Look into notes to find what to edit via sed (probably IP address info grepped with Gcloud API).
#sed -i "s|'HOST': ''|'HOST': 'POSTGRESIP'|g" /opt/myproject/myproject/settings.py
#sed -i 's/'\''PORT'\'': '\'''\''/'\''PORT'\'': '\''5432'\''/g' /opt/myproject/myproject/settings.py

mv /opt/myproject/myproject/settings.py /opt/myproject/myproject/settings.py.bak


source /opt/myproject/myprojectenv/bin/activate && pip install django psycopg2 && django-admin.py startproject myproject /opt/myproject/
mv /opt/myproject/myproject/settings.py /settings.py.bak

wget https://raw.githubusercontent.com/Tedtanium/nti-310-linux-enterprise-applications/master/django-thing/settings.py --directory-prefix=/opt/myproject/myproject/

postgresip=$(getent hosts postgres.c.nti-310-200201.internal | awk '{ print $1 }')

sed -i "s|'HOST': '1.2.3.4'|'HOST': '$postgresip'|g" /opt/myproject/myproject/settings.py
sed -i "s/ALLOWED_HOSTS = \[\]/ALLOWED_HOSTS =  \[\'"*"\'\]/g" /opt/myproject/myproject/settings.py
# ^ New.

echo "from django.contrib.auth.models import User; User.objects.create_superuser('admin', 'admin@example.com', 'pass')" | /opt/myproject/manage.py shell

source /opt/myproject/myprojectenv/bin/activate && python /opt/myproject/manage.py makemigrations && python /opt/myproject/manage.py migrate && python /opt/myproject/manage.py runserver 0.0.0.0:8000
