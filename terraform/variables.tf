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

variable "cloud_build_github_pat" {
  description = "Your GitHub Personal Access Token (PAT)"
}

variable "installation_id" {
  description = "The GitHub App installation ID for the connection"
}

variable "secret_id" {
description = "github-token-secret"  
}

variable "org_id" {
  description = "github organisation id"
  type        = string
}

variable "repo" {
  description = "github repo"
  type        = string
}

variable "remote_uri" {
  description = "github repository to link with cloud build"
}

variable "service_account_id" {
  description = "service account for workload federation"
  type        = string
}


variable "project_number" {
    description = "project id for the terraform"
    type = string
}

