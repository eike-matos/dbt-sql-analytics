variable "snowflake_organization_name" {
  description = "Snowflake organization name"
  type        = string
}

variable "snowflake_account_name" {
  description = "Snowflake account name (within the organization)"
  type        = string
}
variable "snowflake_user" {
  description = "Snowflake username used by Terraform"
  type        = string
}

variable "snowflake_password" {
  description = "Snowflake password used by Terraform"
  type        = string
  sensitive   = true
}

variable "snowflake_role" {
  description = "Snowflake role used to run Terraform (needs privileges to create db/warehouse/schemas)"
  type        = string
  default     = "SYSADMIN"
}

variable "database_name" {
  description = "Name of the project's main database"
  type        = string
  default     = "ECOMMERCE_DB"
}

variable "warehouse_name" {
  description = "Name of the Snowflake warehouse"
  type        = string
  default     = "ECOMMERCE_WH"
}

variable "warehouse_size" {
  description = "Warehouse size (XSMALL, SMALL, MEDIUM...)"
  type        = string
  default     = "XSMALL"
}