# Overview

This project (`dbt-dag`) runs **Apache Airflow** locally using the **Astro CLI**.
It is used to orchestrate the `de_pipeline` dbt project on Snowflake.

Below you’ll find:

- What’s inside this project.
- Step‑by‑step instructions to run Airflow locally with Astro.

---

## Project contents

Your `dbt-dag` project contains at least the following files and folders:

- `dags/`
  Airflow DAGs. This folder will contain:
  - Your custom DAGs that orchestrate the dbt project.
  - A copy of the dbt project in:
    `dags/dbt/de_pipeline/`

- `Dockerfile`
  Defines the Astro Runtime Docker image and includes the dbt virtualenv and `dbt-snowflake` installation:

  ```dockerfile
  FROM astrocrpublic.azurecr.io/runtime:3.3-2

  RUN python -m venv dbt_venv && \
      source dbt_venv/bin/activate && \
      pip install --no-cache-dir dbt-snowflake && \
      deactivate
  ```

- `requirements.txt`
  Python dependencies installed into the Astro image:
  ```
  astronomer-cosmos
  apache-airflow-providers-snowflake
  ```

## Run Airflow locally (step by step)

- Ensure prerequisites
  - Docker is running.
  - Astro CLI is installed.
  - You are in the `dbt-dag` folder:

    ```bash
    cd dbt-dag
    ```

- Start Airflow with Astro:

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

Access the Airflow UI. Once the containers are up, open:

```text
http://localhost:8080
```

Log in with the credentials printed by the Astro CLI (commonly admin / admin or similar, depending on the Astro version). You should see your DAGs, including those that orchestrate the dbt project under dags/dbt/de_pipeline.

To see container logs from your host machine:

```
astro dev logs (To see container logs from your host machine)
astro dev stop (To stop Airflow when you are done)

```
