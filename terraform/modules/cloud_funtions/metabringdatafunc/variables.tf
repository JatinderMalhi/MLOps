variable "project_id" {
  description = "project id for the resource"
  type = string
}

variable "region" {
  description = "bucket region"
  type = string
}

variable "service_account_email" {
  description = "service account email for the vertex ai notbook"
  type = string
}

variable "bkt_prefix" {
  description = "buckets prefix"
  type = string
  default = "bucket-"
}

variable "table_id" {
  description = "landing data table id of meta"
  type = string
}

variable "meta_api_secret_id" {
  description = "meta api secret id"
  type = string
}

variable "meta_api_token" {
  description = "meta api token"
  type = string  
}

variable "symbol" {
  description = "stock symbol"
  type = string
  default = "META"
}