-- One row per case, fully denormalised. Joins anonymised patient demographics,
-- facility geography, and a per-case symptom count. PII never enters this table.
WITH symptom_counts AS (
    SELECT case_id, count(*) AS symptom_count
    FROM {{ source('silver', 'case_symptom') }}
    GROUP BY case_id
)
SELECT
    c.id              AS case_id,
    c.onset_date,
    c.report_date,
    c.outcome,
    c.outcome_date,
    c.days_to_outcome,
    p.sex,
    p.age_band,
    f.id              AS facility_id,
    f.name            AS facility_name,
    f.facility_type,
    d.name            AS district_name,
    r.name            AS region_name,
    COALESCE(s.symptom_count, 0) AS symptom_count
FROM {{ source('silver', 'case_report')        }} c
JOIN {{ source('silver', 'patient_anonymized') }} p ON c.patient_id  = p.patient_key
JOIN {{ source('silver', 'facility')           }} f ON c.facility_id = f.id
JOIN {{ source('silver', 'district')           }} d ON f.district_id = d.id
JOIN {{ source('silver', 'region')             }} r ON d.region_id   = r.id
LEFT JOIN symptom_counts s ON s.case_id = c.id
