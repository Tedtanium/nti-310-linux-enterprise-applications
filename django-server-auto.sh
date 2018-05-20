#!/bin/bash

yum install python-pip -y
pip install virtualenv
pip install --upgrade pip
pip install django psycopg2
#Gcloud install statement goes here.

mkdir opt/myproject
cd /opt/myproject
virtualenv myprojectenv
cd myprojectenv
source myprojectenv/bin/activate

#vim myproject/myproject/settings.py
#Look into notes to find what to edit via sed (probably IP address info grepped with Gcloud API).

python manage.py migrate
echo "from django.contrib.auth.models import User; User.objects.create_superuser('admin', 'admin@example.com', 'pass')" | ./manage.py shell
