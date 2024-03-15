duckdb

.timer on

install spatial;
load spatial;
install httpfs;
load httpfs;

set s3_region='us-west-2';

select count(*) from 's3://us-west-2.opendata.source.coop/vida/google-microsoft-open-buildings/geoparquet/by_country/country_iso=NOR/NOR.parquet';

select count(*) from 's3://us-west-2.opendata.source.coop/cholmes/overture/places-geoparquet-country/NO.parquet';

describe from 's3://us-west-2.opendata.source.coop/vida/google-microsoft-open-buildings/geoparquet/by_country/country_iso=NOR/NOR.parquet';

create or replace table oslo as select bf_source, confidence, area_in_meters, country_iso, st_geomfromwkb(geometry) as geom from 's3://us-west-2.opendata.source.coop/vida/google-microsoft-open-buildings/geoparquet/by_country/country_iso=NOR/NOR.parquet' where st_dwithin(st_geomfromwkb(geometry), st_point(10.7409424, 59.9135533), .1);

select * from oslo;

COPY oslo TO 'oslo.geojson' WITH (FORMAT GDAL, DRIVER 'GeoJSON', LAYER_CREATION_OPTIONS 'WRITE_BBOX=YES');
