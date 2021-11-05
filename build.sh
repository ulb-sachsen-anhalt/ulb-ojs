#!/bin/bash

set -eu

if [ $# -ne 3 ]
  then
    echo "Please pass PWD DB, PWD SMTP, TARGET={'dev', 'prod'} as args"
    exit 0
fi


DB_PASS=$1
SMTP_PASS=$2
TARGET=$3

source .env

if  [ -z "$TARGET" ] || ([ "$TARGET" != "dev" ] && [ "$TARGET" != "prod" ] && [ "$TARGET" != "local" ])
    then
        echo "Parameter 'dev' oder 'prod' oder 'local' fehlt"
        exit 0
elif [ "$TARGET" == "dev" ] || [ "$TARGET" == "local" ]
    then
        data_dir=${PROJECT_DATA_ROOT_DEV}
        echo "We are using ojs  Version: ${OJS_VERSION_ULB_PROD}"
        OJS_VERSION=${OJS_VERSION_ULB_PROD}
elif [ "$TARGET" == "prod" ]
    then
        data_dir=${PROJECT_DATA_ROOT_PROD}
        echo "We are using ojs  Version: ${OJS_VERSION_ULB_DEV}"
        OJS_VERSION=${OJS_VERSION_ULB_DEV}
fi

[ -d "$data_dir" ] && echo "Data Directory $data_dir exists!"


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

# copy custom ULB-theme to /data/plugins
cp -r ./plugins/ulb_theme $data_dir/plugins

# copy Search Results Highlight Plugin to /data/plugins
cp -r ./plugins/searchMark $data_dir/plugins

# pleased do: sudo chown 100:101 -R $data_dir/plugins


if [ "$TARGET" == "prod" ]; then
    sed -i "s/mail_password/$SMTP_PASS/" $data_dir/config/ojs.config.inc.php
fi

# place Apache configuration file for VirtualHost 
cp -v ./resources/ojs"$TARGET".conf $data_dir/config/

# copy our custom settings in php.custom.ini (increase memory_limit)
cp -v ./resources/php.ulb.ini $data_dir/config/

OJS_HOME=$(find ./docker-ojs -type d -name ${OJS_VERSION})
OJS_HOME=$OJS_HOME$PHP_TAIL
if [ -z "$OJS_HOME" ] ; then echo "**OJS Version $VERSION not found!**";
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
if [ $TARGET == "dev" ] || [ $TARGET == "local" ]; then
    # cp -v ./resources/ompdev.conf $data_dir/config/
    echo "reconfigure config file with sed: ojs.config.inc.php"
    sed -i "s/ojsprod_db_ulb/ojsdev_db_ulb/" "$data_dir"/config/ojs.config.inc.php
    sed -i "s/force_ssl/;force_ssl/" "$data_dir"/config/ojs.config.inc.php
    echo "copy and reconfigure develop compose file with sed: docker-compose-ojsdev-ulb.yml"
    cp -v ./docker-compose-ojsprod.yml ./docker-compose-ojsdev.yml
    echo "sed data in docker-compose-ojsdev.yml for develop server"
    sed -i "s/ojsprod/ojsdev/g" ./docker-compose-ojsdev.yml
    sed -i "s/OJS_VERSION_ULB_PROD/OJS_VERSION_ULB_DEV/" ./docker-compose-ojsdev.yml
    cp -v ./docker-compose-ojsdev.yml ./docker-compose-ojslocal.yml
    # do not expose any port in dev (but in devlocal keep Port:80)
    sed -i "/ports:/d" ./docker-compose-ojsdev.yml
    sed -i "/80:80/d" ./docker-compose-ojsdev.yml
    sed -i "/443:443/d" ./docker-compose-ojsdev.yml
    # for local development we don't need ssl  
    sed -i "/443:443/d" ./docker-compose-ojslocal.yml
    sed -i "/ssl/d" ./docker-compose-ojslocal.yml
fi

echo try start docker-compose with docker-compose-ojs"$TARGET".yml

compose_network=ojs

docker network inspect $compose_network >/dev/null 2>&1 || \
    docker network create $compose_network

./stop-ojs "$TARGET"
./start-ojs "$TARGET"

docker network connect $compose_network ojs"$TARGET"_app_ulb

# copy uni favicon
docker cp ./resources/favicon.ico ojs"$TARGET"_app_ulb:/var/www/html/favicon.ico


# backup database
if [ "$TARGET" == "prod" ]; then
    echo dump OJS database $data_dir/sqldumps/$(date +"%Y-%m-%d")_${OJS_VERSION}_ojs.sql
    backup=$data_dir/sqldumps/$(date +"%Y-%m-%d")_${OJS_VERSION}_ojs
    docker exec ojs"$TARGET"_db_ulb mysqldump -p${DB_PASS} ojs > $backup && \
        echo "backup successfull:" $(du -h "$backup") && mv "$backup" "$backup".sql || \
        if [ -f "$backup" ]; then 
            rm "$backup"
            echo "backup fails, delete empty dump"
        fi
fi