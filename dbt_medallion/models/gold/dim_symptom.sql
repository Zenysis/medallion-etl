SELECT
    id   AS symptom_id,
    code,
    name,
    severity
FROM {{ source('silver', 'symptom') }}
