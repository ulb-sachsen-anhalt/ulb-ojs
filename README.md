# OJS Server ULB


In order to streamline the development for our OJS and OMP applications and to ease the deployment of ready-to-go code from our test environment onto our productive environment, we have decided to use Docker. 

What follows is an outline of the steps necessary to run an OJS installation in a Docker container:

OJS install pipeline


install git, gitlab-runner, docker on server, 
configure gitlab runner

configure _./resources/ojs.config.inc.php_ (host, port pwd, mail, etc.)

configure  _.env_  and _docker-compose-ojsprod.yml_  (host, port, pwd, etc.)

## Setup environment

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

_uid_ and _gid_ of directories should correspond within the container ids

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
sudo chown 100:101  /data/ojsdev/ -R
sudo chown 999:999  /data/ojsdev/logs/db -R 
sudo chown 999:999  /data/ojsdev/db -R 
</pre>

From your clone directory start ```./build.sh```

This will setup all data for you to start the docker container in _developent, production_ or _local_ mode.
(There is probably some extra work if you start from scratch.)

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
