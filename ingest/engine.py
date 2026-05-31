"""Bronze ingestion engine.

Reads a manifest of source specs, resolves each to a DuckDB query,
and writes the results as Parquet files to MinIO (or any S3-compatible
object store).

The engine is intentionally thin: all knowledge of *how* to read a
source lives in the resolver (sources.py); all knowledge of *what* to
read lives in the manifest (YAML). The engine just connects the two
and writes parquet.

Usage:
    engine = BronzeWriter(MinioConfig())
    results = engine.ingest_manifest(manifest_path)
"""

import logging
from dataclasses import dataclass
from datetime import date
from typing import Optional

import duckdb
import yaml

from ingest.sources import resolve

LOG = logging.getLogger(__name__)


@dataclass(frozen=True)
class MinioConfig:
    """Connection config for the MinIO (or any S3-compatible) target."""
    endpoint: str = 'localhost:9000'
    access_key: str = 'minioadmin'
    secret_key: str = 'minioadmin'
    use_ssl: bool = False
    url_style: str = 'path'


@dataclass(frozen=True)
class IngestResult:
    source_name: str
    row_count: int
    parquet_path: str
    success: bool
    error: Optional[str] = None


# Source types whose DuckDB query needs a non-built-in extension loaded
# before it can run. Anything not listed needs no extension.
DUCKDB_EXTENSIONS = {
    'postgres': 'postgres_scanner',
    'excel':    'spatial',
}


class BronzeWriter:
    """Reads source specs from a manifest and writes Parquet to object storage."""

    def __init__(self, minio: MinioConfig, bucket: str = 'bronze'):
        self.minio = minio
        self.bucket = bucket

    def ingest_manifest(
        self,
        manifest_path: str,
        partition_date: Optional[date] = None,
    ) -> list[IngestResult]:
        partition = (partition_date or date.today()).isoformat()

        with open(manifest_path) as f:
            manifest = yaml.safe_load(f)

        deployment = manifest['deployment']
        defaults = manifest.get('defaults') or {}
        sources = [{**defaults, **spec} for spec in manifest['sources']]

        LOG.info(
            'Ingesting %d sources for deployment=%s partition=%s',
            len(sources),
            deployment,
            partition,
        )

        results = []
        for spec in sources:
            result = self._ingest_one(spec, deployment, partition)
            results.append(result)
            status = 'OK' if result.success else 'FAILED'
            LOG.info(
                '  %s %s -> %s (%d rows)',
                status,
                result.source_name,
                result.parquet_path,
                result.row_count,
            )

        succeeded = sum(1 for r in results if r.success)
        LOG.info('Done: %d/%d sources ingested', succeeded, len(results))
        return results

    def _ingest_one(self, spec: dict, deployment: str, partition: str) -> IngestResult:
        name = spec['name']
        source_type = spec['type']
        object_path = f"s3://{self.bucket}/{deployment}/{partition}/{name}.parquet"

        try:
            query = resolve(spec)
        except KeyError as e:
            return IngestResult(name, 0, object_path, success=False, error=str(e))

        con = duckdb.connect(':memory:')
        try:
            self._configure_connection(con, source_type)
            row_count = con.execute(
                f"COPY ({query}) TO '{object_path}' (FORMAT PARQUET, COMPRESSION ZSTD)"
            ).fetchone()[0]
            return IngestResult(name, row_count, object_path, success=True)
        except Exception as e:
            return IngestResult(name, 0, object_path, success=False, error=str(e))
        finally:
            con.close()

    def _configure_connection(
        self, con: duckdb.DuckDBPyConnection, source_type: str
    ) -> None:
        extension = DUCKDB_EXTENSIONS.get(source_type)
        if extension:
            con.execute(f"INSTALL {extension}")
            con.execute(f"LOAD {extension}")

        # httpfs lets DuckDB read/write s3:// URLs against any S3-compatible
        # endpoint, including MinIO. The setting names are DuckDB's; they
        # happen to be prefixed s3_ even when the target is MinIO.
        con.execute("INSTALL httpfs")
        con.execute("LOAD httpfs")
        con.execute(f"SET s3_endpoint='{self.minio.endpoint}'")
        con.execute(f"SET s3_access_key_id='{self.minio.access_key}'")
        con.execute(f"SET s3_secret_access_key='{self.minio.secret_key}'")
        con.execute(f"SET s3_use_ssl={'true' if self.minio.use_ssl else 'false'}")
        con.execute(f"SET s3_url_style='{self.minio.url_style}'")
