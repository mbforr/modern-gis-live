-- Load neighborhoods

./duckdb

install spatial;
load spatial;

create table nyc_hoods as select * from st_read('custom-pedia-cities-nyc-Mar2018.geojson');

describe nyc_hoods;

-- Attach MotherDuck

ATTACH 'md:citibike';

show all databases;

describe select * from citibike.citibike_2021_to_present;

-- Show top stations

select count(*) as rides, start_station_name from citibike.citibike_2021_to_present group by 2 order by 1 desc;

create table top_stations as with a as (select count(*) as rides, start_station_name from citibike.citibike_2021_to_present group by 2 order by 1 desc) select a.*, st_point(b.lng, b.lat) as geometry from a join citibike.citibike_stations b on a.start_station_name = b.name;

COPY top_stations TO 'top_stations.geojson' WITH (FORMAT GDAL, DRIVER 'GeoJSON', LAYER_CREATION_OPTIONS 'WRITE_BBOX=YES');

-- Top neighborhoods

select a.neighborhood, count(*) as trips from nyc_hoods a join top_stations b on st_intersects(a.geom, b.geometry) group by 1;


-- Top stations from 21st and 6th

select count(*) as rides, end_station_name from citibike_2021_to_present where start_station_name = 'W 21 St & 6 Ave' group by 2 order by 1 desc;

create table top_dest as with a as (select count(*) as rides, end_station_name from citibike_2021_to_present where start_station_name = 'W 21 St & 6 Ave' group by 2 order by 1 desc) select a.*, st_point(b.lng, b.lat) as geometry from a join citibike.citibike_stations b on a.start_station_name = b.name;


-- Creating routes

install postgres;
load postgres;

ATTACH 'dbname=bike user=docker host=localhost port=25432 password=docker' AS db (TYPE postgres, READ_ONLY);

create table db.routes as select * from top_dest;

create table final_routes as SELECT * FROM postgres_query('db', "with start as ( select 'Start' as name, st_setsrid(st_makepoint(-73.994059, 40.741375)) as geom ), c as ( -- First we select all the columns from the pharm, bldgs, and wid CTEs and subqueries select start.*, top_dest.*, wid.* from start, top_dest cross join lateral ( -- For each row find the start and end way IDs with start as ( select source from ways order by the_geom <-> start.geom limit 1 ), destination as ( select source from ways order by ways.the_geom <-> top_dest.geom limit 1 ) select start.source as start_id, destination.source as end_id from start, destination ) wid ) select -- For each combination we get the sum of the cost in distance, seconds, and route length -- and we repeat this for every row, or possible combinatino sum(di.cost) as cost, sum(length) as length, sum(pt.cost_s) as seconds, st_union(st_transform(the_geom, 4326)) as route from pgr_dijkstra( 'select gid as id, source, target, cost_s * penalty as cost, reverse_cost_s * penalty as reverse_cost, st_length(st_transform(the_geom, 3857)) as length from ways join configuration using (tag_id)', array( select distinct start_id from c ), array( select distinct end_id from c ), true ) as di join ways as pt on di.edge = pt.gid group by start_vid, end_vid");


