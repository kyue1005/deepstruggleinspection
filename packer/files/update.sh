#!/usr/bin/env bash

# rebuild app
(cd src && make build )
mv src/main ./shortener
rm -rf src

# start app
envsubst  < shortener.service.tpl > shortener.service
mv shortener.service /etc/systemd/system/
systemctl daemon-reload

# update nginx conf
envsubst  < nginx.conf.tpl > nginx.shortener.conf
mv nginx.shortener.conf /etc/nginx/sites-available/default