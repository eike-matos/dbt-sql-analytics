resource "snowflake_warehouse" "this" {
  name                = var.warehouse_name
  warehouse_size      = var.warehouse_size
  auto_suspend        = var.auto_suspend_seconds
  auto_resume         = true
  initially_suspended = true
  comment             = "Warehouse for the ecommerce_pipeline project - managed via Terraform"
}

resource "snowflake_database" "this" {
  name    = var.database_name
  comment = "Main database for the ecommerce_pipeline project"
}

resource "snowflake_schema" "schemas" {
  for_each = toset(var.schemas)

  database = snowflake_database.this.name
  name     = each.value
  comment  = "${each.value} schema - managed via Terraform"
}

resource "snowflake_stage" "raw_stage" {
  name     = "RAW_STAGE"
  database = snowflake_database.this.name
  schema   = "RAW"
  comment  = "Internal stage for raw file ingestion"

  depends_on = [snowflake_schema.schemas]
}

resource "snowflake_file_format" "csv_format" {
  name        = "CSV_FORMAT"
  database    = snowflake_database.this.name
  schema      = "RAW"
  format_type = "CSV"

  field_delimiter               = ","
  skip_header                   = 1
  field_optionally_enclosed_by  = "\""
  null_if                       = ["", "NULL", "null"]

  depends_on = [snowflake_schema.schemas]
}