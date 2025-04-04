# ######
module "workload_identity" {
  source             = "./modules/workload_identity_federation"
  project_id         = var.project_id
  pool_id            = var.pool_id
  repo               = var.repo
  org_id             = var.org_id
  project_number     = var.project_number
  service_account_id = var.service_account_id
}
# ######
module "cloudbuild" {
  source                 = "./modules/cloud_build"
  project_id             = var.project_id
  region                 = var.region
  project_number         = var.project_number
  installation_id        = var.installation_id
  cloud_build_github_pat = var.cloud_build_github_pat
  secret_id              = var.secret_id
  remote_uri             = var.remote_uri
}
# ######
module "artifact_registry" {
  source     = "./modules/artifact_registry"
  project_id = var.project_id
  region     = var.region
}
# ######
module "vertex_ai_workbench" {
  source                = "./modules/vetex_ai_workbench"
  project_id            = var.project_id
  service_account_email = var.service_account_id
}
# ######
module "big-query" {
  source     = "./modules/big_query"
  project_id = var.project_id
  region     = var.region

}
# ######
module "cloud_function" {
  source                = "./modules/cloud_funtions/metabringdatafunc"
  project_id            = var.project_id
  region                = var.region
  service_account_email = var.service_account_id
  table_id              = "${var.project_id}.${module.big-query.meta_dataset_id}.${module.big-query.meta_table_id}"
  meta_api_secret_id    = var.meta_api_secret_id
  meta_api_token        = var.meta_api_token
  project_number        = var.project_number
}
# ######
module "cloud_function_meta_pipeline" {
  source                   = "./modules/cloud_funtions/metarunpipelinefunc"
  project_id               = var.project_id
  region                   = var.region
  service_account_email    = var.service_account_id
  meta_pipeline_bucket_uri = var.meta_compiled_pipeline_bucket_uri
}
######
module "gcs" {
  source     = "./modules/gcs"
  project_id = var.project_id
  region     = var.region
}
# ##########
# # module "datafrom_repository" {
# #   source = "./modules/dataform"
# #   project_id = var.project_id
# #   region = var.region
# #   project_number = var.project_number
# # }