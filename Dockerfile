FROM ubuntu:16.04
MAINTAINER Orangehrm <samanthaj@orangehrm.com>

RUN apt-get update
RUN apt-get -y upgrade

# Install apache, PHP, and supplimentary programs. curl and lynx-cur are for debugging the container.
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install apache2 mysql-server libapache2-mod-php php-mysql php-gd php-pear php-memcache php-cache php-curl curl lynx-cur wget unzip supervisor

# Enable apache mods.
RUN a2enmod php*
RUN a2enmod rewrite

# Manually set up the apache environment variables
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

# Export port 80
EXPOSE 80

#config mysql
RUN /usr/sbin/mysqld & \
    sleep 5s &&\
    echo "USE mysql;\nUPDATE user SET password=PASSWORD('root') WHERE user='root';\nFLUSH PRIVILEGES;\n" | mysql

# Download the source
RUN wget -c https://github.com/orangehrm/orangehrm/releases/download/v4.1.1/orangehrm-4.1.1.zip -O ~/orangehrm-3.3.2.zip &&\
    unzip -o ~/orangehrm-3.3.2.zip -d /var/www/site &&\
    rm ~/orangehrm-3.3.2.zip

# Fix Permission
RUN cd /var/www/site/orangehrm-4.1.1; chmod -R go+w installer symfony/apps/orangehrm/config && chmod -R go+w lib/confs symfony/log symfony/cache lib/logs symfony/config upgrader/cache upgrader/log

# Update the default apache site with the config we created.
RUN cat > /etc/apache2/sites-enabled/000-default.conf << EOF
<VirtualHost *:80>
  ServerAdmin me@mydomain.com
  DocumentRoot /var/www/site/orangehrm-4.1.1

  <Directory /var/www/site/orangehrm-4.1.1/>
      Options Indexes FollowSymLinks MultiViews
      AllowOverride All
      Order deny,allow
      Allow from all
  </Directory>

  ErrorLog ${APACHE_LOG_DIR}/error.log
  CustomLog ${APACHE_LOG_DIR}/access.log combined

</VirtualHost>
EOF

# Copy Supervisor configuration
RUN cat > /etc/supervisor/conf.d/supervisord.conf << EOF
[supervisord]
nodaemon=true

[program:sshd]
command=/usr/sbin/sshd -D
autorestart=true

[program:mysql]
command=/usr/bin/pidproxy /var/run/mysqld/mysqld.pid /usr/sbin/mysqld
autorestart=true

[program:apache2]
command=/bin/bash -c "source /etc/apache2/envvars && exec /usr/sbin/apache2 -DFOREGROUND"
EOF

# Start apache/mysql
CMD /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
