# DCacti

Cacti from develop branch + Cacti SPINE 1.1.35 (MySQL DB not included)

Based on Alpine Linux version 3.7

WEB access: _admin_ | _nagiosadmin_

-    Cacti 1.1.36 (develop branch)
-    Spine 1.1.35
-    RDTool 1.5. 	
-    Nginx as web-server (without Apache)
-    Default ENV variables:
MYSQL_DATABASE=cacti,
MYSQL_ROOT_PWD=mysqlpwd,
MYSQL_USER=cacti,
MYSQL_PWD=cacti

## How to run

**WARNING**: MySQL not included. You must use other container. For example https://hub.docker.com/r/zxandy/mysql/

1. `docker run --name cacti --link mysql:mysql -td -v /opt/cacti/rra/:/var/www/cacti/rra/:rw -v c:/opt/cacti/log:/var/log/cacti:rw -p 8088:80 zxandy/cacti:v1.0`

2. `docker exec -ti cacti /tmp/initdb.sh` (DB initialization)

3. Open URL http://X.X.X.X:8088

## Other
Installation wizard variables settings:
- Spine location `/usr/local/spine/bin/spine`
- Log location `/var/log/cacti.log`

## Known issues

If you get error message during Installation wizard: 
> "Your MySQL TimeZone database is not populated. Please populate this database before proceeding."

execute on MySQL host:

`mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql -u root -p mysql`
