#!/bin/sh

#curl "http://www.openstreetmap.org/api/0.6/map?bbox=-73.8467%2C42.5822%2C-73.5284%2C42.85" > /tmp/troy.osm
service postgresql start

sudo -u postgres sh -c "createuser osm && createdb -O osm gis"
sudo -u postgres psql -c "CREATE EXTENSION hstore; CREATE EXTENSION postgis;" -d gis

sudo -u osm osm2pgsql -d gis -C 1500 --number-processes 4 --style /home/osm/openstreetmap-carto/openstreetmap-carto.style -k /tmp/new-york-latest.osm.pbf
