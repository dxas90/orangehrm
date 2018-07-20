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

# Download the source
RUN wget -c https://github.com/orangehrm/orangehrm/releases/download/v4.1.1/orangehrm-4.1.1.zip -O ~/orangehrm-3.3.2.zip &&\
    unzip -o ~/orangehrm-3.3.2.zip -d /var/www/site &&\
    rm ~/orangehrm-3.3.2.zip

# Fix Permission
RUN cd /var/www/site/orangehrm-4.1.1; bash fix_permissions.sh; exit 0

# Update the default apache site with the config we created.
ADD docker-build-files/apache-config.conf /etc/apache2/sites-enabled/000-default.conf

# Copy Supervisor configuration
ADD docker-build-files/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Start apache/mysql
CMD /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
