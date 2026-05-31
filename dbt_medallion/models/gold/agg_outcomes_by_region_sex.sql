-- Region x sex x outcome aggregation. Standard surveillance breakdown:
-- shows case-fatality ratio disaggregated by sex across regions.
SELECT
    r.name AS region_name,
    p.sex,
    c.outcome,
    count(*) AS case_count
FROM {{ source('silver', 'case_report')        }} c
JOIN {{ source('silver', 'patient_anonymized') }} p ON c.patient_id  = p.patient_key
JOIN {{ source('silver', 'facility')           }} f ON c.facility_id = f.id
JOIN {{ source('silver', 'district')           }} d ON f.district_id = d.id
JOIN {{ source('silver', 'region')             }} r ON d.region_id   = r.id
GROUP BY r.name, p.sex, c.outcome
