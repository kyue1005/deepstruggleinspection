#!/usr/bin/env bash

apt-get update && apt-get install nginx golang -y

# build go app
(cd src && go build -o ../shortener)
rm -rf src

# star app
envsubst  < shortener.service.tpl > shortener.service
mv shortener.service /etc/systemd/system/
systemctl daemon-reload
service shortener start

# setup nginx
envsubst  < nginx.conf.tpl > nginx.shortener.conf
mv nginx.shortener.conf /etc/nginx/sites-available/default
nginx -s reload