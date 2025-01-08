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

data "google_iam_policy" "serviceagent_secretAccessor" {
    binding {
        role = "roles/secretmanager.secretAccessor"
        members = ["serviceAccount:service-${var.project_number}@gcp-sa-cloudbuild.iam.gserviceaccount.com"]
    }
}

resource "google_secret_manager_secret_iam_policy" "policy" {
  project = google_secret_manager_secret.github_token_secret.project
  secret_id = google_secret_manager_secret.github_token_secret.secret_id
  policy_data = data.google_iam_policy.serviceagent_secretAccessor.policy_data
}

resource "google_cloudbuildv2_connection" "github_connection" {
  project  = var.project_id
  location = var.region
  name     = var.connection_name

  github_config {
    app_installation_id = var.installation_id
    authorizer_credential {
      oauth_token_secret_version = google_secret_manager_secret_version.github_token_secret_version.id
    }
  }
  depends_on = [google_secret_manager_secret_iam_policy.policy]
}

resource "google_cloudbuildv2_repository" "github_repo" {
  project = var.project_id
  location = var.region
  name = var.name_repo
  parent_connection = google_cloudbuildv2_connection.github_connection.name
  remote_uri = var.remote_uri
}

output "github_token_secret_version_id" {
  value = google_secret_manager_secret_version.github_token_secret_version.id
}