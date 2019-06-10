#!/bin/bash

NAME="DjangoBlog"
DJANGODIR=/data/codes/DjangoBlog
SOCKFILE=/var/run/gunicorn.sock 
USER=root
GROUP=root
NUM_WORKERS=2
DJANGO_SETTINGS_MODULE=DjangoBlog.settings
DJANGO_WSGI_MODULE=DjangoBlog.wsgi

echo "Starting $NAME as `whoami`"

# Activate the virtual environment
cd $DJANGODIR
export PYTHONPATH=$DJANGODIR:$PYTHONPATH

# Create the run directory if it doesn't exist
RUNDIR=$(dirname $SOCKFILE)
test -d $RUNDIR || mkdir -p $RUNDIR

# Start your Django Unicorn
# Programs meant to be run under supervisor should not daemonize themselves (do not use --daemon)
#gunicorn目录(刚刚创建的虚拟环境的bin目录中)
exec /usr/local/bin/gunicorn  ${DJANGO_WSGI_MODULE}:application \
--name $NAME \
--workers $NUM_WORKERS \
--user=$USER --group=$GROUP \
--bind=unix:$SOCKFILE \
--log-level=warn
