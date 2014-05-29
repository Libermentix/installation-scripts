#!/bin/bash
USER=$1
VHOST=$2
PW=$3

source /home/sites/.profile

rabbitmqctl add_user ${USER} ${PW} \
  && rabbitmqctl add_vhost ${VHOST} \
  && rabbitmqctl set_permissions -p ${VHOST} ${USER} ".*" ".*" ".*"

echo "installing into ${WORKON_HOME}${VHOST}/bin/postactivate"
echo "#celery" >> ${WORKON_HOME}${VHOST}/bin/postactivate
echo "export AMQP_MESSAGE_BROKER_URL='amqp://${USER}:${PW}@localhost:5672/${VHOST}'" >> ${WORKON_HOME}${VHOST}/bin/postactivate 

echo "installing into ${WORKON_HOME}${VHOST}/bin/postdeactivate" 
echo "unset AMQP_MESSAGE_BROKER_URL" >> ${WORKON_HOME}${VHOST}/bin/postdeactivate

echo "copying celery_start into ${WORKON_HOME}${VHOST}/bin/ "
cp ~/bin_templates/celery_start ${WORKON_HOME}${VHOST}/bin/

echo "creating lib dir for celery..."
mkdir -p ${WORKON_HOME}${VHOST}/lib/celery/
mkdir -p ${WORKON_HOME}${VHOST}/run/celery/
echo "copying celerybeat_start into ${WORKON_HOME}{$VHOST}/bin/"
cp ~/bin_templates/celerybeat_start ${WORKON_HOME}{$VHOST}/bin/

echo "chowning the whole dir to sites:sites"
chown -Rf sites:sites /home/sites

echo "...done"

