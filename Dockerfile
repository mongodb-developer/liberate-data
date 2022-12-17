FROM postgres:15
COPY /postgres/northwind.sql /docker-entrypoint-initdb.d
