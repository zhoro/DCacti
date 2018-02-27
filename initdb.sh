#!/bin/bash

/usr/bin/mysql -h mysql -u root --password="${MYSQL_ROOT_PWD}" <<MYSQL_SCRIPT
CREATE DATABASE $MYSQL_DATABASE; 
DROP USER IF EXISTS '$MYSQL_USER';
CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PWD';
GRANT SELECT ON mysql.time_zone_name TO '$MYSQL_USER'@'%';
GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
MYSQL_SCRIPT

/usr/bin/mysql -h mysql -u root --password="${MYSQL_ROOT_PWD}" ${MYSQL_DATABASE} < /var/www/cacti/cacti.sql

/bin/cp /var/www/cacti/include/config.php.dist /var/www/cacti/include/config.php

sed -i "s/\$database_hostname = \'localhost\';/\$database_hostname = \'mysql\';/g" /var/www/cacti/include/config.php
sed -i "s/\$database_default = \'cacti\';/\$database_default = \'$MYSQL_DATABASE\'/g" /var/www/cacti/include/config.php
sed -i "s/\$database_username = \'cactiuser\';/\$database_username = \'$MYSQL_USER\';/g" /var/www/cacti/include/config.php
sed -i "s/\$database_password = \'cactiuser\';/\$database_password = \'$MYSQL_PWD\';/g" /var/www/cacti/include/config.php

sed -i "s/DB_Host[ \t]*localhost/DB_Host                 mysql/g" /etc/spine.conf
sed -i "s/DB_Database[ \t]*cacti/DB_Database             $MYSQL_DATABASE/g" /etc/spine.conf
sed -i "s/DB_User[ \t]*cactiuser/DB_User                 $MYSQL_USER/g" /etc/spine.conf
sed -i "s/DB_Pass[ \t]*cactiuser/DB_Pass                 $MYSQL_PWD/g" /etc/spine.conf

