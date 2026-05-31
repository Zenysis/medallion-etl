{{ config(materialized='external', location='s3://silver/karatu/facility_readiness.parquet', format='parquet') }}

SELECT
    TRIM(facility_name)             AS facility_name,
    TRIM(district)                  AS district_name,
    has_isolation_unit,
    has_ppe_stock,
    trained_staff,
    CAST(NULLIF(TRIM(CAST(last_drill_date AS VARCHAR)), '') AS DATE) AS last_drill_date,
    NULLIF(TRIM(notes), '')         AS notes
FROM {{ source('bronze', 'facility_readiness') }}
WHERE facility_name IS NOT NULL
