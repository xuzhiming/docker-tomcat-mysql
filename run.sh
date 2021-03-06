#!/bin/bash

VOLUME_HOME="/var/lib/mysql"

if [[ ! -d $VOLUME_HOME/mysql ]]; then
    echo "=> An empty or uninitialized MySQL volume is detected in $VOLUME_HOME"
    echo "=> Installing MySQL ..."
    mysqld --initialize-insecure --user=mysql > /dev/null 2>&1
    echo "=> Done!"  
    /create_mysql_admin_user.sh
else
    echo "=> Using an existing volume of MySQL"
fi

if [[ `compgen -u | grep elsearch` == "elsearch" ]]; then
    echo 'User elsearch exist'
else
    groupadd elsearchg
    useradd elsearch -g elsearchg -p elasticsearch
    chown -R elsearch:elsearchg $ES_HOME 
    chown elsearch:elsearchg /start-es.sh
fi

su elsearch -c "$ES_HOME/bin/elasticsearch -d"
# $ES_HOME/bin/elasticsearch

exec supervisord -n
