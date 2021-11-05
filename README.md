# OJS Server ULB

[![pipeline status](https://git.itz.uni-halle.de/ulb/ulb-ojs/badges/master/pipeline.svg)](https://git.itz.uni-halle.de/ulb/ulb-ojs/badges/master/pipeline.svg)


OJS install pipeline


git, gitlab-runner, docker, docker-ojs auf Server installieren 
Runner configurieren

ojs.config.inc.php (host, port pwd, mail, etc) Anpassen!

docker-ojs-ulb.yml  (host, port, pwd, etc) Anpassen!

TODO: 

- Daten in /home/ojs/ ablegen &#10003;
- Datenbank update &#10003;
- upgrade OJS von 3.1.1.2(aktuell) auf 3_3_0_6 &#10003;


https://github.com/pkp/ojs/blob/main/docs/UPGRADE.md


einmaliges upgrade auf neueste Version:

in der .env alle Versionen auskommentieren! (die Versionen werden im upgrade_ojs.sh gesetzt!)

<pre>
sudo mysqldump ojs > /tmp/ojs.sql
cp /tmp/ojs.sql /data/ojs/sqldump
cp -aur /home/ojs/journals/ /data/ojs/public/
</pre>

die Journalbilder/Sitebilder liegen unter /srv/ojs/public/

"private" liegt unter /home/ojs/journals

<pre>
cp -aur /srv/ojs/public/journals/ /data/ojs/public/
cp -aur /srv/ojs/public/site/ /data/ojs/public/
cp -aur /home/ojs/journals/ /data/ojs/private/
</pre>

./upgrade_ojs.sh &#10003;

OJS Daten liegen nun in 

_/data/ojsprod_ bzw. _/data/ojsdev_

Die Besitzer hier entsprechen den uid/gid im entspr. Container.
Da diese Ordner/Unterordner von den Containern eingebunden werden, sollten diese Rechte analog gesetzt werden:

Im Container ojsdev_app_ulb / ojsprod_app_ulb:
<pre>
 >id apache   
 >uid=100(apache) gid=101(apache) groups=101(apache),82(www-data),101(apache)
</pre>

Host:
<pre>
sudo chown 100:101  /data/ojsprod/ -R
sudo chown 100:101  /data/ojsdev/ -R
</pre>


Im container ojsprod_db_ulb bzw. ojsdev_db_ulb:
<pre>
 >id mysql  
 >uid=999(mysql) gid=999(mysql) groups=999(mysql)
</pre>

Host:
<pre>
sudo chown 999:999  /data/ojs{&lt;prod&gt;,&lt;dev&gt;}/logs/db -R 
sudo chown 999:999  /data/ojs{&lt;prod&gt;,&lt;dev&gt;}db -R 
</pre>




https://typeset.io/resources/the-a-z-of-open-journal-systems-ojs-3-user-guide/