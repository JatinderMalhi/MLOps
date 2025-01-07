variable "project_id" {
  description = "project id for the resource"
  type = string
}

variable "region" {
  description = "instance zonal region"
  default = "us-central1-a"
}

variable "service_account_email" {
  description = "service account email for the vertex ai notbook"
  type = string
}

variable "instance_name" {
  description = "name of the instance notebook"
  type = string
  default = "mlops"
}