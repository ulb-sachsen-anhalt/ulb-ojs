#!/bin/bash

set -e

if [ $# -ne 2 ]
  then
    echo "Please pass PWD SMTP, TARGET={'dev', 'prod'} as args"
    exit 0
fi


SMTP_PASS=$1
TARGET=$2

source .env

if  [ -z "$TARGET" ] || ([ "$TARGET" != "dev" ] && [ "$TARGET" != "prod" ])
    then
        echo "second parameter must be 'dev' or 'prod'"
        exit 0
elif [ "$TARGET" == "dev" ]
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

# copy Plugins to /data/plugins
echo "copy plugins -->" $(ls plugins)
cp -r ./plugins/* $data_dir/plugins


# pleased do: sudo chown 100:101 -R $data_dir/plugins


if [ "$TARGET" == "prod" ]; then
    sed -i "s/mail_password/$SMTP_PASS/" $data_dir/config/ojs.config.inc.php
fi

# place Apache configuration file for VirtualHost 
echo "copy resources -->" $(ls resources)
cp ./resources/*.conf $data_dir/config/

# copy our custom settings in php.custom.ini (increase memory_limit)
cp -v ./resources/php.ulb.ini $data_dir/config/

# copy favicon
cp -v ./resources/favicon.ico $data_dir/config/favicon.ico

OJS_HOME=$(find ./docker-ojs -type d -name ${OJS_VERSION})

if [ -z "$OJS_HOME" ] ; then 
         echo "**OJS Version $OJS_VERSION not found!**"; echo EXIT; exit 1;
    else echo "Version '$OJS_VERSION' found --> $OJS_HOME"; fi
OJS_HOME=$OJS_HOME$PHP_TAIL

echo copy $OJS_HOME/Dockerfile .
cp -v $OJS_HOME/Dockerfile .
echo add mod_proxy to Dockerfile 
sed -i "s/ENV PACKAGES/ENV PACKAGES apache2-proxy/g" Dockerfile

echo copy $OJS_HOME/exclude.list .
cp -v $OJS_HOME/exclude.list .

echo copy $OJS_HOME/root .
cp -R $OJS_HOME/root .


# replace Host variable if in development build
if [ $TARGET == "dev" ]; then
    # cp -v ./resources/ojsdev.conf $data_dir/config/
    echo "reconfigure config file with sed: $data_dir"/config/ojs.config.inc.php
    sed -i "s/ojsprod_db_ulb/ojsdev_db_ulb/" "$data_dir"/config/ojs.config.inc.php
    sed -i "s/force_login_ssl/;force_login_ssl/" "$data_dir"/config/ojs.config.inc.php
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
    sed -i "s/ojsdev\.conf/ojslocal\.conf/" ./docker-compose-ojslocal.yml
    sed -i "s/ojsdev_app_ulb/ojslocal_app_ulb/" ./docker-compose-ojslocal.yml


fi

echo done....
echo "now start with --> ./start-ojs {dev, local, prod}"
echo you probably must stop running docker containers before!
echo "try --> ./stop-ojs {dev, local, prod}"
echo "now try start ojs ./start-ojs  {dev, local, prod}"

# backup database
if [ "$TARGET" == "prod" ]; then
    backup=$data_dir/sqldumps/$(date +"%Y-%m-%d")_${OJS_VERSION}_ojs
    echo dump OJS database $backup.sql
    echo "docker exec ojs"$TARGET"_db_ulb mysqldump -p${DB_PASS} ojs > $backup"
    docker exec ojs"$TARGET"_db_ulb mysqldump -p${DB_PASS} ojs > $backup && \
        echo "backup successfull:" $(du -h "$backup") && mv "$backup" "$backup".sql || \
        if [ -f "$backup" ]; then 
            rm "$backup"
            echo "backup fails, delete empty dump"
        fi
fi