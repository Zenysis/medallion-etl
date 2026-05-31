"""Source resolvers: map a source type to a DuckDB SQL query.

Every data source -- Postgres table, CSV file, Excel sheet, API dump,
or raw parquet -- reduces to a single DuckDB SELECT statement.  A resolver
is a function that takes a source spec dict and returns that statement.

To add a new source type, write a resolver function and register it
in RESOLVERS.  That's the only extension point.
"""

from typing import Callable


def _pg_connection_string(connection: dict) -> str:
    parts = [
        f"host={connection['host']}",
        f"port={connection.get('port', 5432)}",
        f"dbname={connection['dbname']}",
        f"user={connection['user']}",
    ]
    if 'password' in connection:
        parts.append(f"password={connection['password']}")
    return ' '.join(parts)


def resolve_postgres(spec: dict) -> str:
    conn = _pg_connection_string(spec['connection'])
    schema = spec.get('schema', 'public')
    table = spec['table']
    return f"SELECT * FROM postgres_scan('{conn}', '{schema}', '{table}')"


def resolve_csv(spec: dict) -> str:
    path = spec['path']
    opts = spec.get('options', {})
    option_parts = []
    for key, value in opts.items():
        if isinstance(value, bool):
            option_parts.append(f"{key}={str(value).lower()}")
        elif isinstance(value, str):
            option_parts.append(f"{key}='{value}'")
        else:
            option_parts.append(f"{key}={value}")
    options_str = ', '.join(option_parts)
    if options_str:
        return f"SELECT * FROM read_csv('{path}', {options_str})"
    return f"SELECT * FROM read_csv('{path}')"


def resolve_excel(spec: dict) -> str:
    path = spec['path']
    sheet = spec.get('sheet', '')
    if sheet:
        return f"SELECT * FROM st_read('{path}', layer='{sheet}')"
    return f"SELECT * FROM st_read('{path}')"


def resolve_json(spec: dict) -> str:
    path = spec['path']
    return f"SELECT * FROM read_json_auto('{path}')"


def resolve_parquet(spec: dict) -> str:
    path = spec['path']
    return f"SELECT * FROM read_parquet('{path}')"


def resolve_duckdb(spec: dict) -> str:
    """Read from an existing DuckDB database file (e.g., dlt output)."""
    database = spec['database']
    table = spec['table']
    schema = spec.get('schema', 'main')
    return f"ATTACH '{database}' AS src (READ_ONLY); SELECT * FROM src.{schema}.{table}"


def resolve_sql(spec: dict) -> str:
    """Raw SQL query -- the escape hatch for anything DuckDB can express."""
    return spec['query']


SourceResolver = Callable[[dict], str]

RESOLVERS: dict[str, SourceResolver] = {
    'postgres': resolve_postgres,
    'csv': resolve_csv,
    'excel': resolve_excel,
    'json': resolve_json,
    'parquet': resolve_parquet,
    'duckdb': resolve_duckdb,
    'sql': resolve_sql,
}


def resolve(spec: dict) -> str:
    """Resolve a source spec to a DuckDB SQL query.

    Raises KeyError if the source type is not registered.
    """
    source_type = spec['type']
    resolver = RESOLVERS.get(source_type)
    if resolver is None:
        registered = ', '.join(sorted(RESOLVERS))
        raise KeyError(
            f"Unknown source type '{source_type}'. " f"Registered types: {registered}"
        )
    return resolver(spec)
