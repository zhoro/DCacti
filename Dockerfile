FROM alpine:3.7

MAINTAINER Andrii Zhovtiak <andy@urlog.net>

ENV CACTI_HOME /usr/local/cacti
ENV CACTI_BRANCH develop 
ENV CACTI_SPINE 1.1.35

ENV MYSQL_DATABASE=cacti
ENV MYSQL_ROOT_PWD=mysqlpwd
ENV MYSQL_USER=cacti
ENV MYSQL_PWD=cacti

RUN apk update && apk upgrade
RUN apk add dcron coreutils mariadb-client-libs mysql-dev autoconf automake binutils libtool tzdata bash sudo supervisor shadow curl unzip bind-tools ca-certificates nginx fcgiwrap wget iputils rrdtool
RUN apk add net-snmp-libs net-snmp-perl net-snmp-tools net-snmp mysql-client net-snmp-dev 
RUN apk add perl php7 php7-xml php7-simplexml php7-mysqlnd php7-posix php7-sockets php7-gmp php7-ldap php7-json php7-zlib php7-session php7-mbstring php7-mysqli php7-pdo_mysql php7-curl php7-fpm php7-gd php7-snmp php7-pdo php7-pear build-base linux-headers mariadb-dev help2man  
RUN apk add gd gd-dev fontconfig-dev jpeg-dev libx11-dev
 
RUN set -x ; \
    addgroup -g 82 -S www-data ; \
    adduser -u 82 -D -S -G www-data www-data && exit 0 ; exit 1;
# 82 is the standard uid and gid for "www-data" in Alpine Linux

RUN set -x ;  addgroup -S cacti ; adduser -D -S -G cacti cacti && exit 0 ; exit 1;

RUN cd /tmp  \
	&& wget https://github.com/Cacti/cacti/archive/${CACTI_BRANCH}.zip \
	&& /usr/bin/unzip -o ${CACTI_BRANCH}.zip \
	&& mv cacti-${CACTI_BRANCH} /var/www/cacti \
	&& chown -R www-data:www-data /var/www/cacti \
	&& rm -rf /tmp/cacti-${CACTI_BRANCH}.zip

RUN cd /tmp \
	&& wget http://www.cacti.net/downloads/spine/cacti-spine-${CACTI_SPINE}.tar.gz \
	&& tar -zxvf cacti-spine-${CACTI_SPINE}.tar.gz \ 
	&& cd cacti-spine-${CACTI_SPINE} \
        && ./configure \
	&& make \
	&& make install \
	&& chown root:root /usr/local/spine/bin/spine \
	&& chmod +s /usr/local/spine/bin/spine \
	&& rm -rf /tmp/cacti-spine-${CACTI_SPINE}.tar.gz

RUN cp /usr/local/spine/etc/spine.conf.dist /etc/spine.conf

RUN mkdir -p /run/nginx
RUN mkdir -p /var/log/supervisor
RUN mkdir -p /var/log/cacti

RUN /bin/sed -i "s|;date.timezone =|date.timezone = Europe/Kiev|g" /etc/php7/php.ini  

RUN cp /usr/share/zoneinfo/Europe/Kiev /etc/localtime
RUN /bin/echo "Europe/Kiev" >  /etc/timezone

RUN apk del mysql-dev autoconf automake net-snmp-dev mariadb-dev build-base linux-headers gd-dev fontconfig-dev jpeg-dev libx11-dev
RUN rm -rf /var/cache/apk/*
RUN rm /etc/nginx/conf.d/default.conf
RUN echo "*/5 * * * * /usr/bin/php /var/www/cacti/poller.php > /dev/null 2>&1" >> /etc/crontabs/root

COPY htpasswd.users /etc/htpasswd.users
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY supervisord.conf /etc/supervisord.conf

RUN /bin/chown www-data:nginx /var/www/cacti/scripts -R 
RUN /bin/chown www-data:nginx /var/www/cacti/log -R
RUN /bin/chown www-data:nginx /var/www/cacti/cache -R 
RUN /bin/chown www-data:nginx /var/www/cacti/rra -R 
RUN /bin/chmod 777 /var/www/cacti/scripts -R 
RUN /bin/chmod 777 /var/www/cacti/resource -R 
RUN /bin/chmod 777 /var/www/cacti/log -R
RUN /bin/chmod 777 /var/www/cacti/cache -R 
RUN /bin/chmod 777 /var/www/cacti/rra -R 

COPY initdb.sh /tmp/initdb.sh
RUN chmod +x /tmp/initdb.sh

EXPOSE  80/tcp

VOLUME "/var/log/cacti" "/var/www/cacti/rra"

CMD ["supervisord", "-n", "-c", "/etc/supervisord.conf"]

