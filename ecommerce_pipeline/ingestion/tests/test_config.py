"""
Unit tests for configuration loading.
"""

import pytest

import src.config as config_module


def test_require_env_raises_when_missing(monkeypatch):
    """Missing required env vars should fail fast with a clear error."""
    monkeypatch.delenv("SOME_TEST_VAR", raising=False)

    with pytest.raises(EnvironmentError):
        config_module._require_env("SOME_TEST_VAR")


def test_require_env_returns_value_when_present(monkeypatch):
    monkeypatch.setenv("SOME_TEST_VAR", "hello")

    assert config_module._require_env("SOME_TEST_VAR") == "hello"


def test_account_identifier_combines_org_and_account():
    cfg = config_module.SnowflakeConfig(
        organization_name="MYORG",
        account_name="MYACCOUNT",
        user="user",
        password="pw",
        role="LOADER_ROLE",
        warehouse="WH",
        database="DB",
        schema="RAW",
    )

    assert cfg.account_identifier == "MYORG-MYACCOUNT"
