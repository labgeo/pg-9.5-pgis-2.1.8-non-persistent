FROM debian:jessie

MAINTAINER Benito Zaragozi <benizar@gmail.com>

RUN apt-get update
RUN apt-get -y install wget lsb-release
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list
RUN wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | apt-key add -
RUN apt-get update
RUN apt-get -y install postgresql postgresql-contrib postgresql-server-dev-all wget unzip
RUN apt-get clean

RUN service postgresql start; \
  su - postgres -c "/usr/lib/postgresql/9.5/bin/psql -U postgres -c \"ALTER USER postgres with password 'postgres';\""
RUN sed -i "s/\#listen_addresses = 'localhost'/listen_addresses = '\*'/g" /etc/postgresql/9.5/main/postgresql.conf
RUN echo "host all all 0.0.0.0/0 md5" >> /etc/postgresql/9.5/main/pg_hba.conf

ADD run.sh /run.sh
RUN chmod -v +x /run.sh

EXPOSE 5432

CMD ["/run.sh"]

