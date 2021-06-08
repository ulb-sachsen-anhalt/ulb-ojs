set -eu

echo "upgrade ojs from version 3.1.1.2 up to 3_3_0-6"

echo "drop database ojs"

echo  "drop database ojs;" | docker exec -i ojs_db_ulb mysql -pxxx

echo "create database ojs"

echo  "create database ojs;" | docker exec -i ojs_db_ulb mysql -pxxx

echo "recreate last ojs db form version 3.1.1.2 dump"

cat /data/ojs/sqldumps/ojs.sql | docker exec -i ojs_db_ulb mysql -pxxx ojs

versions_steps=(
    3_1_2-0
    3_1_2-4
    3_2_0-3
    3_2_1-1
    3_3_0-4
    3_3_0-6
    )

for version in ${versions_steps[*]}
    do
        echo "update ojs to from version $OJS_VERSION to $version"
        export OJS_VERSION=$version
        echo "start build script"; ./build-ojs.sh
        docker exec -it ojs_app_ulb /usr/local/bin/ojs-upgrade 
    done

