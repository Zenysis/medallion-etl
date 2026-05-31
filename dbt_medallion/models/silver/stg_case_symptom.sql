{{ config(materialized='external', location='s3://silver/karatu/case_symptom.parquet', format='parquet') }}

SELECT
    case_id,
    symptom_id
FROM {{ source('bronze', 'case_symptom') }}
