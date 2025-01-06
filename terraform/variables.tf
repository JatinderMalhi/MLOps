variable "project_id" {
    description = "project id for the terraform"
    type = string
}

variable "region" {
  description = "region for gcp"
  type = string
}

variable "pool_id" {
  description = "workload pool id"
  type        = string
}

variable "org_id" {
  description = "github organisation id"
  type        = string
}

variable "repo" {
  description = "github repo"
  type        = string
}

variable "service_account_id" {
  description = "service account for workload federation"
  type        = string
}


variable "project_number" {
    description = "project id for the terraform"
    type = string
}

