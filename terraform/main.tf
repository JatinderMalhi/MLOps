module "workload_identity" {
  source = "./modules/workload_identity_federation"
  project_id=var.project_id
  pool_id = var.pool_id
  repo = var.repo
  org_id = var.org_id
  project_number = var.project_number
  service_account_id = var.service_account_id
}
##################################
module "cloudbuild" {
  source = "./modules/cloud_build"
  project_id = var.project_id
  region = var.region
  project_number = var.project_number
  installation_id = var.installation_id
  cloud_build_github_pat = var.cloud_build_github_pat
  secret_id = var.secret_id
  remote_uri = var.remote_uri
}
##################################
module "artifact_registry" {
  source = "./modules/artifact_registry"
  project_id = var.project_id
  region = var.region
}
###################################
module "vertex_ai_workbench" {
  source = "./modules/vetex_ai_workbench"
  project_id = var.project_id
  service_account_email = var.service_account_id
  project_number = var.project_number
}
###################################
# module "datafrom_repository" {
#   source = "./modules/dataform"
#   project_id = var.project_id
#   region = var.region
#   project_number = var.project_number
# }