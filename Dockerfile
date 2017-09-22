FROM ubuntu:17.04

# mod_tile
RUN apt-get update && \
	apt-get install -y libmapnik3.0 libmapnik-dev mapnik-utils python-mapnik autoconf apache2-dev git
RUN mkdir /tmp/build && cd /tmp/build
RUN git clone https://github.com/openstreetmap/mod_tile.git
RUN cd mod_tile && ./autogen.sh && ./configure && make && make install && make install-mod_tile
RUN mkdir /var/lib/mod_tile
RUN useradd --create-home --shell /bin/bash osm
RUN chown osm:osm /var/lib/mod_tile

# renderd
COPY renderd.conf /usr/local/etc/renderd.conf
COPY renderd.init /etc/init.d/renderd

# set up server
RUN apt-get install -y apache2
RUN echo "LoadModule tile_module /usr/lib/apache2/modules/mod_tile.so" > /etc/apache2/mods-available/tile.load
RUN ln -s /etc/apache2/mods-available/tile.load /etc/apache2/mods-enabled/
COPY 000-default.conf /etc/apache2/sites-enabled/000-default.conf

# mapnik style
RUN cd /home/osm && git clone https://github.com/gravitystorm/openstreetmap-carto.git
RUN cd /home/osm/openstreetmap-carto && scripts/get-shapefiles.py
WORKDIR /home/osm/openstreetmap-carto
RUN apt-get install -y nodejs npm fonts-noto-cjk fonts-noto-hinted fonts-noto-unhinted fonts-hanazono ttf-unifont
RUN ln -s /usr/bin/nodejs /usr/local/bin/node
RUN npm install -g carto
RUN carto project.mml > style.xml

# import tile data
RUN apt-get install -y osm2pgsql postgresql
RUN apt-get install -y sudo
RUN curl http://download.geofabrik.de/north-america/us/new-york-latest.osm.pbf > /tmp/new-york-latest.osm.pbf
COPY import.sh /tmp/import.sh
RUN /tmp/import.sh

WORKDIR /
COPY run.sh /run.sh
#CMD ["/bin/bash"]
CMD ["/run.sh"]
