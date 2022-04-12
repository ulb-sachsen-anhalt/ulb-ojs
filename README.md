# OJS Server ULB



OJS install pipeline


install git, gitlab-runner, docker on server, 
configure gitlab runner

configure _./resources/ojs.config.inc.php_ (host, port pwd, mail, etc.)

configure  _.env_  and _docker-compose-ojsprod.yml_  (host, port, pwd, etc.)

## Setup enviroment

First we need to create all directories, 
referenced as volume form _docker-compose-ompdev.yml_
OJS data are located in
_/data/ojsprod_ and _/data/ojsdev_

```bash
/data/ojsdev/config
/data/ojsdev/db
/data/ojsdev/files
/data/ojsdev/logs
/data/ojsdev/plugins
/data/ojsdev/private
/data/ojsdev/public

```
(same for _docker-compose-ojsprod.yml_)

_uid_ and _gid_ of directories should correspondent within the container ids

e.g.: container ojs_app_ulb
```bash
 $ id apache   
 uid=100(apache) gid=101(apache) groups=101(apache),82(www-data),101(apache)
```
container ojs_dbdev_ulb:
```bash
 $ id mysql  
 uid=999(mysql) gid=999(mysql) groups=999(mysql)
```

So set appropriate on host machine:
<pre>
sudo chown 100:100  /data/ojsdev/ -R
sudo chown 999:999  /data/ojsdev/logs/db -R 
sudo chown 999:999  /data/ojsdev/db -R 
</pre>

From your clone directory start ```./build.sh```

This will setup all data for you to start docker container in _developent, production_ or _local_ mode.
(There is probably some extra work if you start form scratch.)

To start container use start and stop scripts:
```bash
./start-ojs local
./stop-ojs local
```

Please check _.env_ for further settings!

## GitLab CI/CD

If you are working with gitlab you can use the .```gitlab-ci.yml``` to fire up your gitlab-runner. 



## License

GPL3


## Further information

https://typeset.io/resources/the-a-z-of-open-journal-systems-ojs-3-user-guide/
