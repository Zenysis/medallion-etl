{{ config(materialized='external', location='s3://silver/karatu/symptom.parquet', format='parquet') }}

SELECT
    id,
    code,
    TRIM(name) AS name,
    severity
FROM {{ source('bronze', 'symptom') }}
