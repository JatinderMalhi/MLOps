resource "google_secret_manager_secret" "github_token_secret" {
  project   = var.project_id
  secret_id = var.secret_id

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "github_token_secret_version" {
  secret      = google_secret_manager_secret.github_token_secret.id
  secret_data = var.cloud_build_github_pat
}

resource "google_dataform_repository" "dataform_repository" {
  project = var.project_id
  name     = var.dataform_repository_name
  region   = var.region

  git_remote_settings {
    url                                 = var.remote_uri
    default_branch                      = "main"
    authentication_token_secret_version = google_secret_manager_secret_version.github_token_secret_version.id
  }
}

data "google_iam_policy" "dataform_sa" {
  binding {
    role    = "roles/bigquery.user"
    members = ["serviceAccount:service-${var.project_number}@gcp-sa-dataform.iam.gserviceaccount.com"]
  }
}

resource "google_dataform_repository_iam_policy" "policy" {
  project     = google_dataform_repository.dataform_repository.project
  region      = google_dataform_repository.dataform_repository.region
  repository  = google_dataform_repository.dataform_repository.name
  policy_data = data.google_iam_policy.dataform_sa.policy_data
}

