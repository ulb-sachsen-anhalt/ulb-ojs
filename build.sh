#!/bin/bash

set -eu

if [ $# -eq 0 ]
  then
    echo "Please pass: 
            - root password for mysqldump, (e.g. *ojs*)
            - password SMTP (e.g. *arbitrary*)
            - docker-compose project-name  (*dev* or *prod*) "
fi


DB_PASS=$1
SMTP_PASS=$2
TARGET=$3

source .env

if  [ -z "$3" ] || ([ $3 != "dev" ] && [ $3 != "prod" ])
    then
        echo "Parameter 'dev' oder 'prod' fehlt"
        exit 0
elif [ $3 == "dev" ]
    then
        data_dir=${PROJECT_DATA_ROOT_DEV}
        echo "We are using ojs  Version: ${OJS_VERSION_ULB_PROD}"
        OJS_VERSION=${OJS_VERSION_ULB_PROD}
elif [ $3 == "prod" ]
    then
        data_dir=${PROJECT_DATA_ROOT_PROD}
        echo "We are using ojs  Version: ${OJS_VERSION_ULB_DEV}"
        OJS_VERSION=${OJS_VERSION_ULB_DEV}
fi

[ -d $data_dir ] && echo "Data Directory $data_dir exists!"


PHP_TAIL=/alpine/apache/php
OJS_GIT=https://github.com/pkp/docker-ojs.git

if [ -d "docker-ojs" ]; then
    echo "docker-ojs found"
else    
    git clone ${OJS_GIT} || echo "'${OJS_GIT}' just here"
fi


# place ojs.config.inc.php file
echo propagate new version of \"ojs.config.inc.php\"
cp -v ./resources/ojs.config.inc.php $data_dir/config/

if [ $3 == "prod" ]; then
    sed -i "s/mail_password/$SMTP_PASS/" $data_dir/config/ojs.config.inc.php
fi

# place Apache configuration file for VirtualHost 
cp -v ./resources/ojs$3.conf $data_dir/config/

OJS_HOME=$(find ./docker-ojs -type d -name ${OJS_VERSION})
OJS_HOME=$OJS_HOME$PHP_TAIL
if [ -z "$OJS_HOME$" ] ; then echo "**OJS Version $VERSION not found!**";
    else echo "Version '$OJS_VERSION' found --> $OJS_HOME"; fi

echo copy $OJS_HOME/Dockerfile .
cp -v $OJS_HOME/Dockerfile .
echo add mod_proxy to Dockerfile 
sed -i "s/ENV PACKAGES/ENV PACKAGES apache2-proxy/g" Dockerfile

echo copy $OJS_HOME/exclude.list .
cp -v $OJS_HOME/exclude.list .

echo copy $OJS_HOME/root .
cp -R $OJS_HOME/root .


# replace Host variable if in development build
if [ $3 == "dev" ]; then
    # cp -v ./resources/ompdev.conf $data_dir/config/
    echo "reconfigure config file with sed: ojs.config.inc.php"
    sed -i "s/ojsprod_db_ulb/ojsdev_db_ulb/" $data_dir/config/ojs.config.inc.php
    echo "copy and reconfigure develop compose file with sed: docker-compose-ojsdev-ulb.yml"
    cp -v ./docker-compose-ojsprod.yml ./docker-compose-ojsdev.yml
    echo "sed data in docker-compose-ojsdev.yml for develop server"
    sed -i "s/ojsprod/ojsdev/g" ./docker-compose-ojsdev.yml
    # do not expose any port
    sed -i "/ports:/d" ./docker-compose-ompdev.yml
    sed -i "/80:80/d" ./docker-compose-ompdev.yml
    sed -i "/443:443/d" ./docker-compose-ompdev.yml
    # sed -i "s/80:80/8080:80/" ./docker-compose-ojsdev.yml
    # sed -i "s/443:443/8443:443/" ./docker-compose-ojsdev.yml
    sed -i "s/OJS_VERSION_ULB_PROD/OJS_VERSION_ULB_DEV/" ./docker-compose-ojsdev.yml
fi

echo try start docker-compose with docker-compose-ojs$3.yml

compose_network=ojs

docker network inspect $compose_network >/dev/null 2>&1 || \
    docker network create $compose_network

./stop-ojs $3
./start-ojs $3

docker network connect $compose_network ojs$3_app_ulb

# copy uni favicon
docker cp ./resources/favicon.ico ojs$3_app_ulb:/var/www/html/favicon.ico


# backup database
if [ $3 == "prod" ]; then
    echo dump OJS database $data_dir/sqldumps/$(date +"%Y-%m-%d")_${OJS_VERSION}_ojs.sql
    backup=$data_dir/sqldumps/$(date +"%Y-%m-%d")_${OJS_VERSION}_ojs
    docker exec ojs$3_db_ulb mysqldump -p${DB_PASS} ojs > $backup && \
        echo "backup successfull:" $(du -h $backup) && mv "$backup" "$backup".sql || \
        if [ -f "$backup" ]; then 
            rm "$backup"
            echo "backup fails, delete empty dump"
        fi
fi