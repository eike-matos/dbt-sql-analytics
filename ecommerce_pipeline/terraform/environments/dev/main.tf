provider "snowflake" {
  organization_name = var.snowflake_organization_name
  account_name       = var.snowflake_account_name
  user               = var.snowflake_user
  password           = var.snowflake_password
  role               = var.snowflake_role
}

module "snowflake_warehouse" {
  source = "../../modules/snowflake_warehouse"

  database_name  = var.database_name
  warehouse_name = var.warehouse_name
  warehouse_size = var.warehouse_size
  snowflake_user  = var.snowflake_user
}

output "database_name" {
  value = module.snowflake_warehouse.database_name
}

output "warehouse_name" {
  value = module.snowflake_warehouse.warehouse_name
}

output "stage_name" {
  value = module.snowflake_warehouse.stage_name
}

output "schemas" {
  value = module.snowflake_warehouse.schemas
}