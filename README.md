# qdbd Demo

A small, end-to-end **dbt + DuckDB** project for trying [quickdbd-cli (qdbd)](https://github.com/MarkPhamm/quickdbd-cli): keep database diagrams as text in Git, validate them against a dbt project, review changes in pull requests, and publish browsable ERDs.

The demo uses four CSV-backed source tables, dbt staging models, and a simple dimensional mart. qdbd reads the diagram definitions and dbt metadata; **it does not connect to the database to render diagrams**.

## What is in this repository?

```text
data/raw/*.csv
      │
      ▼  scripts/load_raw.py
DuckDB: crm.customers + erp.{orders,order_items,payments}
      │
      ▼  dbt source + staging models
models/staging/
      │
      ▼  dbt transformations
models/marts/
      │
      ├── dim_customers, dim_dates
      └── fct_orders, fct_order_items, fct_payments

docs/erd/source/  ── source-table ERDs
docs/erd/models/  ── dimensional-mart ERDs
         │
         ▼
   qdbd check / build → HTML diagrams
```

| Path | Purpose |
| --- | --- |
| `data/raw/` | Example CRM and ERP CSV inputs |
| `scripts/load_raw.py` | Loads the CSVs into a local DuckDB file |
| `models/staging/` | dbt source declarations and staging SQL/YAML |
| `models/marts/` | Customer/date dimensions and order/item/payment facts |
| `docs/erd/source/` | qdbd text definitions for source tables |
| `docs/erd/models/` | qdbd text definitions for mart tables |
| `docs/erd/**/qdbd.layout.json` | Saved diagram layout positions |
| `.github/workflows/` | PR schema checks, ERD previews, and Pages deployment |

## Quick start

**Requirements:** Python 3.12 (used in the Pages workflow) and Git. The Python dependencies are pinned in `requirements.txt`, including `dbt-duckdb` and `quickdbd-cli==0.6.11`.

From the repository root:

```bash
git clone https://github.com/MarkPhamm/qdbd_demo.git
cd qdbd_demo

python3 -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements.txt

# Create the local DuckDB database from the sample CSVs
python scripts/load_raw.py

# Run dbt against the profile committed in this repository
dbt debug --profiles-dir .
dbt build --profiles-dir .

# Validate both sets of diagrams
qdbd check --strict docs/erd/source/ docs/erd/models/

# Generate a browsable HTML site
qdbd build --strict docs/erd/source/ docs/erd/models/ --site site/
```

Open the generated HTML files under `site/` in a browser. The local DuckDB database is written to `data/qdbd.duckdb`; you can regenerate it by rerunning the loader.

> On Windows, activate the virtual environment with `.venv\Scripts\activate` instead.

### Explore or edit an ERD

The source and mart diagrams are intentionally separate:

- **Source:** `docs/erd/source/crm.txt` and `erp.txt` describe CRM/ERP tables and their foreign keys.
- **Mart:** `docs/erd/models/dims.txt` and `facts.txt` describe dimensions, facts, and relationships.

For example, a relationship in `docs/erd/models/facts.txt` looks like:

```text
fct_orders
----
order_id PK int
customer_id int FK >- dim_customers.customer_id
```

Each diagram file also carries a `# @dbt: ../../..` directive pointing back to the dbt project root. Edit the text definitions (and their saved layout JSON when needed), then rerun `qdbd check` and `qdbd build` to see the result.

For qdbd syntax, commands, and supported flags, consult [qdbd.dev](https://qdbd.dev/).

## CI/CD and pull-request previews

This repository demonstrates a **feature → QA → main** promotion flow:

| Event | Workflow | Behavior |
| --- | --- | --- |
| PR targeting `qa` | `feature CI` | Runs strict qdbd checks |
| PR targeting `qa` | `feature CD` | Builds a diagram diff, comments on the PR, and uploads an HTML artifact |
| PR targeting `main` | `release CI` | Checks and publishes a diagram diff artifact/comment |
| Push to `qa` or `main` | `release CD` | Checks/builds ERDs; `qa` uploads an artifact |
| Successful eligible workflow run | `pages` | Rebuilds the main site and previews for open PRs, then deploys GitHub Pages |

The Pages workflow is designed to serve the main-branch diagrams at the site root and open PR diagrams under `/pr/<number>/`, diffed against each PR's target branch. The PR index is generated at `/pr/`. Availability depends on GitHub Pages being enabled and the deployment workflow succeeding.

**Note:** The workflows validate qdbd diagrams; they do not run the CSV loader or `dbt build` as part of CI.

## Pre-commit validation

The repository includes a pre-commit hook using `quickdbd-cli@v0.6.11`. Once `pre-commit` is installed, enable it with:

```bash
python -m pip install pre-commit
pre-commit install
pre-commit run --all-files
```

The hook checks each diagram folder as a unit so cross-file foreign keys can resolve.

## Making a change

1. Update the relevant dbt SQL/YAML and/or `docs/erd/` schema text.
2. If changing sample source data, run `python scripts/load_raw.py` again and rebuild dbt.
3. Run `dbt build --profiles-dir .` and `qdbd check --strict docs/erd/source/ docs/erd/models/` locally.
4. Open a feature PR into `qa` to review the diagram diff and checks.
5. Promote `qa` into `main` via a release PR.

## Links

- [quickdbd-cli source and GitHub Action](https://github.com/MarkPhamm/quickdbd-cli)
- [qdbd documentation](https://qdbd.dev/)
- [dbt documentation](https://docs.getdbt.com/)
- [DuckDB documentation](https://duckdb.org/docs/)
