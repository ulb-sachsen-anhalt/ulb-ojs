#!/bin/bash

set -eu

DB_NAME=$1
DB_USER=$2
DB_PASS=$3

echo start with DB: $DB_NAME, $DB_USER, DB_PASS

VERSION=main
PHP_TAIL=/alpine/apache/php
OJS_GIT=https://github.com/pkp/docker-ojs.git
# OJS_ULB=git@git.itz.uni-halle.de:ulb/ulb-ojs.git


git clone ${OJS_GIT} || echo "'${OJS_GIT}' just here"
# git clone ${OJS_ULB} || echo "'${OJS_ULB}' just here"

mkdir -p volumes/config
cp ./ojs.config.inc.php volumes/config/
mkdir -p volumes/db
mkdir -p volumes/logs
mkdir -p volumes/migration
mkdir -p volumes/private
mkdir -p volumes/public

OJS_HOME=$(find ./docker-ojs -type d -name ${VERSION})
OJS_HOME=$OJS_HOME$PHP_TAIL
if [ -z "$OJS_HOME$" ] ; then echo "**OJS Version $VERSION not found!**";
    else echo "Version '$VERSION' found --> $OJS_HOME"; fi

echo copy $OJS_HOME/Dockerfile .
cp $OJS_HOME/Dockerfile .

echo copy $OJS_HOME/exclude.list
cp $OJS_HOME/exclude.list .


echo try start docker-compose with docker-compose-ulb.yml
#start OJS

docker-compose --file ./docker-compose-ulb.yml down

docker-compose --file ./docker-compose-ulb.yml up -d


