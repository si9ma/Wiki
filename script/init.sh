#!/usr/bin/env bash
# Created At Mon Apr 15 2019 4:50:09 PM 
# init docker
# 
# Copyright 2019 si9ma <hellob374@gmail.com>

# set store username and password
user="$1"
passwd="$2"
[ "$user" = "" -o "$passwd" = "" ] && echo "need username and password for store" && exit 1
setting=`printf "\\\$USERS = array('%s' => '%s');" $user $passwd`
cp /script/store.php /script/.htaccess /var/www/html # copy script to apachae home
sed -i '/$USERS = array(/c\'"$setting" /var/www/html/store.php

# change apache config
# TODO just change /var/www config
sed -i 's/AllowOverride None/AllowOverride All/g' /etc/apache2/apache2.conf

# clone repo
repo="$3"
[ "$repo" = "" ] && repo="https://github.com/si9ma/Wiki.git"
git_repo=`echo $repo | sed 's/https:\/\/github.com\//git@github.com:/g'`
sudo -u www-data git clone $repo -o Wiki && cd Wiki && git remote rename Wiki origin && git remote set-url origin $git_repo

# auto commiter
email="$4"
name="$5"
ssh-keygen -b 2048 -t rsa -f ~/.ssh/id_rsa -q -N "" && cat ~/.ssh/id_rsa.pub # copy public key to github
ssh-keyscan github.com >> ~/.ssh/known_hosts
git config user.email "$email"
git config user.name "$name"
# inotify events is MOVE_SELF when store.php store index.html 
# Analysis use inotifywait -m index.html
while inotifywait -e MOVE_SELF index.html
    # wait file exist
    until [ -f index.html ]
    do
        echo "wait index.html"
        sleep 1
    done
    do git commit -m 'autocommit on change' index.html && git pull && git push origin
done &

# start apache
docker-php-entrypoint apache2-foreground