FROM php:apache

RUN apt-get -y update
RUN apt-get -y install vim git inotify-tools sudo
RUN chown -R www-data /var/www

USER www-data

ADD script /
ADD docker-entrypoint.sh /

WORKDIR /var/www/html

ENTRYPOINT [ "/docker-entrypoint.sh" ]