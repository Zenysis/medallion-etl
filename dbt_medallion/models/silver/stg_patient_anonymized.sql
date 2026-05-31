{{ config(materialized='external', location='s3://silver/karatu/patient_anonymized.parquet', format='parquet') }}

-- De-identification step. Source patient rows include PII (full_name,
-- phone, national_id) which must never reach gold. We retain only the
-- attributes needed for analytics (sex, age band) plus a surrogate id.
SELECT
    id AS patient_key,
    sex,
    CASE
        WHEN age < 5   THEN '0-4'
        WHEN age < 15  THEN '5-14'
        WHEN age < 30  THEN '15-29'
        WHEN age < 50  THEN '30-49'
        WHEN age < 65  THEN '50-64'
        ELSE                '65+'
    END AS age_band
FROM {{ source('bronze', 'patient') }}
