duckdb

describe from read_parquet('s3://overturemaps-us-west-2/release/2024-04-16-beta.0/theme=buildings/type=building/*', filename=true, hive_partitioning=1);

select names from read_parquet('s3://overturemaps-us-west-2/release/2024-04-16-beta.0/theme=buildings/type=building/*', filename=true, hive_partitioning=1) where names is not null limit 10;

select id, version, update_time, sources from read_parquet('s3://overturemaps-us-west-2/release/2024-04-16-beta.0/theme=buildings/type=building/*', filename=true, hive_partitioning=1) limit 10;

select distinct version from 's3://overturemaps-us-west-2/release/2024-04-16-beta.0/theme=buildings/type=building/*';

select count(*) from read_parquet('s3://overturemaps-us-west-2/release/2024-04-16-beta.0/theme=buildings/type=building/*', filename=true, hive_partitioning=1);

select count(*) FROM read_parquet('s3://overturemaps-us-west-2/release/2024-04-16-beta.0/theme=buildings/type=building/*', filename=true, hive_partitioning=1);


duckdb duckdb.ddb

show tables;

select count(*) from updated_last_14_days;

install spatial;
load spatial;

alter table height_names_tokyo add column geom geometry;
update height_names_tokyo set geom = st_geomfromwkb(geometry);

describe updated_last_14_days;

create or replace table tokyo as
select * exclude (bbox, sources, names) from height_names_tokyo;

COPY tokyo TO 'tokyo.geojson'
WITH (FORMAT GDAL, DRIVER 'GeoJSON', LAYER_CREATION_OPTIONS 'WRITE_BBOX=YES');