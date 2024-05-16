
{{ config(materialized='ephemeral') }}

CALL `carto-un`.carto.CREATE_SPATIAL_INDEX_TILESET(
  'cartodb-gcp-solutions-eng-team.matt.overture_geom_20240416',
  'cartodb-gcp-solutions-eng-team.matt.overture_tiles_20240416',
  R'''{
    "spatial_index_column": "h3:h3",
    "resolution": 11,
    "resolution_min": 0,
    "resolution_max": 8,
    "aggregation_resolution": 6,
    "properties": {
      "population": {
        "formula": "COUNT(id)",
        "type": "Number"
      }
    }
  }'''
);