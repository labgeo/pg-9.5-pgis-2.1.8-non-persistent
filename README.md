pg-pgis-non-persistent
=========================

Build a non persistent docker image containing PostgreSQL + PostGIS latest versions. This may be particularly useful when you need to commit a running docker with attached data. Check tags and releases to see what versions are available.

This image is based on the pg-non-persistent dockerfile, and two other well-known dockerfiles. You can read documentation from these repositories to get a better understanding on how these images can be run:

* https://github.com/labgeo/pg-non-persistent
* https://github.com/docker-library/postgres
* https://github.com/appropriate/docker-postgis

This Docker is aimed at tests and development, not for production purposes.


Build and/or run the container
------------------------------

You can build this dockerfile directly from github or pull it directly compiled from Docker Hub:

```
docker build -t labgeo/pg-pgis-non-persistent:9.5-2.2  https://github.com/labgeo/pg-pgis-non-persistent.git#9.5-2.2
```

Then, run the image:

```
docker run -p 5433:5432  --name siose2005 -e POSTGRES_PASSWORD=postgres -d labgeo/pg-pgis-non-persistent:9.5-2.2
```

Finally, test if postgresql is running with psql. Create a new geodatabase with a basic setup:

```
PGPASSWORD=labgeo psql -h localhost -p 5433 -U postgres -d postgres -w <<EOSQL
CREATE DATABASE siose2005
WITH OWNER "labgeo"
ENCODING 'UTF8'
TEMPLATE template0;

\c siose2005
CREATE EXTENSION postgis;

CREATE SCHEMA IF NOT EXISTS relational;
CREATE SCHEMA IF NOT EXISTS jsonb;
CREATE SCHEMA IF NOT EXISTS grids;
CREATE SCHEMA IF NOT EXISTS reports;
\q
EOSQL
```

