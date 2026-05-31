"""CLI entry point for bronze ingestion.

Usage:
    python run_ingest.py manifests/karatu.yml
    python run_ingest.py manifests/karatu.yml --date 2026-05-28
    python run_ingest.py manifests/*.yml
"""

import argparse
import logging
import sys
from datetime import date

from ingest.engine import BronzeWriter, MinioConfig


def main():
    parser = argparse.ArgumentParser(description='Ingest sources to bronze parquet')
    parser.add_argument('manifests', nargs='+', help='Path(s) to manifest YAML files')
    parser.add_argument(
        '--date',
        type=date.fromisoformat,
        default=None,
        help='Partition date (default: today)',
    )
    parser.add_argument('--bucket', default='bronze', help='Target MinIO bucket')
    parser.add_argument('--minio-endpoint',   default='localhost:9000')
    parser.add_argument('--minio-access-key', default='minioadmin')
    parser.add_argument('--minio-secret-key', default='minioadmin')
    parser.add_argument('--minio-use-ssl',    action='store_true')
    args = parser.parse_args()

    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s %(levelname)s %(message)s',
        datefmt='%H:%M:%S',
    )

    minio = MinioConfig(
        endpoint=args.minio_endpoint,
        access_key=args.minio_access_key,
        secret_key=args.minio_secret_key,
        use_ssl=args.minio_use_ssl,
    )
    writer = BronzeWriter(minio, bucket=args.bucket)

    all_results = []
    for manifest_path in args.manifests:
        results = writer.ingest_manifest(manifest_path, partition_date=args.date)
        all_results.extend(results)

    failures = [r for r in all_results if not r.success]
    if failures:
        for f in failures:
            logging.error('FAILED: %s -- %s', f.source_name, f.error)
        sys.exit(1)


if __name__ == '__main__':
    main()
