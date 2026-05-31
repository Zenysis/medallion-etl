-- Create the two databases the pipeline uses.
--   demo_source: the upstream operational database (Ebola surveillance system)
--   demo_gold:   the downstream analytics database that receives gold models

CREATE DATABASE demo_source;
CREATE DATABASE demo_gold;
