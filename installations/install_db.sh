#!/bin/bash
APPNAME=$1
USER=$2
DBNAME=$3
PW=$4

source /etc/profile

SQL_USER_CREATE="CREATE USER ${USER} WITH PASSWORD '${PW}';"
SQL_DB_CREATE="CREATE DATABASE ${DBNAME} with OWNER=${USER};"

echo "creating user and database..."
su - postgres -c "psql -d postgres -c \"${SQL_USER_CREATE}\""
su - postgres -c "psql -d postgres -c \"${SQL_DB_CREATE}\""

echo "writing to postactivate config ...."
echo "export DB_ENGINE='django.db.backends.postgresql_psycopg2'" >> ${WORKON_HOME}${APPNAME}/bin/postactivate
echo "export DB_NAME='${DBNAME}'" >> ${WORKON_HOME}${APPNAME}/bin/postactivate
echo "export DB_PW='${PW}'" >> ${WORKON_HOME}${APPNAME}/bin/postactivate
echo "export DB_USER='${USER}'" >> ${WORKON_HOME}${APPNAME}/bin/postactivate
echo "export DB_HOST='localhost'" >> ${WORKON_HOME}${APPNAME}/bin/postactivate
echo "export DB_PORT=''" >> ${WORKON_HOME}${APPNAME}/bin/postactivate

echo "writing to postdeactivate config ..."
echo "unset DB_ENGINE" >> ${WORKON_HOME}${APPNAME}/bin/postdeactivate
echo "unset DB_NAME" >> ${WORKON_HOME}${APPNAME}/bin/postdeactivate
echo "unset DB_PW" >> ${WORKON_HOME}${APPNAME}/bin/postdeactivate
echo "unset DB_USER" >> ${WORKON_HOME}${APPNAME}/bin/postdeactivate
echo "unset DB_HOST" >> ${WORKON_HOME}${APPNAME}/bin/postdeactivate
echo "unset DB_PORT" >> ${WORKON_HOME}${APPNAME}/bin/postdeactivate

echo "...done"
