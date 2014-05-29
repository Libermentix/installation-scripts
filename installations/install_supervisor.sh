#!/bin/bash
APPNAME=$1
apt-get install --force-yes supervisor > /dev/null

echo "Building 001_${APPNAME}.conf"
cat > /etc/supervisor/conf.d/001_${APPNAME}.conf << EOF
[program:${APPNAME}]
command=/home/sites/virtualenvs/${APPNAME}/bin/gunicorn_start madeineuregio
user=sites
stdout_logfile=/home/sites/virtualenvs/${APPNAME}/logs/gunicorn_supervisor_stdout.log
stderr_logfile=/home/sites/virtualenvs/${APPNAME}/logs/gunicorn_supervisor_stderr.log
redirect_stdrr=true
autostart=true
autorestart=true
EOF

echo "Building 002_${APPNAME}_celery.conf"
cat > /etc/supervisor/conf.d/002_${APPNAME}_celery.conf << EOF
[program:celery_${APPNAME}]
; Set full path to celery program if using virtualenv
command=/home/sites/virtualenvs/${APPNAME}/bin/celery_start madeineuregio 

directory=/home/sites/apps/${APPNAME}
user=sites
numprocs=1
stdout_logfile=/home/sites/virtualenvs/${APPNAME}/logs/celery_worker_stdout.log
stderr_logfile=/home/sites/virtualenvs/${APPNAME}/logs/celery_worker_stderr.log
autostart=true
autorestart=true
startsecs=10

; Need to wait for currently executing tasks to finish at shutdown.
; Increase this if you have very long running tasks.
stopwaitsecs = 600

; When resorting to send SIGKILL to the program to terminate it
; send SIGKILL to its whole process group instead,
; taking care of its children as well.
killasgroup=true

; if rabbitmq is supervised, set its priority higher
; so it starts first
priority=998
EOF

echo "Building 003_${APPNAME}_beat.conf"
cat > /etc/supervisor/conf.d/003_${APPNAME}_beat.conf << EOF
[program:celerybeat_${APPNAME}]
; Set full path to celery program if using virtualenv
command=/home/sites/virtualenvs/${APPNAME}/bin/celerybeat_start madeineuregio

; remove the -A myapp argument if you are not using an app instance

directory=/home/sites/apps/${APPNAME}
user=sites
numprocs=1
stdout_logfile=/home/sites/virtualenvs/${APPNAME}/logs/celery_beat_stdout.log
stderr_logfile=/home/sites/virtualenvs/${APPNAME}/logs/celery_beat_sterr.log
autostart=true
autorestart=true
startsecs=10

; if rabbitmq is supervised, set its priority higher
; so it starts first
priority=999
EOF
