docker pull postgis/postgis:15-master

docker run --name mini-postgis -p 35432:5432 --network="host" -v /Users/mattforrest/Documents/modern-gis-live/2024-05-30-Elephants-and-Ducks/duckdb-to-postgis:/mnt/mydata -e POSTGRES_USER=admin -e POSTGRES_PASSWORD=password -d postgis/postgis:15-master

docker container exec -it mini-postgis bash

apt update
apt install osm2pgrouting
apt install osmctools

osmfilter mnt/mydata/planet.osm \
--keep="highway= route= cycleway= bicycle= segregated=" \
-o=mnt/mydata/bike_ways.osm

osm2pgrouting -f "mnt/mydata/bike_ways.osm" -d bike -p 25432 -U docker -W docker --clean