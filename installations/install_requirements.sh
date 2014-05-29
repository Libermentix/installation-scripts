#!/bin/bash
APPNAME=$1
source /etc/profile
workon ${APPNAME}
pip install -r ${WORKON_HOME}../apps/${APPNAME}/requirements/base.txt

