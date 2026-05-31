-- Schema for demo_source: Ebola case surveillance in the fictitious
-- Republic of Karatu. Cases are reported by health facilities; each case
-- is linked to a patient (PII) and one or more symptoms.

\c demo_source

CREATE TABLE region (
    id    SERIAL       PRIMARY KEY,
    name  VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE district (
    id          SERIAL       PRIMARY KEY,
    region_id   INTEGER      NOT NULL REFERENCES region(id),
    name        VARCHAR(100) NOT NULL,
    population  INTEGER      NOT NULL,
    UNIQUE (region_id, name)
);

CREATE TABLE facility (
    id             SERIAL       PRIMARY KEY,
    district_id    INTEGER      NOT NULL REFERENCES district(id),
    name           VARCHAR(255) NOT NULL,
    facility_type  VARCHAR(50)  NOT NULL CHECK (facility_type IN ('hospital','clinic','health_post')),
    is_active      BOOLEAN      NOT NULL DEFAULT true
);

-- PII table. Silver layer must de-identify before anything downstream sees it.
CREATE TABLE patient (
    id            SERIAL       PRIMARY KEY,
    national_id   VARCHAR(50)  NOT NULL UNIQUE,
    full_name     VARCHAR(255) NOT NULL,
    sex           CHAR(1)      NOT NULL CHECK (sex IN ('M','F')),
    age           INTEGER      NOT NULL CHECK (age >= 0 AND age < 120),
    phone         VARCHAR(50)
);

CREATE TABLE symptom (
    id        SERIAL       PRIMARY KEY,
    code      VARCHAR(50)  NOT NULL UNIQUE,
    name      VARCHAR(255) NOT NULL,
    severity  VARCHAR(20)  NOT NULL CHECK (severity IN ('mild','moderate','severe'))
);

CREATE TABLE case_report (
    id            SERIAL      PRIMARY KEY,
    patient_id    INTEGER     NOT NULL REFERENCES patient(id),
    facility_id   INTEGER     NOT NULL REFERENCES facility(id),
    onset_date    DATE        NOT NULL,
    report_date   DATE        NOT NULL,
    outcome       VARCHAR(20) NOT NULL CHECK (outcome IN ('recovered','died','ongoing')),
    outcome_date  DATE
);

CREATE TABLE case_symptom (
    case_id     INTEGER NOT NULL REFERENCES case_report(id),
    symptom_id  INTEGER NOT NULL REFERENCES symptom(id),
    PRIMARY KEY (case_id, symptom_id)
);

CREATE INDEX case_report_facility_idx ON case_report(facility_id);
CREATE INDEX case_report_patient_idx  ON case_report(patient_id);
CREATE INDEX case_report_onset_idx    ON case_report(onset_date);
