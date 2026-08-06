# dagster_orchestrator

A Dagster project scaffolded with `dagster project scaffold`.

## Requirements

- Python 3.10 to 3.14
- Active virtual environment (recommended)

## Getting started

First, install your Dagster code location as a Python package. By using the --editable flag, pip will install your Python package in ["editable mode"](https://pip.pypa.io/en/latest/topics/local-project-installs/#editable-installs) so that as you develop, local code changes will automatically apply.

```bash
pip install -U pip hatchling
pip install -e ".[dev]"
```

Then, start the Dagster UI web server:

```bash
dagster dev
```

You can start writing assets in `dagster_orchestrator/assets.py`. The assets are automatically loaded into the Dagster code location as you define them.

## Development

### Adding new Python dependencies

Assets can be defined in dagster_orchestrator/assets.py and are auto-loaded.
Managing dependencies
Edit pyproject.toml:

```
[project].dependencies
[project.optional-dependencies].dev
```

Reinstall after changes:

```
pip install -e ".[dev]"
```

### Unit testing

Tests are in the `dagster_orchestrator_tests` directory and you can run tests using `pytest`:

```bash
pytest dagster_orchestrator_tests
```

### Schedules and sensors

If you want to enable Dagster [Schedules](https://docs.dagster.io/guides/automate/schedules/) or [Sensors](https://docs.dagster.io/guides/automate/sensors/) for your jobs, the [Dagster Daemon](https://docs.dagster.io/guides/deploy/execution/dagster-daemon) process must be running. This is done automatically when you run `dagster dev`.

Once your Dagster Daemon is running, you can start turning on schedules and sensors for your jobs.

## Deploy on Dagster+

The easiest way to deploy your Dagster project is to use Dagster+.

Check out the [Dagster+ documentation](https://docs.dagster.io/dagster-plus/) to learn more.
