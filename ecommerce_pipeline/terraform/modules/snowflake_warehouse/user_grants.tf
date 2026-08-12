# ---------------------------------------------------------------------------
# Grants roles to the developer's own user, for local/manual testing.
# In a production setup, each role would instead be granted to a dedicated
# service user (e.g. SVC_LOADER, SVC_DBT) - see README for details.
# ---------------------------------------------------------------------------

resource "snowflake_grant_account_role" "loader_to_user" {
  role_name = snowflake_account_role.loader.name
  user_name = var.snowflake_user

  depends_on = [snowflake_account_role.loader]
}

resource "snowflake_grant_account_role" "transformer_to_user" {
  role_name = snowflake_account_role.transformer.name
  user_name = var.snowflake_user

  depends_on = [snowflake_account_role.transformer]
}

resource "snowflake_grant_account_role" "reader_to_user" {
  role_name = snowflake_account_role.reader.name
  user_name = var.snowflake_user

  depends_on = [snowflake_account_role.reader]
}
