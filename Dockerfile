FROM postgres:14
COPY /postgres/northwind.sql /docker-entrypoint-initdb.d
