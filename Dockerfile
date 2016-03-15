FROM ubuntu
MAINTAINER Benito Zaragozi <benizar@gmail.com>

# Add the PostgreSQL PGP key to verify their Debian packages.
# It should be the same key as https://www.postgresql.org/media/keys/ACCC4CF8.asc
RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8

# Add PostgreSQL's repository. It contains the most recent stable release
#     of PostgreSQL, ``9.5``.
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" > /etc/apt/sources.list.d/pgdg.list

# Install ``python-software-properties``, ``software-properties-common`` and PostgreSQL 9.5
#  There are some warnings (in red) that show up during the build. You can hide
#  them by prefixing each apt-get statement with DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y python-software-properties software-properties-common postgresql-9.5 postgresql-client-9.5 postgresql-contrib-9.5 postgresql-server-dev-9.5


#--------------
ENV POSTGIS_VERSION 2.1.8

RUN buildDeps=" \
  libgeos-dev \
  libproj-dev \ 
  libgdal-dev \
  libjson0-dev \
  make \
  curl \
  gcc \
  "; \
     apt-get update \
  && apt-get install -y $buildDeps libxml2 --no-install-recommends \
  && curl -o /tmp/postgis-$POSTGIS_VERSION.tar.gz -s \ 
      http://download.osgeo.org/postgis/source/postgis-$POSTGIS_VERSION.tar.gz \
  && tar xf /tmp/postgis-$POSTGIS_VERSION.tar.gz -C /usr/src/ \
  && cd /usr/src/postgis-$POSTGIS_VERSION \
  && ./configure \
  && make -j"$(nproc)" \
  && make install \
  && cd extensions \
  && make -j"$(nproc)" \
  && make install \
  && cd / && rm /tmp/postgis-$POSTGIS_VERSION.tar.gz \
  && apt-get purge --auto-remove -y $buildDeps \
  && rm -rf /var/lib/apt/lists/*

RUN postgisDeps=' \
  libgdal1h \
  libproj0 \
  libgeos-3.4.2 \
  libjson0 \
  '; \
    apt-get update \
  && apt-get install -y $postgisDeps \
  && rm -rf /var/lib/apt/lists/*


#--------------


# Note: The official Debian and Ubuntu images automatically ``apt-get clean``
# after each ``apt-get``

# Run the rest of the commands as the ``postgres`` user created by the ``postgres-9.5`` package when it was ``apt-get installed``
USER postgres

# Create a PostgreSQL role named ``docker`` with ``docker`` as the password and
# then create a database `docker` owned by the ``docker`` role.
# Note: here we use ``&&\`` to run commands one after the other - the ``\``
#       allows the RUN command to span multiple lines.
RUN    /etc/init.d/postgresql start &&\
    psql --command "CREATE USER labgeo WITH SUPERUSER PASSWORD 'labgeo';" 
#&&\ createdb -O labgeo labgeo

# Adjust PostgreSQL configuration so that remote connections to the
# database are possible.
RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/9.5/main/pg_hba.conf

# And add ``listen_addresses`` to ``/etc/postgresql/9.5/main/postgresql.conf``
RUN echo "listen_addresses='*'" >> /etc/postgresql/9.5/main/postgresql.conf

# Expose the PostgreSQL port
EXPOSE 5432

# Add VOLUMEs to allow backup of config, logs and databases
#VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]

# Set the default command to run when starting the container
CMD ["/usr/lib/postgresql/9.5/bin/postgres", "-D", "/var/lib/postgresql/9.5/main", "-c", "config_file=/etc/postgresql/9.5/main/postgresql.conf"]


