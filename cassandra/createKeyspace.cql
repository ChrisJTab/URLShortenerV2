CREATE KEYSPACE IF NOT EXISTS urlshortener WITH REPLICATION = {'class' : 'SimpleStrategy', 'replication_factor' : 3};

DESCRIBE KEYSPACE urlshortener;

USE urlshortener;

CREATE TABLE IF NOT EXISTS short_urls (
    short_url text PRIMARY KEY,
    long_url text
);