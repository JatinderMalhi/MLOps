resource "google_workbench_instance" "mlops_instance" {
  name     = var.instance_name
  location = var.region
  project  = var.project_id


  gce_setup {
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