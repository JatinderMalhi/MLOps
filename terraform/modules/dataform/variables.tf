variable "project_id" {
  description = "project id for the resource"
  type = string
}

variable "region" {
  description = "bucket region"
  type = string
}

variable "cloud_build_github_pat" {
  description = "Your GitHub Personal Access Token (PAT)"
}

variable "dataform_repository_name" {
  description = "The name of datafrom repository"
  type = string
  default = "mlops"
}

variable "project_number" {
  description = "project number"
}

variable "remote_uri" {
  description = "github repository to link with cloud build"
}

variable "github_token_secret_version_id" {
  description = "secret verion id"
}

variable "secret_id" {
description = "github-token-secret"  
}
