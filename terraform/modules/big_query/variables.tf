variable "project_id" {
  description = "project id for the resource"
  type        = string
}

variable "region" {
  description = "bucket region"
  type        = string
}

variable "dataset_prefix" {
  description = "prefix for the dataset"
  type        = string
  default     = "dt"
}

variable "table_prefix" {
  description = "prefix for the table"
  type        = string
  default     = "tbl"
}