# data-engineering-projects

Monorepo for data engineering projects using **dbt**, **Snowflake**, **Airflow**, **Dagster**, and **Terraform**.

The goal is to centralize multiple pipelines and experiments under a single repository, each project living in its own folder.

---

## Projects

### 1. `dbt-dag` — dbt + Snowflake + Airflow

Data engineering project focused on building an analytics pipeline using:

- **dbt** for data transformations
- **Snowflake** as the data warehouse
- **Airflow** for orchestration

Project folder: `./dbt-dag`

> The detailed documentation and step-by-step instructions for this project live in `dbt-dag/README.md`.

### 2. `dagster_orchestrator` — Dagster + Snowflake + MongoDB

Data engineering project focused on ingestion and transformation orchestrated with **Dagster**, using:

- **Dagster** as the orchestrator (assets, sensors, resources)
- **dlt (data load tool)** to extract data from MongoDB (Atlas `sample_mflix` dataset) and load into Snowflake
- **Snowflake** as the data warehouse
- **pandas / scikit-learn** for downstream transformations and embeddings (TSNE) on top of the loaded data

Project folder: `./dagster_orchestrator`

> The detailed documentation and step-by-step instructions for this project live in `dagster_orchestrator/README.md`.

### 3. `ecommerce_pipeline` — Terraform + Snowflake + dbt + Dagster + Streamlit

End-to-end data platform built on real e-commerce data (Olist Brazilian E-Commerce dataset, ~1.5M rows), covering the full lifecycle from infrastructure to consumption:

- **Terraform** for infrastructure as code (Snowflake database, warehouse, schemas, stages, and role-based access control with least privilege)
- **Python** for ingestion (CSV validation, upload to internal stage, `COPY INTO`), tested with **pytest**
- **dbt** for transformation (staging → intermediate → marts, dimensional modeling, incremental models, 48+ data tests)
- **Dagster** for orchestration, with a fully connected asset lineage from raw ingestion through every dbt model
- **Streamlit** for the analytics dashboard, reading from the marts layer via a dedicated read-only role

Project folder: `./ecommerce_pipeline`

> The detailed documentation and step-by-step instructions for this project live in `ecommerce_pipeline/README.md`.

### 4. _(coming soon)_

A fourth project will be added here as the monorepo grows.

---

## Tech stack

Across projects in this repo, the main tools and technologies are:

- **Python** (3.11+ recommended; some sub-projects pin specific versions — see each project's README)
- **dbt**
- **Dagster** + **dagster-embedded-elt (dlt)**
- **Snowflake**
- **Terraform**
- **MongoDB Atlas**
- **Airflow**
- **Streamlit**
- **Git** + **GitHub**
- **VS Code** (recommended editor)

Each project may have its own specific versions and dependencies, documented inside its own folder.

---

## Global requirements

These are the base tools expected on your machine before working with any project in this repo:

- **macOS** (tested)
- **Homebrew**
- **Git**
- **Python 3.11+**
- **Terraform** (for projects that provision infrastructure)

Install Python 3.11 via Homebrew:

```bash
brew install python@3.11
python3.11 --version
```

Install Terraform via the official HashiCorp tap:

```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
terraform -version
```

---

## Project-specific commands and workflows

From here, follow the specific README of each project (e.g. `dbt-dag/README.md`, `dagster_orchestrator/README.md`, `ecommerce_pipeline/README.md`) for:

- Creating and activating a virtual environment
- Installing project dependencies
- Configuring credentials (Snowflake, MongoDB, dbt profiles, etc.)
- Running the pipeline (`dbt run`, `dagster dev`, Airflow DAGs, `terraform apply`, etc.)
- Git branching and PR workflow for that project

Each project folder contains its own `README.md` with the exact commands and steps.

---

## Repository structure

.
├── dbt-dag/ # dbt + Snowflake + Airflow pipeline
│ ├── README.md
│ ├── dags/
│ ├── include/
│ └── ...
├── dagster_orchestrator/ # Dagster + Snowflake + MongoDB pipeline
│ ├── README.md
│ ├── dagster_orchestrator/ # Dagster package (assets, definitions)
│ ├── dagster_orchestrator_tests/
│ ├── adhoc/
│ ├── data/
│ └── pyproject.toml
├── ecommerce_pipeline/ # Terraform + Snowflake + dbt + Dagster + Streamlit
│ ├── README.md
│ ├── terraform/
│ ├── ingestion/
│ ├── dbt_project/
│ ├── orchestration/
│ └── streamlit_app/
├── .gitignore
└── README.md # this file — global overview for all projects

---

## Contributing / workflow (high level)

Work is done in feature branches and then merged into environment branches, following this flow (per project/repo convention):
feature → dev → qa → main
Detailed branching and commit conventions for each project are described in its own README.

New projects should:

- Live in their own folder.
- Have their own `README.md`.
- Reuse the same Git workflow where it makes sense.
- Not commit `.env` files, `secrets.toml`, `terraform.tfvars`, or any credentials — see each project's `.gitignore`.

More sections will be added as the monorepo grows (CI/CD, shared libs, etc.).
