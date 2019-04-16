FROM php:apache

RUN apt-get -y update
RUN apt-get -y install vim git inotify-tools sudo

WORKDIR /var/www/html

ENTRYPOINT [ "/script/init.sh" ]