variable "project_id" {
  description = "project id for the resource"
  type        = string
}

variable "region" {
  description = "bucket region"
  type        = string
}

variable "service_account_email" {
  description = "service account email for the vertex ai notbook"
  type        = string
}

variable "bkt_prefix" {
  description = "buckets prefix"
  type        = string
  default     = "bucket-"
}

variable "meta_pipeline_bucket_uri" {
  description = "bucket uri for the meta pipeline"
  type        = string
}