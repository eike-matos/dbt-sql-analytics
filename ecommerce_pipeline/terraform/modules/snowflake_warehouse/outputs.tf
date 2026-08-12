output "database_name" {
  value = snowflake_database.this.name
}

output "warehouse_name" {
  value = snowflake_warehouse.this.name
}

output "stage_name" {
  value = snowflake_stage.raw_stage.name
}

output "schemas" {
  value = [for s in snowflake_schema.schemas : s.name]
}
output "loader_role_name" {
  value = snowflake_account_role.loader.name
}

output "transformer_role_name" {
  value = snowflake_account_role.transformer.name
}

output "reader_role_name" {
  value = snowflake_account_role.reader.name
}
