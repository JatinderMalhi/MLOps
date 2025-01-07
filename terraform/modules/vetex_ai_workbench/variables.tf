variable "project_id" {
  description = "project id for the resource"
  type = string
}

variable "region" {
  description = "bucket region"
}

variable "service_account_email" {
  description = "service account email for the vertex ai notbook"
}

variable "instance_name" {
  description = "name of the instance notebook"
  type = string
  default = "mlops"
}