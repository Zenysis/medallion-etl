{{ config(materialized='external', location='s3://silver/karatu/facility.parquet', format='parquet') }}

SELECT
    id,
    district_id,
    TRIM(name) AS name,
    facility_type
FROM {{ source('bronze', 'facility') }}
WHERE is_active
