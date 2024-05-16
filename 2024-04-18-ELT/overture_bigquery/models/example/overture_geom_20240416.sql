
/*
    Welcome to your first dbt model!
    Did you know that you can also configure models directly within SQL files?
    This will override configurations stated in dbt_project.yml

    Try changing "table" to "view" below
*/

{{ config(materialized='table') }}

select 
*,
st_geogfromwkb(geometry, make_valid => true) as geom,
timestamp(update_time) as timestamp,
`carto-un`.carto.H3_FROMGEOGPOINT(st_centroid(st_geogfromwkb(geometry, make_valid => true)), 11) as h3
from `cartodb-gcp-solutions-eng-team.matt.overture-buildings-20240416`

/*
    Uncomment the line below to remove records with null `id` values
*/

-- where id is not null
