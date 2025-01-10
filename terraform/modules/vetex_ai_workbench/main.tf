resource "google_workbench_instance" "instance" {
  name = var.instance_name
  location = var.region
  project = var.project_id


  gce_setup{
    
    machine_type = "e2-standard-4" 
    service_accounts {
      email = var.service_account_email
    }
    boot_disk {
      disk_type = "PD_STANDARD"
    }
    data_disks {
      disk_type = "PD_STANDARD"
    }
    metadata = {
      terraform = "true"
    }
  }
  desired_state = "ACTIVE"
}

# data "google_iam_policy" "instance_policy" {
#   binding {
#     role = "roles/compute.instances.get"
#     members = [
#       "serviceAccount:service-${var.project_number}@gcp-sa-notebooks.iam.gserviceaccount.com",
#     ]
#   }
# }

# resource "google_workbench_instance_iam_policy" "policy" {
#   project = google_workbench_instance.instance.project
#   location = google_workbench_instance.instance.location
#   name = google_workbench_instance.instance.name
#   policy_data = data.google_iam_policy.instance_policy.policy_data
# }