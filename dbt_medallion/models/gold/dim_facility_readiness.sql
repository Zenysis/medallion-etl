-- Cross-source enrichment: joins the external readiness CSV with the
-- Postgres-derived geographic hierarchy. Facilities present in the readiness
-- assessment but missing from the surveillance system surface as NULL geo_id.
SELECT
    fr.facility_name,
    fr.district_name,
    fr.has_isolation_unit,
    fr.has_ppe_stock,
    fr.trained_staff,
    fr.last_drill_date,
    fr.notes,
    f.id           AS facility_id,
    f.facility_type,
    r.name         AS region_name
FROM {{ source('silver', 'facility_readiness') }} fr
LEFT JOIN {{ source('silver', 'facility') }} f ON f.name = fr.facility_name
LEFT JOIN {{ source('silver', 'district') }} d ON f.district_id = d.id
LEFT JOIN {{ source('silver', 'region')   }} r ON d.region_id   = r.id
