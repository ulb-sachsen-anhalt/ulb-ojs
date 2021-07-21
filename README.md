# ulb-ojs

OJS install pipeline


git, gitlab-runner, docker, docker-cojsose auf Server installieren 
Runner configurieren

ojs.config.inc.php (host, port pwd, etc) Anpassen!

docker-cojsose-ulb.yml  (host, port pwd, etc) Anpassen!

TODO: 

- Daten in /home/ojs/ ablegen &#10003;
- Datenbank update &#10003;




upgrade OJS von 3.1.1.2(aktuell) auf 3_3_0_6 &#10003;

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

./upgrade_ojs.sh &#10003;


Im container Diese Rechte entsprechen den uid/gid im entspr. container.
Da diese Ordner von den Containern eingebunden werden, sollten diese Rechte gesetzt werden.


Im Container ojs_app_ulb:
<pre>
 >id apache   
 >uid=100(apache) gid=101(apache) groups=101(apache),82(www-data),101(apache)
</pre>

Host:
<pre>
sudo chown 999:999  /data/ojs/logs/db -R 
sudo chown 999:999  /data/db -R 
</pre>


Im container ojs_db_ulb:
<pre>
 >id mysql  
 >uid=999(mysql) gid=999(mysql) groups=999(mysql)
</pre>

Host:
<pre>
sudo chown 999:999  /data/ojs/logs/db -R 
sudo chown 999:999  /data/db -R 
</pre>
