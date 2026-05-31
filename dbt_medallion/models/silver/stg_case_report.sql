{{ config(materialized='external', location='s3://silver/karatu/case_report.parquet', format='parquet') }}

SELECT
    id,
    patient_id,
    facility_id,
    onset_date,
    report_date,
    outcome,
    outcome_date,
    -- Days from onset to outcome (NULL while ongoing). Useful clinical signal.
    CASE WHEN outcome_date IS NOT NULL
         THEN date_diff('day', onset_date, outcome_date)
    END AS days_to_outcome
FROM {{ source('bronze', 'case_report') }}
WHERE report_date >= onset_date
