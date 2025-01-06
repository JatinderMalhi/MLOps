module "workload_identity" {
  source = "./modules/workload_identity_federation"
  project_id=var.project_id
  pool_id = var.pool_id
  repo = var.repo
  org_id = var.org_id
  project_number = var.project_number
  service_account_id = var.service_account_id
}