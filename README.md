# Medallion ETL

A runnable medallion-architecture pipeline that keeps the heavy layers
(bronze + silver) as Parquet in MinIO and only the curated gold layer in
Postgres. The demo simulates an Ebola case surveillance system for a
fictitious country, the **Republic of Karatu**.

```
 SOURCE              BRONZE                SILVER                GOLD
 ------              ------                ------                ----
 Postgres   ingest   Parquet      dbt      Parquet      dbt     Postgres
 CSV/XLSX  ------->  in MinIO  --------->  in MinIO  -------->  (curated)
 API/JSON  (DuckDB)  raw copy   (DuckDB)   cleaned    (DuckDB)
                                           anonymised
```

Why split this way: bronze and silver are huge and read rarely, so they
belong in cheap object storage (Parquet+ZSTD compresses ~20-25x vs a
Postgres heap). Gold is the only layer that needs indexed, transactional
access, so it stays in Postgres. DuckDB is the universal reader that
bridges the two.

## Quickstart

Prereqs: Docker + Docker Compose, Python 3.9+.

```bash
docker compose up -d                       # Postgres (auto-seeded) + MinIO
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt

python run_ingest.py manifests/karatu.yml manifests/facility_readiness.yml

cd dbt_medallion
dbt run --profiles-dir . --target silver
dbt run --profiles-dir . --target gold

docker exec -it medallion-postgres psql -U postgres -d demo_gold -c "\dt"
```

Full pipeline runs in under a minute on a laptop.

## How it works

### Stage 1: Source -> Bronze

DuckDB can already read Postgres, CSV, Excel, JSON, Parquet, and more.
Every source resolves to a single DuckDB `SELECT`; the engine wraps it in:

```
COPY (<resolved query>) TO 's3://bronze/.../<table>.parquet' (FORMAT PARQUET, COMPRESSION ZSTD)
```

**Adding a source = one line of YAML** ([manifests/karatu.yml](manifests/karatu.yml)):

```yaml
deployment: karatu
defaults:
  type: postgres
  connection: { host: localhost, port: 5432, dbname: demo_source, user: postgres, password: postgres }
sources:
  - { name: case_report, table: case_report }
  - { name: facility,    table: facility }
```

**Adding a new source type = one function** ([ingest/sources.py](ingest/sources.py)):

```python
def resolve_gsheet(spec): return f"SELECT * FROM read_gsheet('{spec['sheet_id']}')"
RESOLVERS['gsheet'] = resolve_gsheet
```

Each run writes a dated partition: `s3://bronze/karatu/<YYYY-MM-DD>/*.parquet`.
Re-running overwrites the partition (idempotent).

### Stage 2: Bronze -> Silver (dbt)

Silver models read bronze Parquet, apply cleaning / filtering / PII
removal, and write cleaned Parquet back to MinIO via dbt-duckdb's
`external` materialisation. Examples:

- `stg_facility` — keeps only `is_active` facilities.
- `stg_patient_anonymized` — drops name, phone, national_id; keeps sex
  and an age band (`0-4`, `5-14`, ...).
- `stg_case_report` — adds `days_to_outcome`.

The bronze source definition in [models/bronze/_sources.yml](dbt_medallion/models/bronze/_sources.yml)
uses a single expression that picks the **latest dated partition per
table** — no hardcoded dates, one definition covers every source.

### Stage 3: Silver -> Gold (dbt -> Postgres)

Gold models read silver Parquet and write curated tables straight into
Postgres using dbt-duckdb's `attach` feature ([profiles.yml](dbt_medallion/profiles.yml)).
Gold (`demo_gold`) is a separate database from the source (`demo_source`),
so the layers share no schema.

Models in the demo:

- `dim_geography`, `dim_symptom`, `dim_facility_readiness` — dimensions
- `fct_case` — one row per case, fully denormalised, no PII
- `agg_outcomes_by_region_sex` — surveillance breakdown

## Layout

```
medallion-etl/
  docker-compose.yml      Postgres (auto-seeded) + MinIO + bucket init
  setup/*.sql             Postgres init: creates demo_source, demo_gold, seeds Karatu
  ingest/                 Source -> Bronze (Python + DuckDB)
    engine.py               BronzeWriter
    sources.py              resolvers — the extension point for new source types
  manifests/*.yml         Declarative source definitions
  run_ingest.py           CLI entry point
  dbt_medallion/          Bronze -> Silver -> Gold (dbt)
    dbt_project.yml         target-gated layer config
    profiles.yml            silver (duckdb) + gold (duckdb + postgres attach)
    models/{bronze,silver,gold}/
```

## Tear-down

```bash
docker compose down -v             # stops containers and removes volumes
```
