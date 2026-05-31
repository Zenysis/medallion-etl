-- Denormalised geographic hierarchy: region -> district -> facility.
-- One row per facility, with parent region/district names inlined.
SELECT
    f.id           AS facility_id,
    f.name         AS facility_name,
    f.facility_type,
    d.id           AS district_id,
    d.name         AS district_name,
    d.population   AS district_population,
    r.id           AS region_id,
    r.name         AS region_name
FROM {{ source('silver', 'facility') }} f
JOIN {{ source('silver', 'district') }} d ON f.district_id = d.id
JOIN {{ source('silver', 'region') }}   r ON d.region_id  = r.id
