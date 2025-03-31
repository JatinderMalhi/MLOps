variable "project_id" {
  description = "project id for the terraform"
  type        = string
}

variable "region" {
  description = "region for gcp"
  type        = string
}

variable "repo_prefix" {
  description = "rego "
  type        = string
  default     = "repo-artifacts-registry-"
}