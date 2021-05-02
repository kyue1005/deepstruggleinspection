#!/usr/bin/env bash

# stop app
service shortener stop

# rebuild app
(cd src && go build -o ../shortener)

# start app
envsubst  < shortener.service.tpl > shortener.service
mv shortener.service /etc/systemd/system/
systemctl daemon-reload
service shortener.service restart

# update nginx conf
envsubst  < nginx.conf.tpl > nginx.shortener.conf
mv nginx.shortener.conf /etc/nginx/sites-available/default
nginx -s reload