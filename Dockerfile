FROM php:apache

RUN apt-get -y update
RUN apt-get -y install vim git inotify-tools sudo

COPY script /script
COPY docker-entrypoint.sh /

WORKDIR /var/www/html

ENTRYPOINT [ "/docker-entrypoint.sh" ]
