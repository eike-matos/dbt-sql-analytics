# dbt-sql-analytics

Analytics project using **dbt**, **SQL** and **Python**.

## Tech stack

- dbt
- SQL
- Python

## Project structure (initial)

- `models/` – core dbt models
- `seeds/` – static seed data
- `analysis/` – ad-hoc analysis models
- `snapshots/` – snapshot definitions (if needed)
- `macros/` – custom dbt macros
- `tests/` – generic and singular tests
- `python/` – helper Python scripts (to be added)

## Development workflow

- Long‑lived branches:
- `main` – production
- `qa` – testing / pre‑prod
- `dev` – active development
- Feature branches:
  - `users/eike-matos/feature-<short-description>`
- Commit messages:
  - `[#EM-XXX] <message>`
  - Example: `[#EM-001] update README`

---

## Local setup

### 1. Requirements

- macOS
- Homebrew installed
- Git installed
- Python **3.11** (installed via Homebrew)

Install Python 3.11:

```bash
brew install python@3.11
python3.11 --version   # should print Python 3.11.x
```

### 2. Clone the repository

```bash
git clone https://github.com/eike-matos/dbt-sql-analytics.git
cd dbt-sql-analytics
```

### 3. Create and activate a virtual environment (Python 3.11)

```bash
python3.11 -m venv .venv
source .venv/bin/activate

python --version   # should print Python 3.11.x
```

### 4. Install dbt (core + Snowflake adapter)

```bash
python -m pip install --upgrade pip
python -m pip install dbt-core dbt-snowflake
```

### 5. Verify the version

```bash
dbt --version
# or:
# python -m dbt --version
```

## dbt profile (Snowflake) – local only, not committed

This project uses a **local** dbt profile with Snowflake credentials.
The file **`profiles.yml` must never be committed to Git**.

### 1. Location of `profiles.yml`

On macOS, dbt reads profiles from:

```text
~/.dbt/profiles.yml

Note: This file is outside the repository and is specific to your machine/user.
Important: Do not create a profiles.yml inside this repo. I also add profiles.yml to .gitignore to avoid accidental commits.
```

### 2. Creating the profile

```bash
From the project root (or a temporary folder), run:
dbt init
```

When running `dbt init`:

- Choose the **Snowflake** adapter.
- When prompted, provide:
  - **account (locator)**
    - Example: `yyyyyy.east-us-2.azure`
    - This is the Snowflake account identifier, **without** `https://` or `.snowflakecomputing.com`.

  - **user**
    - Your Snowflake username (e.g. `YOUR_USERNAME`).

  - **password**
    - Your Snowflake password.

  - **role**
    - Example: `DBT_ROLE`.

  - **warehouse**
    - Example: `DBT_WAREHOUSE`.

  - **database**
    - Example: `DBT_DB`.

  - **schema**
    - Example: `DBT_SCHEMA`.

dbt will write a profile for you into `~/.dbt/profiles.yml`.

### Example Snowflake profile (for reference only)

> Do **not** commit this file. It lives in `~/.dbt/profiles.yml` and contains secrets.

```yaml
de_pipeline:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: "yyyyy.east-us-2.azure"
      user: "YOUR_USERNAME"
      password: "YOUR_PASSWORD"
      role: "DBT_ROLE"
      warehouse: "DBT_WAREHOUSE"
      database: "DBT_DB"
      schema: "DBT_SCHEMA"
      threads: 4
      client_session_keep_alive: false

In `dbt_project.yml`, the project is configured to use the `de_pipeline` profile:

name: de_pipeline
profile: de_pipeline
```

### Quick dbt command sequence

From the dbt project root (where `dbt_project.yml` lives), with the virtualenv activated:

```bash
# 1. Verify configuration and connection
dbt debug

# 2. Run models
dbt run

If everything is configured correctly, you should see messages similar to:

profiles.yml file [OK found and valid]
dbt_project.yml file [OK found and valid]
Connection test: [OK]

1 of 1 OK created model <model_name> .................. [SUCCESS]
Finished running 1 view in 0 hours 0 minutes X.X seconds

```
