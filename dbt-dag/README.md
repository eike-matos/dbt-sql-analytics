# dbt-dag — dbt + Snowflake + Airflow

This project (`dbt-dag`) runs **Apache Airflow** locally using the **Astro CLI**.
It is used to orchestrate the `de_pipeline` dbt project on Snowflake.

Below you'll find:

- What's inside this project
- Step-by-step instructions to run Airflow locally with Astro

---

## Tech stack

- **Apache Airflow** (via Astro Runtime)
- **Astro CLI** — local Airflow development environment (Docker-based)
- **dbt** (`dbt-snowflake` adapter)
- **astronomer-cosmos** — runs dbt models as native Airflow tasks
- **Snowflake** as the data warehouse
- **Docker** — required by Astro CLI to run Airflow locally

---

## Project structure

dbt-dag/
├── dags/
│ ├── dbt/
│ │ └── de_pipeline/ # dbt project (models, macros, tests, etc.)
│ └── ... # custom Airflow DAGs orchestrating the dbt project
├── include/
├── plugins/
├── tests/
├── .astro/
├── Dockerfile # Astro Runtime image + dbt venv setup
├── requirements.txt # Python deps installed into the Astro image
├── packages.txt # OS-level packages installed into the Astro image
├── airflow_settings.yaml # local Airflow connections/variables (Snowflake, etc.)
├── .env # local environment overrides (gitignored)
└── README.md

---

## Project contents

- **`dags/`**
  Airflow DAGs. This folder contains:
  - Custom DAGs that orchestrate the dbt project.
  - A copy of the dbt project in `dags/dbt/de_pipeline/`.

- **`Dockerfile`**
  Defines the Astro Runtime Docker image and includes the dbt virtualenv and `dbt-snowflake` installation:

```dockerfile
  FROM astrocrpublic.azurecr.io/runtime:3.3-2

  RUN python -m venv dbt_venv && \
      source dbt_venv/bin/activate && \
      pip install --no-cache-dir dbt-snowflake && \
      deactivate
```

- **`requirements.txt`**
  Python dependencies installed into the Astro image:

```text
  astronomer-cosmos
  apache-airflow-providers-snowflake
```

- **`airflow_settings.yaml`**
  Local Airflow connections and variables (e.g. the Snowflake connection used by the DAGs). Used only for local development with Astro CLI — see [Credentials](#credentials) below.

---

## Requirements

- **Docker** installed and running
- **Astro CLI** installed ([install guide](https://www.astronomer.io/docs/astro/cli/install-cli))
- A Snowflake account with a warehouse, database, and role provisioned

---

## Credentials

Local Snowflake connection details are configured in `airflow_settings.yaml` (gitignored — contains real credentials once filled in) and/or via `.env` (also gitignored).

> Never commit `airflow_settings.yaml` or `.env` with real credentials — check `.gitignore` before your first commit.

---

## Run Airflow locally (step by step)

**1. Ensure prerequisites**

- Docker is running.
- Astro CLI is installed.
- You are in the `dbt-dag` folder:

```bash
  cd dbt-dag
```

**2. Start Airflow with Astro:**

```bash
astro dev start
```

This command will:

- Build the Docker image defined in `Dockerfile` (including `dbt_venv` and `dbt-snowflake`).
- Start the local Airflow environment in Docker containers:
  - Postgres (metadata DB)
  - Webserver / API
  - Scheduler
  - DAG Processor
  - Triggerer

**3. Access the Airflow UI**

Once the containers are up, open:

```text
http://localhost:8080
```

Log in with the credentials printed by the Astro CLI (commonly `admin` / `admin`, depending on the Astro version). You should see your DAGs, including those that orchestrate the dbt project under `dags/dbt/de_pipeline`.

**4. Useful commands**

```bash
astro dev logs   # see container logs from your host machine
astro dev stop   # stop Airflow when you are done
```

---

## Notes

- `.astro/`, `.env`, `airflow_settings.yaml` (when filled with real values), and Docker build artifacts are gitignored — see `.gitignore`.
- The detailed dbt project documentation (models, macros, tests) lives inside `dags/dbt/de_pipeline/`.
