data "google_iam_policy" "serviceagent_Accessor" {
    binding {
        role = "roles/secretmanager.secretAccessor"
        members = ["serviceAccount:service-${var.project_number}@gcp-sa-dataform.iam.gserviceaccount.com"]
    }
}

resource "google_secret_manager_secret_iam_policy" "dataform_policy" {
  project = var.project_id
  secret_id = var.secret_id
  policy_data = data.google_iam_policy.serviceagent_Accessor.policy_data
}

resource "google_dataform_repository" "dataform_repository" {
  provider = google-beta
  project  = var.project_id
  name     = var.dataform_repository_name
  region   = var.region

  git_remote_settings {
    url                                 = var.remote_uri
    default_branch                      = "main"
    authentication_token_secret_version = var.github_token_secret_version_id
  }
}

resource "google_project_iam_member" "dataform_bigquery_job_user" {
  project = var.project_id
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:service-${var.project_number}@gcp-sa-dataform.iam.gserviceaccount.com"
}
