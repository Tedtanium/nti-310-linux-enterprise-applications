#!/bin/bash

yum install epel-release -y
yum install nginx -y
yum install python34-devel gcc -y
curl -O https://bootstrap.pypa.io/get-pip.py
/usr/bin/python3.4 get-pip.py

#Gets Python ready to roll.
pip install virtualenv
mkdir -p /var/www && cd /var/www
virtualenv -p python3 p3venv


#Sets up virtual environment.
source p3venv/bin/activate
pip install uwsgi
pip install django

##### Echo statement ######
echo -e "upstream django {
	server unix:/run/uwsgi/apivndeveloper.sock;
}
# configuration of the server
server {
	listen		80;
	server_name 	api.vndeveloper.com;
	charset		utf-8;
	# max upload size
	client_max_body_size 75M;
	# Django media & static
	location /media  {
		alias /var/www/apivndeveloper/media;
	}
	location /static {
		alias /var/www/apivndeveloper/static;
	}
	# Finally, send all non-media requests to the Django server.
	location / {
		uwsgi_pass  django;
		include uwsgi_params;
		
		uwsgi_param Host $host;
		uwsgi_param X-Real-IP $remote_addr;
		uwsgi_param X-Forwarded-For $proxy_add_x_forwarded_for;
		uwsgi_param X-Forwarded-Proto $http_x_forwarded_proto;
	}
}" > /etc/nginx/conf.d/apivndeveloper.conf
######### End of echo statement ###############

systemctl start nginx

django-admin.py startproject /var/www/apivndeveloper

python manage.py runserver 0.0.0.0:8000
uwsgi --http :8000 --module apivndeveloper.wsgi

useradd -s /bin/false -r uwsgi

- mkdir -p /etc/uwsgi/vassals


######### Echo into ini file ###############
echo -e "[uwsgi]
# Django-related settings
# the base directory (full path)
chdir = /var/www/apivndeveloper
# Django's wsgi file
module =apivndeveloper.wsgi
# the virtualenv (full path)
home = /var/www/p3venv
# Logs
logdate = True
logto = /var/log/uwsgi/access.log
# process-related settings
# master
master = true
# maximum number of worker processes
processes = 5
# the socket (use the full path to be safe)
socket = /run/uwsgi/apivndeveloper.sock
# ... with appropriate permissions - may be needed
chmod-socket = 666
# clear environment on exit
vacuum = true" >> /var/www/apivndeveloper/apivndeveloper_uwsgi.ini

ln -s /var/www/apivndeveloper/apivndeveloper_uwsgi.ini /etc/uwsgi/vassals/

######### Emperor service echo statement ###############
echo -e "[Unit]
Description=uWSGI Emperor service
[Service]
ExecStartPre=/usr/bin/bash -c 'mkdir -p /run/uwsgi; chown uwsgi:nginx /run/uwsgi'
ExecStart=/var/www/p3venv/bin/uwsgi --emperor /etc/uwsgi/vassals
Restart=always
KillSignal=SIGQUIT
Type=notify
NotifyAccess=all
[Install]
WantedBy=multi-user.target" >> /etc/systemd/system/uwsgi.service
######### End of echo statements ###############


systemctl stop nginx
systemctl start uwsgi
systemctl start nginx
