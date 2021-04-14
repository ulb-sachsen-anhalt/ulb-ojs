#!/bin/bash

set -eu

DB_NAME=$1
DB_USER=$2
DB_PASS=$3

echo start with DB: $DB_NAME, $DB_USER, DB_PASS

source .env

echo We are using OJS  Version:${OJS_VERSION} 
PHP_TAIL=/alpine/apache/php
OJS_GIT=https://github.com/pkp/docker-ojs.git


git clone ${OJS_GIT} || echo "'${OJS_GIT}' just here"


mkdir -pv /home/ojs/volumes/config && cp ojs.config.inc.php /home/ojs/volumes/config/

OJS_HOME=$(find ./docker-ojs -type d -name ${OJS_VERSION})
OJS_HOME=$OJS_HOME$PHP_TAIL
if [ -z "$OJS_HOME$" ] ; then echo "**OJS Version $VERSION not found!**";
    else echo "Version '$OJS_VERSION' found --> $OJS_HOME"; fi

echo copy $OJS_HOME/Dockerfile .
cp $OJS_HOME/Dockerfile .

echo copy $OJS_HOME/exclude.list
cp $OJS_HOME/exclude.list .


echo try start docker-compose with docker-compose-ulb.yml
#start OJS

docker-compose --file ./docker-compose-ulb.yml down

docker-compose --file ./docker-compose-ulb.yml up -d