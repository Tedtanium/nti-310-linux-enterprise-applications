#!/bin/bash

yum install python-pip -y
pip install virtualenv
pip install --upgrade pip
pip install django psycopg2

mkdir opt/myproject
cd /opt/myproject
virtualenv myprojectenv
cd myprojectenv
source myprojectenv/bin/activate

#vim myproject/settings.py
#Look into notes to find what to edit via sed (probably IP address info grepped with Gcloud API).
sed -i 's|'\''HOST'\'': '\'''\''|'\''HOST'\'': '\''"/ip.txt"'\''|g' /opt/myproject/myproject/settings.py
# ^ Currently BROKEN!
sed -i 's/'\''PORT'\'': '\'''\''/'\''PORT'\'': '\''5432'\''/g' /opt/myproject/myproject/settings.py

python manage.py migrate
echo "from django.contrib.auth.models import User; User.objects.create_superuser('admin', 'admin@example.com', 'pass')" | ./manage.py shell
