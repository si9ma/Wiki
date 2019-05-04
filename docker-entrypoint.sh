#!/usr/bin/env bash
# Created At Mon Apr 15 2019 4:50:09 PM 
# init docker
# 
# Copyright 2019 si9ma <hellob374@gmail.com>

# variable
user="$1"
passwd="$2"
repo="$3"
email="$4"
name="$5"

# check
[ "$user" = "" -o "$passwd" = "" ] && echo "need username and password for store" && exit 1

cp /script/store.php /script/.htaccess /var/www/html # copy script to apachae home

# change store.php
setting=`printf "\\\$USERS = array('%s' => '%s');" $user $passwd`
sed -i '/$USERS = array(/c\'"$setting" /var/www/html/store.php

# change apache config
# TODO just change /var/www config
sed -i 's/AllowOverride None/AllowOverride All/g' /etc/apache2/apache2.conf

# change directory owner 
chown -R www-data:www-data /var/www/

# clone repo
[ "$repo" = "" ] && repo="https://github.com/si9ma/Wiki.git"
git_repo=`echo $repo | sed 's/https:\/\/github.com\//git@github.com:/g'`

# run as user www-data
[ ! -d "Wiki" ] && sudo -u www-data bash -c "git clone $repo -o Wiki" # clone when repo don't exist
cd Wiki
sudo -u www-data bash -c "git remote rename Wiki origin && git remote set-url origin $git_repo" # run as user www-data
sudo -u www-data bash -c "git config user.email $email"
sudo -u www-data bash -c "git config user.name $name"
sudo -u www-data bash -c 'ssh-keygen -b 2048 -t rsa -f ~/.ssh/id_rsa -q -N "" && cat ~/.ssh/id_rsa.pub' # copy public key to github
sudo -u www-data bash -c 'ssh-keyscan github.com >> ~/.ssh/known_hosts'

# start apache
docker-php-entrypoint apache2-foreground