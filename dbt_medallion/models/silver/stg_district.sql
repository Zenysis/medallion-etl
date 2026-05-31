{{ config(materialized='external', location='s3://silver/karatu/district.parquet', format='parquet') }}

SELECT
    id,
    region_id,
    TRIM(name) AS name,
    population
FROM {{ source('bronze', 'district') }}
WHERE population > 0
