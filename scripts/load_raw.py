"""Load the raw CSVs into DuckDB. Customers land in crm, orders in erp."""

import duckdb

SCHEMAS = {
    "crm": ("customers",),
    "erp": ("orders", "order_items", "payments"),
}

con = duckdb.connect("data/qdbd.duckdb")
for schema, tables in SCHEMAS.items():
    con.execute(f"create schema if not exists {schema}")
    for name in tables:
        con.execute(
            f"create or replace table {schema}.{name} as "
            f"select * from read_csv('data/raw/{name}.csv', header=true)"
        )
        con.execute(f"drop table if exists raw.{name}")
        con.execute(f"drop table if exists main.{name}")
con.execute("drop schema if exists raw")
con.close()
