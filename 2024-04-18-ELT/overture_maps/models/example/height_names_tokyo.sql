{{ config(materialized='table') }}

select * from read_parquet({{ source('overture_april', '2024-04-16-beta.0')}}, filename=true, hive_partitioning=1)
where height is not null
and names is not null
and bbox.ymin > 34.7965
AND bbox.ymax < 37.0499
AND bbox.xmin > 138.6013
AND bbox.xmax < 141.442


