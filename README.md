# ulb-ojs

OJS install pipeline


git, gitlab-runner, docker, docker-compose auf Server installieren 
Runner configurieren

ojs.config.inc.php (host, port pwd, etc) Anpassen!

docker-compose-ulb.yml  (host, port pwd, etc) Anpassen!

TODO: 

- Daten in /home/ojs/volumes/db ablegen
- Datenbank update




upgrade OJS von 3.1.1.2(aktuell) auf 3_3_0_6

https://openjournaltheme.com/how-to-upgrade-ojs-3/

https://github.com/pkp/ojs/blob/main/docs/UPGRADE.md


einmaliges upgrade auf neueste Version:

in der .env alle Versionen auskommentieren! (die Versionen werden im upgrade_ojs.sh gesetzt!)

<pre>
sudo mysqldump ojs > /tmp/ojs.sql
cp /tmp/ojs.sql /data/ojs/sqldump
cp -aur /home/ojs/journals/ /data/ojs/public/
</pre>

die Journalbilder/Sitebilder liegen unter /srv/ojs/public/
"private" liegt unter /home/ojs/jurnals
also auch hier 
<pre>
cp -aur /srv/ojs/public/journals/ /data/ojs/public/
cp -aur /srv/ojs/public/site/ /data/ojs/public/
cp -aur /home/ojs/journals/ /data/ojs/private/
</pre>

./upgrade_ojs.sh