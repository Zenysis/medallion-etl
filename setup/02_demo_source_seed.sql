\c demo_source

-- Geography: 5 regions, 15 districts, 25 facilities in the Republic of Karatu.

INSERT INTO region (name) VALUES
    ('Northern'), ('Central'), ('Eastern'), ('Western'), ('Coastal');

INSERT INTO district (region_id, name, population) VALUES
    (1, 'Bandiro',     185000),
    (1, 'Kelima',      142000),
    (1, 'Tanjira',      96000),
    (2, 'Mwasini',     310000),
    (2, 'Kotari',      225000),
    (2, 'Nyamoro',     178000),
    (3, 'Dombe',       121000),
    (3, 'Sakuli',       89000),
    (3, 'Ireti',       147000),
    (4, 'Halumba',     205000),
    (4, 'Geredi',      152000),
    (4, 'Onsuru',       78000),
    (5, 'Kibanda',     268000),
    (5, 'Maziri',      194000),
    (5, 'Pwaka',       102000);

INSERT INTO facility (district_id, name, facility_type) VALUES
    ( 1, 'Bandiro General Hospital',  'hospital'),
    ( 1, 'Bandiro East Clinic',       'clinic'),
    ( 2, 'Kelima Health Post',        'health_post'),
    ( 3, 'Tanjira District Hospital', 'hospital'),
    ( 4, 'Mwasini Central Hospital',  'hospital'),
    ( 4, 'Mwasini North Clinic',      'clinic'),
    ( 4, 'Mwasini South Health Post', 'health_post'),
    ( 5, 'Kotari Mission Clinic',     'clinic'),
    ( 5, 'Kotari Rural Health Post',  'health_post'),
    ( 6, 'Nyamoro Community Clinic',  'clinic'),
    ( 7, 'Dombe District Hospital',   'hospital'),
    ( 7, 'Dombe Health Post',         'health_post'),
    ( 8, 'Sakuli Clinic',             'clinic'),
    ( 9, 'Ireti Regional Hospital',   'hospital'),
    ( 9, 'Ireti West Clinic',         'clinic'),
    (10, 'Halumba Teaching Hospital', 'hospital'),
    (10, 'Halumba South Clinic',      'clinic'),
    (11, 'Geredi Clinic',             'clinic'),
    (11, 'Geredi Hilltop Health Post','health_post'),
    (12, 'Onsuru Border Clinic',      'clinic'),
    (13, 'Kibanda Port Hospital',     'hospital'),
    (13, 'Kibanda Dockside Clinic',   'clinic'),
    (14, 'Maziri Town Clinic',        'clinic'),
    (14, 'Maziri Outpost',            'health_post'),
    (15, 'Pwaka Coastal Clinic',      'clinic');

-- Symptom catalog: typical Ebola clinical signs.

INSERT INTO symptom (code, name, severity) VALUES
    ('FEV',  'Fever',                'moderate'),
    ('HDA',  'Headache',             'mild'),
    ('FAT',  'Fatigue',              'mild'),
    ('MYL',  'Muscle pain',          'mild'),
    ('VOM',  'Vomiting',             'moderate'),
    ('DIA',  'Diarrhoea',            'moderate'),
    ('ABD',  'Abdominal pain',       'moderate'),
    ('RSH',  'Rash',                 'mild'),
    ('SOR',  'Sore throat',          'mild'),
    ('HEM',  'Unexplained bleeding', 'severe');

-- Patients (PII; silver layer will anonymise these).

INSERT INTO patient (national_id, full_name, sex, age, phone) VALUES
    ('KAR-1001', 'Amani Ngolo',         'F', 34, '+44170000001'),
    ('KAR-1002', 'Bakari Mtemi',        'M', 41, '+44170000002'),
    ('KAR-1003', 'Chausiku Nuru',       'F', 27, '+44170000003'),
    ('KAR-1004', 'Daudi Ramadhan',      'M',  9, NULL),
    ('KAR-1005', 'Esha Tumaini',        'F', 52, '+44170000005'),
    ('KAR-1006', 'Faraji Salim',        'M', 30, '+44170000006'),
    ('KAR-1007', 'Gisele Boko',         'F', 19, '+44170000007'),
    ('KAR-1008', 'Hamadi Kweli',        'M', 64, NULL),
    ('KAR-1009', 'Imani Joto',          'F', 23, '+44170000009'),
    ('KAR-1010', 'Juma Bahari',         'M', 38, '+44170000010'),
    ('KAR-1011', 'Kesia Lulu',          'F', 45, '+44170000011'),
    ('KAR-1012', 'Lameck Soko',         'M', 12, NULL),
    ('KAR-1013', 'Maua Pendo',          'F', 67, '+44170000013'),
    ('KAR-1014', 'Nasoro Idd',          'M', 29, '+44170000014'),
    ('KAR-1015', 'Olivia Kwena',        'F', 33, '+44170000015'),
    ('KAR-1016', 'Pendo Asha',          'F',  6, NULL),
    ('KAR-1017', 'Qasim Toba',          'M', 50, '+44170000017'),
    ('KAR-1018', 'Rehema Ali',          'F', 28, '+44170000018'),
    ('KAR-1019', 'Salim Mawazo',        'M', 16, '+44170000019'),
    ('KAR-1020', 'Tausi Mwema',         'F', 71, NULL),
    ('KAR-1021', 'Uledi Marombo',       'M', 26, '+44170000021'),
    ('KAR-1022', 'Vumilia Heri',        'F', 39, '+44170000022'),
    ('KAR-1023', 'Wema Sauti',          'F', 14, NULL),
    ('KAR-1024', 'Yusuf Chui',          'M', 55, '+44170000024'),
    ('KAR-1025', 'Zara Imara',          'F', 21, '+44170000025'),
    ('KAR-1026', 'Abasi Penda',         'M', 47, '+44170000026'),
    ('KAR-1027', 'Bina Furaha',         'F', 32, '+44170000027'),
    ('KAR-1028', 'Chacha Onyo',         'M',  8, NULL),
    ('KAR-1029', 'Dalila Nia',          'F', 60, '+44170000029'),
    ('KAR-1030', 'Eli Mzuri',           'M', 24, '+44170000030');

-- Case reports: 60 cases distributed across facilities; outcomes weighted
-- to ~55% recovered, ~30% died, ~15% ongoing. onset_date spans 4 months.
-- Some patients have multiple cases over time (chronic re-presentations).

INSERT INTO case_report (patient_id, facility_id, onset_date, report_date, outcome, outcome_date) VALUES
    ( 1,  1, '2026-01-08', '2026-01-09', 'recovered', '2026-01-22'),
    ( 2,  1, '2026-01-12', '2026-01-13', 'died',      '2026-01-19'),
    ( 3,  2, '2026-01-15', '2026-01-16', 'recovered', '2026-01-30'),
    ( 4,  3, '2026-01-18', '2026-01-20', 'recovered', '2026-02-02'),
    ( 5,  4, '2026-01-22', '2026-01-23', 'died',      '2026-02-01'),
    ( 6,  5, '2026-01-25', '2026-01-25', 'recovered', '2026-02-09'),
    ( 7,  5, '2026-01-28', '2026-01-29', 'recovered', '2026-02-12'),
    ( 8,  6, '2026-02-01', '2026-02-02', 'died',      '2026-02-08'),
    ( 9,  7, '2026-02-03', '2026-02-04', 'recovered', '2026-02-17'),
    (10,  8, '2026-02-06', '2026-02-07', 'recovered', '2026-02-21'),
    (11,  9, '2026-02-08', '2026-02-09', 'died',      '2026-02-15'),
    (12, 10, '2026-02-10', '2026-02-11', 'recovered', '2026-02-25'),
    (13, 11, '2026-02-12', '2026-02-13', 'died',      '2026-02-18'),
    (14, 11, '2026-02-14', '2026-02-15', 'recovered', '2026-02-28'),
    (15, 12, '2026-02-16', '2026-02-17', 'recovered', '2026-03-02'),
    (16, 13, '2026-02-19', '2026-02-20', 'recovered', '2026-03-05'),
    (17, 14, '2026-02-21', '2026-02-22', 'died',      '2026-02-27'),
    (18, 14, '2026-02-23', '2026-02-24', 'recovered', '2026-03-09'),
    (19, 15, '2026-02-26', '2026-02-27', 'recovered', '2026-03-12'),
    (20, 16, '2026-02-28', '2026-03-01', 'died',      '2026-03-06'),
    (21, 16, '2026-03-02', '2026-03-03', 'recovered', '2026-03-17'),
    (22, 17, '2026-03-04', '2026-03-05', 'recovered', '2026-03-19'),
    (23, 18, '2026-03-06', '2026-03-07', 'died',      '2026-03-13'),
    (24, 19, '2026-03-09', '2026-03-10', 'recovered', '2026-03-24'),
    (25, 20, '2026-03-11', '2026-03-12', 'recovered', '2026-03-26'),
    (26, 21, '2026-03-13', '2026-03-14', 'died',      '2026-03-20'),
    (27, 21, '2026-03-15', '2026-03-16', 'recovered', '2026-03-30'),
    (28, 22, '2026-03-18', '2026-03-19', 'recovered', '2026-04-02'),
    (29, 23, '2026-03-20', '2026-03-21', 'died',      '2026-03-27'),
    (30, 24, '2026-03-22', '2026-03-23', 'recovered', '2026-04-06'),
    ( 1, 25, '2026-03-25', '2026-03-26', 'recovered', '2026-04-09'),
    ( 2,  1, '2026-03-27', '2026-03-28', 'recovered', '2026-04-11'),
    ( 3,  2, '2026-03-30', '2026-03-31', 'died',      '2026-04-05'),
    ( 4,  4, '2026-04-02', '2026-04-03', 'recovered', '2026-04-17'),
    ( 5,  5, '2026-04-04', '2026-04-05', 'recovered', '2026-04-19'),
    ( 6,  6, '2026-04-07', '2026-04-08', 'died',      '2026-04-14'),
    ( 7,  7, '2026-04-09', '2026-04-10', 'recovered', '2026-04-24'),
    ( 8,  8, '2026-04-11', '2026-04-12', 'recovered', '2026-04-26'),
    ( 9,  9, '2026-04-13', '2026-04-14', 'died',      '2026-04-20'),
    (10, 10, '2026-04-15', '2026-04-16', 'recovered', '2026-04-30'),
    (11, 12, '2026-04-17', '2026-04-18', 'recovered', '2026-05-02'),
    (12, 13, '2026-04-19', '2026-04-20', 'died',      '2026-04-26'),
    (13, 14, '2026-04-22', '2026-04-23', 'recovered', '2026-05-07'),
    (14, 15, '2026-04-24', '2026-04-25', 'recovered', '2026-05-09'),
    (15, 16, '2026-04-26', '2026-04-27', 'died',      '2026-05-03'),
    (16, 17, '2026-04-28', '2026-04-29', 'recovered', '2026-05-12'),
    (17, 18, '2026-04-30', '2026-05-01', 'recovered', '2026-05-15'),
    (18, 19, '2026-05-02', '2026-05-03', 'died',      '2026-05-09'),
    (19, 20, '2026-05-04', '2026-05-05', 'recovered', '2026-05-19'),
    (20, 22, '2026-05-06', '2026-05-07', 'recovered', '2026-05-21'),
    (21, 23, '2026-05-08', '2026-05-09', 'died',      '2026-05-15'),
    (22, 24, '2026-05-10', '2026-05-11', 'ongoing',   NULL),
    (23, 25, '2026-05-12', '2026-05-13', 'ongoing',   NULL),
    (24,  1, '2026-05-14', '2026-05-15', 'ongoing',   NULL),
    (25,  3, '2026-05-16', '2026-05-17', 'ongoing',   NULL),
    (26,  5, '2026-05-18', '2026-05-19', 'ongoing',   NULL),
    (27,  7, '2026-05-20', '2026-05-21', 'ongoing',   NULL),
    (28,  9, '2026-05-22', '2026-05-23', 'ongoing',   NULL),
    (29, 11, '2026-05-24', '2026-05-25', 'ongoing',   NULL),
    (30, 13, '2026-05-26', '2026-05-27', 'ongoing',   NULL);

-- Case-to-symptom links: most cases have fever + headache plus a varying mix.

INSERT INTO case_symptom (case_id, symptom_id)
SELECT cr.id, s.id
FROM case_report cr
CROSS JOIN symptom s
WHERE
    s.code = 'FEV'                                                     -- everyone has fever
    OR (s.code = 'HDA' AND cr.id % 2 = 0)
    OR (s.code = 'FAT' AND cr.id % 3 = 0)
    OR (s.code = 'MYL' AND cr.id % 4 = 0)
    OR (s.code = 'VOM' AND cr.id % 5 = 0)
    OR (s.code = 'DIA' AND cr.id % 6 = 0)
    OR (s.code = 'ABD' AND cr.id % 7 = 0)
    OR (s.code = 'RSH' AND cr.id % 8 = 0)
    OR (s.code = 'SOR' AND cr.id % 9 = 0)
    OR (s.code = 'HEM' AND cr.outcome = 'died');                       -- hemorrhage strongly correlates with mortality
