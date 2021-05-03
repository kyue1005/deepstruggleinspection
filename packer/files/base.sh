#!/usr/bin/env bash

apt-get update && apt-get install nginx golang build-essential -y

# build go app
(cd src && make build )
mv src/main ./shortener
rm -rf src

# star app
envsubst  < shortener.service.tpl > shortener.service
mv shortener.service /etc/systemd/system/
systemctl daemon-reload

# setup nginx
envsubst  < nginx.conf.tpl > nginx.shortener.conf
mv nginx.shortener.conf /etc/nginx/sites-available/default