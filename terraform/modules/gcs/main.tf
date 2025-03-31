resource "google_storage_bucket" "meta_stock_forecasting" {
  project                     = var.project_id
  name                        = "${var.bkt_prefix}meta-stock-forecasting-pipeline"
  location                    = var.region
  force_destroy               = true
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true
  storage_class               = "STANDARD"
}