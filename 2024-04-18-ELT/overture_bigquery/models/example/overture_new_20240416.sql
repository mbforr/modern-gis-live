
-- Use the `ref` function to select from other models

select *
from `cartodb-gcp-solutions-eng-team.matt.overture_geom_20240416`
where timestamp between timestamp_sub(timestamp, INTERVAL 14 DAY) and TIMESTAMP("2024-04-16 00:00:00+00") 
