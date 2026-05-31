{{ config(materialized='external', location='s3://silver/karatu/region.parquet', format='parquet') }}

SELECT
    id,
    TRIM(name) AS name
FROM {{ source('bronze', 'region') }}
