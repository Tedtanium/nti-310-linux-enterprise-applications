#!/bin/bash

yum install python-pip -y
pip install virtualenv
pip install --upgrade pip
pip install django psycopg2

mkdir /opt/myproject
virtualenv /opt/myproject/myprojectenv
source /opt/myproject/myprojectenv/bin/activate
django-admin.py startproject myproject /opt/myproject

#vim myproject/settings.py
#Look into notes to find what to edit via sed (probably IP address info grepped with Gcloud API).
#sed -i "s|'HOST': ''|'HOST': '${djangoip}'|g" /opt/myproject/myproject/settings.py
#sed -i 's/'\''PORT'\'': '\'''\''/'\''PORT'\'': '\''5432'\''/g' /opt/myproject/myproject/settings.py

mv /opt/myproject/myproject/settings.py /opt/myproject/myproject/settings.py.bak
wget https://raw.githubusercontent.com/Tedtanium/nti-310-linux-enterprise-applications/master/django-thing/settings.py --directory-prefix=/opt/myproject/myproject/settings.py
sed -i "s|'HOST': '1.2.3.4'|'HOST': '${djangoip}'|g" /opt/myproject/myproject/settings.py
#How is $djangoip transferred from the master server to here?

python manage.py migrate
echo "from django.contrib.auth.models import User; User.objects.create_superuser('admin', 'admin@example.com', 'pass')" | /opt/myproject/myproject/manage.py shell
