provider "google" {
  project = var.project_id
  region  = var.region
  default_labels = {
    "gcp" = "mlops"
  }
}