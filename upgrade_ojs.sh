set -eu

echo "upgrade ojs from version 3.1.1.2 up to 3_3_0-6"

echo "drop database ojs"

echo  "drop database ojs;" | docker exec -i ojs_db_ulb mysql -pXXX

echo "create database ojs"

echo  "create database ojs;" | docker exec -i ojs_db_ulb mysql -pXXX

echo "copy public files" | cp -aur /srv/ojs/public/ /data/ojs/
echo "copy journals files" | cp -aur /home/ojs/journals/ /data/ojs/private/
echo "copy userStats files" | cp -aur /home/ojs/userStats/ /data/ojs/private/
echo "copy scheduledTaskLogs files" | cp -aur /home/ojs/scheduledTaskLogs /data/ojs/private/

echo "dump current ojs database" | sudo mysqldump ojs > /data/ojs/sqldumps/ojs.sql

echo "recreate last ojs db form version 3.1.1.2 dump"

cat /data/ojs/sqldumps/ojs.sql | docker exec -i ojs_db_ulb mysql -pXXX ojs

OJS_VERSION=3_1_1-2

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

