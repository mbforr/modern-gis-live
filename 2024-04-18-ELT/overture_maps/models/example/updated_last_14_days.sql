
{{ config(materialized='table') }}

select *
from read_parquet({{ source('overture_april', '2024-04-16-beta.0')}}, filename=true, hive_partitioning=1)
where cast(update_time as timestamp) between cast('2024-04-16' as timestamp) - INTERVAL 14 DAY and  cast('2024-04-16' as timestamp)
and bbox.ymin > 36.9924
AND bbox.ymax < 41.0034
AND bbox.xmin > -109.0602
AND bbox.xmax < -102.0416
