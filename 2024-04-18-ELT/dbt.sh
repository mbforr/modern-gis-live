python3 -m venv dbt-env  

source dbt-env/bin/activate

pip install dbt-core

pip install dbt-duckdb

dbt --version

dbt init overture_maps

dbt debug

dbt run

pip install dbt-bigquery

dbt init overture_bigquery