#!/bin/bash

set -eu

DB_PASS=$1

source .env

echo We are using OJS  Version ${OJS_VERSION}  data in: ${PROJECT_DATA_ROOT}
PHP_TAIL=/alpine/apache/php
OJS_GIT=https://github.com/pkp/docker-ojs.git


git clone ${OJS_GIT} || echo "'${OJS_GIT}' just here"


cp -v ojs.config.inc.php ${PROJECT_DATA_ROOT}/volumes/config/


OJS_HOME=$(find ./docker-ojs -type d -name ${OJS_VERSION})
OJS_HOME=$OJS_HOME$PHP_TAIL
if [ -z "$OJS_HOME$" ] ; then echo "**OJS Version $VERSION not found!**";
    else echo "Version '$OJS_VERSION' found --> $OJS_HOME"; fi

echo copy $OJS_HOME/Dockerfile .
cp -v $OJS_HOME/Dockerfile .

echo copy $OJS_HOME/exclude.list .
cp -v $OJS_HOME/exclude.list .

echo copy $OJS_HOME/root .
cp -R $OJS_HOME/root .

echo try start docker-compose with docker-compose-ulb.yml
#start OJS

docker-compose --file ./docker-compose-ulb.yml down

docker-compose --file ./docker-compose-ulb.yml up -d

# copy uni favicon
docker cp favicon.ico ojs_app_ulb:/var/www/html/favicon.ico

echo dump OJS database ${PROJECT_DATA_ROOT}/volumes/sqldumps/$(date +"%Y-%m-%d")_${OJS_VERSION}_ojs.sql

backup=${PROJECT_DATA_ROOT}/volumes/sqldumps/$(date +"%Y-%m-%d")_${OJS_VERSION}_ojs.sql
docker exec ojs_db_ulb mysqldump -p${DB_PASS} ojs > $backup  && echo "backup successfull" || rm ${backup}

# wieder einspielen, falls notwendig
# sudo cat YYYY-MM-DD_ojs.sql | sudo docker exec -i ojs_db_ulb mysql -pPWD ojs
