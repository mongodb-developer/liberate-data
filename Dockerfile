FROM postgres:14
#COPY /postgres/postgresql.conf /var/lib/postgresql/data/postgresql.conf
COPY /postgres/northwind.sql /docker-entrypoint-initdb.d
