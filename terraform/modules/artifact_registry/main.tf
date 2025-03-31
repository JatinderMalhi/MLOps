resource "google_artifact_registry_repository" "asp_gcp" {
  project       = var.project_id
  repository_id = "${var.repo_prefix}ml"
  location      = var.region
  format        = "DOCKER"
}