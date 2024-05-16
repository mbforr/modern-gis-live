{{ config(materialized='table') }}

with apr as (select * from read_parquet({{ source('overture_april', '2024-04-16-beta.0')}}, filename=true, hive_partitioning=1) where bbox.ymin > 52.338271
AND bbox.ymax < 52.675509
AND bbox.xmin > 13.088345
AND bbox.xmax < 13.761161),
jan as (select * from read_parquet({{ source('overture_jan', '2024-01-17-alpha.0')}}, filename=true, hive_partitioning=1) where bbox.miny > 52.338271
AND bbox.maxy < 52.675509
AND bbox.minx > 13.088345
AND bbox.maxx < 13.761161)

select apr.*
from apr
left join jan ON apr.id = jan.id
where jan.id is null

