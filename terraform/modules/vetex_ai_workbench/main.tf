resource "google_notebooks_instance" "mlops_instance" {
  name         = var.instance_name
  location     = var.region
  project      = var.project_id
  machine_type = "e2-standard-4"

  vm_image {
    project      = "deeplearning-platform-release"
    image_family = "tf-latest-cpu"
  }
  service_account = "${var.service_account_email}"
  desired_state = "ACTIVE"
}


