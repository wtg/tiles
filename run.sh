#!/bin/sh

service postgresql start
sleep 60
service renderd start
apachectl -e info -DFOREGROUND
