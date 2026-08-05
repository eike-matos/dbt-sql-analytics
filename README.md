# data-engineering-projects

Monorepo for data engineering projects using **dbt**, **Snowflake**, and **Airflow**.

The goal is to centralize multiple pipelines and experiments under a single repository, each project living in its own folder.

---

## Projects

### 1. `dbt-dag with de_pipeline`

Data engineering project focused on building an analytics pipeline using:

- **dbt** for data transformations
- **Snowflake** as the data warehouse
- **Airflow** for orchestration

Project folder: `./dbt-dag/de_pipeline`

> The detailed documentation and step‑by‑step instructions for this project live in `de_pipeline/README.md`.

---

## Tech stack

Across projects in this repo, the main tools and technologies are:

- **Python** (3.11+ recommended)
- **dbt**
- **Snowflake**
- **Airflow**
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

Install Python 3.11 via Homebrew:

```bash
brew install python@3.11
python3.11 --version
```

## Project-specific commands and workflows

From here, follow the specific README of each project (e.g. `de_pipeline/README.md`) for:

- Creating and activating a virtual environment
- Installing project dependencies (dbt, adapters, Airflow, etc.)
- Configuring Snowflake and dbt profiles
- Running dbt commands (`dbt debug`, `dbt run`, `dbt test`)
- Scheduling / orchestrating with Airflow (when applicable)
- Git branching and PR workflow for that project

Each project folder contains its own `README.md` with the exact commands and steps.

## Repository structure (initial)

```text
.
├── de_pipeline/          # dbt + Snowflake pipeline (first project)
│   ├── README.md         # detailed documentation for de_pipeline
│   ├── models/
│   ├── macros/
│   ├── tests/
│   ├── snapshots/
│   ├── seeds/
│   └── ...
├── .gitignore
└── README.md             # global overview for all projects

```

## Contributing / workflow (high level)

Work is done in feature branches and then merged into environment branches, following this flow (per project/repo convention):

```text
feature → dev → qa → main

Detailed branching and commit conventions for de_pipeline are described in de_pipeline/README.md.

New projects should:
- Live in their own folder.
- Have their own README.md.
- Reuse the same Git workflow where it makes sense.
- More sections will be added as the monorepo grows (CI/CD, Airflow deployment, shared libs, etc.).
```
