# ---------------------------------------------------------------------------
# Roles
# ---------------------------------------------------------------------------

resource "snowflake_account_role" "loader" {
  name    = var.loader_role_name
  comment = "Role for the Python ingestion process. Write access to RAW only."
}

resource "snowflake_account_role" "transformer" {
  name    = var.transformer_role_name
  comment = "Role for dbt. Reads RAW, writes STAGING and MARTS."
}

resource "snowflake_account_role" "reader" {
  name    = var.reader_role_name
  comment = "Role for BI / Streamlit. Read-only access to MARTS."
}

# ---------------------------------------------------------------------------
# Warehouse usage - all three roles need to run queries
# ---------------------------------------------------------------------------

resource "snowflake_grant_privileges_to_account_role" "loader_warehouse_usage" {
  privileges         = ["USAGE"]
  account_role_name  = snowflake_account_role.loader.name
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = snowflake_warehouse.this.name
  }
}

resource "snowflake_grant_privileges_to_account_role" "transformer_warehouse_usage" {
  privileges         = ["USAGE"]
  account_role_name  = snowflake_account_role.transformer.name
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = snowflake_warehouse.this.name
  }
}

resource "snowflake_grant_privileges_to_account_role" "reader_warehouse_usage" {
  privileges         = ["USAGE"]
  account_role_name  = snowflake_account_role.reader.name
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = snowflake_warehouse.this.name
  }
}

# ---------------------------------------------------------------------------
# Database usage - all three roles need to see the database
# ---------------------------------------------------------------------------

resource "snowflake_grant_privileges_to_account_role" "loader_database_usage" {
  privileges         = ["USAGE"]
  account_role_name  = snowflake_account_role.loader.name
  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.this.name
  }
}

resource "snowflake_grant_privileges_to_account_role" "transformer_database_usage" {
  privileges         = ["USAGE"]
  account_role_name  = snowflake_account_role.transformer.name
  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.this.name
  }
}

resource "snowflake_grant_privileges_to_account_role" "reader_database_usage" {
  privileges         = ["USAGE"]
  account_role_name  = snowflake_account_role.reader.name
  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.this.name
  }
}

# ---------------------------------------------------------------------------
# LOADER_ROLE: write access to RAW schema only
# ---------------------------------------------------------------------------

resource "snowflake_grant_privileges_to_account_role" "loader_raw_schema" {
  privileges         = ["USAGE", "CREATE TABLE"]
  account_role_name  = snowflake_account_role.loader.name
  on_schema {
    schema_name = "\"${snowflake_database.this.name}\".\"RAW\""
  }
}

resource "snowflake_grant_privileges_to_account_role" "loader_raw_tables" {
  privileges         = ["SELECT", "INSERT", "UPDATE", "DELETE"]
  account_role_name  = snowflake_account_role.loader.name
  on_schema_object {
    all {
      object_type_plural = "TABLES"
      in_schema           = "\"${snowflake_database.this.name}\".\"RAW\""
    }
  }
}

# ---------------------------------------------------------------------------
# TRANSFORMER_ROLE: read RAW, write STAGING and MARTS (this is what dbt uses)
# ---------------------------------------------------------------------------

resource "snowflake_grant_privileges_to_account_role" "transformer_raw_read" {
  privileges         = ["USAGE"]
  account_role_name  = snowflake_account_role.transformer.name
  on_schema {
    schema_name = "\"${snowflake_database.this.name}\".\"RAW\""
  }
}

resource "snowflake_grant_privileges_to_account_role" "transformer_raw_tables_read" {
  privileges         = ["SELECT"]
  account_role_name  = snowflake_account_role.transformer.name
  on_schema_object {
    all {
      object_type_plural = "TABLES"
      in_schema           = "\"${snowflake_database.this.name}\".\"RAW\""
    }
  }
}

resource "snowflake_grant_privileges_to_account_role" "transformer_staging_full" {
  privileges         = ["USAGE", "CREATE TABLE", "CREATE VIEW"]
  account_role_name  = snowflake_account_role.transformer.name
  on_schema {
    schema_name = "\"${snowflake_database.this.name}\".\"STAGING\""
  }
}

resource "snowflake_grant_privileges_to_account_role" "transformer_marts_full" {
  privileges         = ["USAGE", "CREATE TABLE", "CREATE VIEW"]
  account_role_name  = snowflake_account_role.transformer.name
  on_schema {
    schema_name = "\"${snowflake_database.this.name}\".\"MARTS\""
  }
}

resource "snowflake_grant_privileges_to_account_role" "transformer_intermediate_full" {
  privileges         = ["USAGE", "CREATE TABLE", "CREATE VIEW"]
  account_role_name  = snowflake_account_role.transformer.name
  on_schema {
    schema_name = "\"${snowflake_database.this.name}\".\"INTERMEDIATE\""
  }
}

# ---------------------------------------------------------------------------
# READER_ROLE: read-only access to MARTS (this is what Streamlit uses),
# plus read-only access to INTERMEDIATE (some dashboard queries read
# int_orders_enriched directly for delivery/location breakdowns).
#
# Both "all" (covers objects that already exist) and "future" (covers
# objects dbt creates later) grants are needed - "all" alone does not
# retroactively apply to tables created after the grant was applied.
# ---------------------------------------------------------------------------

resource "snowflake_grant_privileges_to_account_role" "reader_marts_usage" {
  privileges         = ["USAGE"]
  account_role_name  = snowflake_account_role.reader.name
  on_schema {
    schema_name = "\"${snowflake_database.this.name}\".\"MARTS\""
  }
}

resource "snowflake_grant_privileges_to_account_role" "reader_marts_tables" {
  privileges         = ["SELECT"]
  account_role_name  = snowflake_account_role.reader.name
  on_schema_object {
    all {
      object_type_plural = "TABLES"
      in_schema           = "\"${snowflake_database.this.name}\".\"MARTS\""
    }
  }
}

resource "snowflake_grant_privileges_to_account_role" "reader_marts_tables_future" {
  privileges         = ["SELECT"]
  account_role_name  = snowflake_account_role.reader.name
  on_schema_object {
    future {
      object_type_plural = "TABLES"
      in_schema           = "\"${snowflake_database.this.name}\".\"MARTS\""
    }
  }
}

resource "snowflake_grant_privileges_to_account_role" "reader_marts_views" {
  privileges         = ["SELECT"]
  account_role_name  = snowflake_account_role.reader.name
  on_schema_object {
    all {
      object_type_plural = "VIEWS"
      in_schema           = "\"${snowflake_database.this.name}\".\"MARTS\""
    }
  }
}

resource "snowflake_grant_privileges_to_account_role" "reader_marts_views_future" {
  privileges         = ["SELECT"]
  account_role_name  = snowflake_account_role.reader.name
  on_schema_object {
    future {
      object_type_plural = "VIEWS"
      in_schema           = "\"${snowflake_database.this.name}\".\"MARTS\""
    }
  }
}

resource "snowflake_grant_privileges_to_account_role" "reader_intermediate_usage" {
  privileges         = ["USAGE"]
  account_role_name  = snowflake_account_role.reader.name
  on_schema {
    schema_name = "\"${snowflake_database.this.name}\".\"INTERMEDIATE\""
  }
}

resource "snowflake_grant_privileges_to_account_role" "reader_intermediate_views" {
  privileges         = ["SELECT"]
  account_role_name  = snowflake_account_role.reader.name
  on_schema_object {
    all {
      object_type_plural = "VIEWS"
      in_schema           = "\"${snowflake_database.this.name}\".\"INTERMEDIATE\""
    }
  }
}

resource "snowflake_grant_privileges_to_account_role" "reader_intermediate_views_future" {
  privileges         = ["SELECT"]
  account_role_name  = snowflake_account_role.reader.name
  on_schema_object {
    future {
      object_type_plural = "VIEWS"
      in_schema           = "\"${snowflake_database.this.name}\".\"INTERMEDIATE\""
    }
  }
}
