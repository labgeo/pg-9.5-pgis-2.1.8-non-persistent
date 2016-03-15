pg-9.5-pgis-2.1.8-non-persistent
=========================

Presentation
------------
Build a non persistent docker image containing PostgreSQL 9.5 + PostGIS 2.1.8. This may be particularly useful when you need to commit a running docker with attached data.

This Docker image is a container is based on Ubuntu 14.04 and features:

* PostgreSQL 9.5 (from PGDG packages)
* PostGIS 2.1.8 and GEOS 3.5
* 

It won't create any database, but you can use a labgeo superuser (password labgeo), with postgis. This Docker is aimed at tests and development. Do not use it for production purposes. It lacks security and is not micro-service oriented as should a Docker stack be. Use at your own risk.


Build and/or run the container
------------------------------

Git clone this repository to get the Dockerfile, and cd to it.

You can build the image with :

```sh
docker build https://github.com/labgeo/pg-9.5-pgis-2.1.8-non-persistent.git
```

Run the container with :

```sh
docker run -d -p 5433:5432 benizar/pg-9.5-pgis-2.1.8-non-persistent
```
