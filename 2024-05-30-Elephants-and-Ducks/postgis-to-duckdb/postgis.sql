CREATE EXTENSION duckdb_fdw;

CREATE SERVER duckdb_server
FOREIGN DATA WRAPPER duckdb_fdw
OPTIONS (
        database ':memory'
);

GRANT USAGE ON FOREIGN SERVER duckdb_server TO postgres;

CREATE FOREIGN TABLE public.bikes_2023 (
	ride_id text,
	rideable_type text,
	started_at timestamp,
	ended_at timestamp,
	start_station_name text,
	start_station_id text,
	end_station_name text,
	end_station_id text,
	start_lat float,
	start_lng float,
	end_lat float, 
	end_lng float,
	member_casual text
)
SERVER duckdb_server
OPTIONS (
    table 'read_parquet("https://storage.googleapis.com/citi-bikes-spatial/citibike_2023.parquet")'
);

SELECT count(*) FROM public.bikes_2023;

SELECT duckdb_execute('duckdb_server', 'install spatial;');
SELECT duckdb_execute('duckdb_server', 'load spatial;');


SELECT duckdb_execute('duckdb_server'
,'create table bikes_2023 as select *, st_point(start_lng, start_lat) as start_geom, st_point(end_lng, end_lat) as end_geom from "https://storage.googleapis.com/citi-bikes-spatial/citibike_2023.parquet";');


drop foreign table public.bikes_2023_duckdb;

create foreign TABLE public.bikes_2023_duckdb(
	ride_id text,
	rideable_type text,
	started_at timestamp,
	ended_at timestamp,
	start_station_name text,
	start_station_id text,
	end_station_name text,
	end_station_id text,
	start_lat float,
	start_lng float,
	end_lat float, 
	end_lng float,
	member_casual text,
    start_geom geometry,
    end_geom geometry)
      SERVER duckdb_server OPTIONS (table 'bikes_2023');


select *, st_transform(st_setsrid(end_geom, 4326), 3857) from bikes_2023_duckdb limit 10;

select 
start_station_name,
count(*) as total
from bikes_2023_duckdb
group by 1 order by 2 desc

select 
	*
	from
	bikes_2023_duckdb
where st_intersects((
	select wkb_geometry from public.custom_pedia_cities_nyc_mar2018 where neighborhood = 'West Village'
)
	, st_setsrid(end_geom, 4326))
