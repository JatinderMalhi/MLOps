resource "google_iam_workload_identity_pool" "pool" {
  workload_identity_pool_id = var.pool_id
}

resource "google_iam_workload_identity_pool_provider" "mlops" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "github"
  display_name                       = "Github"
  description                        = "GitHub Actions identity pool provider for automation"
  disabled                           = false
  attribute_condition = <<EOT
    assertion.repository_owner_id == "${var.org_id}" &&
    attribute.repository == "${var.repo}" &&
    assertion.ref == "refs/heads/main" &&
    assertion.ref_type == "branch"
EOT
  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.aud"        = "assertion.aud"
    "attribute.repository" = "assertion.repository"
  }
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}


resource "google_service_account_iam_binding" "workload_identity_iam" {
service_account_id = "projects/${var.project_id}/serviceAccounts/${var.service_account_id}"
role = "roles/iam.workloadIdentityUser"
members = [
"principalSet://iam.googleapis.com/projects/${var.project_number}/locations/global/workloadIdentityPools/${var.pool_id}/attribute.repository/${var.repo}"
]

depends_on = [ google_iam_workload_identity_pool_provider.mlops ]
}