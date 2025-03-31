variable "project_id" {
  description = "project id for the terraform"
  type        = string
}

variable "region" {
  description = "region for gcp"
  type        = string
}

variable "bkt_prefix" {
  description = "buckets prefix"
  type        = string
  default     = "bucket-"
}
