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

python manage.py migrate
echo "from django.contrib.auth.models import User; User.objects.create_superuser('admin', 'admin@example.com', 'pass')" | ./manage.py shell
