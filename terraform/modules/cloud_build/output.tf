output "github_token_secret_version_id" {
  value = google_secret_manager_secret_version.github_token_secret_version.id
}

output "github_token_secret" {
  value = google_secret_manager_secret.github_token_secret.secret_id
}