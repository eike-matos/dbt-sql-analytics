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

variable "auto_suspend_seconds" {
  description = "Seconds of inactivity before auto-suspending the warehouse (cost control)"
  type        = number
  default     = 60
}

variable "schemas" {
  description = "List of schemas to create inside the database"
  type        = list(string)
  default     = ["RAW", "STAGING", "MARTS"]
}

variable "loader_role_name" {
  description = "Role used by the Python ingestion script to write into RAW"
  type        = string
  default     = "LOADER_ROLE"
}

variable "transformer_role_name" {
  description = "Role used by dbt to read RAW and write into STAGING/MARTS"
  type        = string
  default     = "TRANSFORMER_ROLE"
}

variable "reader_role_name" {
  description = "Role used by Streamlit (or other BI tools) with read-only access to MARTS"
  type        = string
  default     = "READER_ROLE"
}
