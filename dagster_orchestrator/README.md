# dagster_orchestrator

Data engineering pipeline orchestrated with **Dagster**, ingesting data from **MongoDB Atlas** (`sample_mflix` sample dataset) into **Snowflake** using **dlt (data load tool)**, followed by downstream transformations and a simple ML-based visualization (TSNE embeddings).

---

## What this project does

1. **Ingestion (MongoDB → Snowflake)**
   A `@dlt_assets`-based Dagster asset extracts the `comments` and `embedded_movies` collections from a MongoDB Atlas cluster and loads them into Snowflake, using `merge` write disposition to keep data up to date.

2. **Transformation (Snowflake)**
   Downstream Dagster assets query Snowflake directly (via `SnowflakeResource`) to compute:
   - `user_engagement`: number of comments per movie
   - `top_movies_by_month`: best-rated movie per genre for a given time window
   - `top_movies_by_engagement`: a bar chart of the most-commented movies

3. **Adhoc requests + sensor**
   An `@sensor` (`adhoc_sensor`) watches an `adhoc/` folder for new or modified `.json` request files and automatically triggers a Dagster run for each one — useful for on-demand embedding generation.

---

## Tech stack

- **Dagster** — orchestration (assets, sensors, resources)
- **dagster-embedded-elt (dlt)** — MongoDB → Snowflake ingestion
- **dagster-snowflake** — native Snowflake resource for querying/transforming
- **pymongo** — MongoDB driver
- **pandas** — data wrangling
- **scikit-learn** — TSNE embeddings for the visualization asset
- **matplotlib** — chart generation

---

## Project structure

\```
dagster_orchestrator/
├── dagster_orchestrator/ # Dagster package
│ ├── **init**.py
│ ├── definitions.py # Definitions object (assets + resources)
│ ├── mongodb/ # dlt source definition for MongoDB
│ └── assets/
│ ├── mongodb.py # @dlt_assets — MongoDB → Snowflake ingestion
│ └── movies.py # transformation assets (Snowflake)
├── dagster_orchestrator_tests/
├── adhoc/ # drop .json files here to trigger adhoc runs
├── data/ # generated CSVs / PNGs (gitignored)
├── pyproject.toml
└── README.md
\```

---

## Requirements

- Python `>=3.10,<3.15`
- A MongoDB Atlas cluster with the `sample_mflix` sample dataset loaded
- A Snowflake account with a warehouse, database, and role provisioned

---

## Setup

\```bash
cd dagster_orchestrator

# create and activate a virtual environment

python3.11 -m venv .venv
source .venv/bin/activate

pip install --upgrade pip
pip install -e ".[dev]"
\```

### Credentials

This project separates credentials into **two places**, matching how each tool resolves them:

**1. `dlt` credentials** — used by the ingestion asset (MongoDB source + Snowflake destination). Create `dagster_orchestrator/.dlt/secrets.toml` (gitignored):

\```toml
[sources.mongodb]
connection_url = "mongodb+srv://<user>:<password>@<cluster-url>/?retryWrites=true&w=majority"

[destination.snowflake.credentials]
database = "dagster_db"
password = "<snowflake_password>"
username = "<snowflake_user>"
host = "<snowflake_account_identifier>" # e.g. ORG-ACCOUNT, no .snowflakecomputing.com suffix
warehouse = "dagster_wh"
role = "dagster_role"
\```

**2. Dagster resource credentials** — used by the transformation assets (`SnowflakeResource`, via `EnvVar`). Create a `.env` file in the project root (gitignored):

\```bash
SNOWFLAKE_ACCOUNT="<snowflake_account_identifier>"
SNOWFLAKE_USER="<snowflake_user>"
SNOWFLAKE_PASSWORD="<snowflake_password>"
\```

> Both files are gitignored — never commit real credentials. See `.gitignore`.

---

## Running

\```bash
dagster dev
\```

Open the Dagster UI (usually `http://localhost:3000`), go to **Assets → Lineage**, and materialize the assets. Order matters: `dlt_mongodb_comments` / `dlt_mongodb_embedded_movies` first, then `user_engagement` and `top_movies_by_month`, then `top_movies_by_engagement`.

---

## Adhoc runs

Drop a `.json` config file into `adhoc/` (see `adhoc/ratings.json` for an example) — the `adhoc_sensor` picks up new or modified files automatically and triggers a run with that config.

---

## Notes

- Local Dagster instance data (`.tmp_dagster_home_*/`) and generated outputs in `data/` are gitignored — they're regenerated on each run.
- If you rotate MongoDB or Snowflake credentials, remember to update **both** `.dlt/secrets.toml` and `.env` — they are separate credential stores read by different tools (`dlt` vs. Dagster's `EnvVar`).
