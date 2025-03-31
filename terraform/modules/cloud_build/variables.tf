variable "project_id" {
  description = "project id for the resource"
  type        = string
}

variable "region" {
  description = "bucket region"
  type        = string
}

variable "cloud_build_github_pat" {
  description = "Your GitHub Personal Access Token (PAT)"
}

variable "connection_name" {
  description = "The name for the GitHub Cloud Build connection"
  type        = string
  default     = "mlops_connection_github"
}

variable "installation_id" {
  description = "The GitHub App installation ID for the connection"
}

variable "secret_id" {
  description = "github-token-secret"
}

variable "project_number" {
  description = "project number"
}

variable "remote_uri" {
  description = "github repository to link with cloud build"
}

variable "name_repo" {
  description = "name of the repo"
  type        = string
  default     = "MLOps"
}