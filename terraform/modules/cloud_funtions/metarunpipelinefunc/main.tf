data "archive_file" "source_dir" {
  type        = "zip"
  source_dir  = "${path.module}/src"
  output_path = "${path.module}/src/alert_source.zip"
}

resource "google_storage_bucket" "cloud_function_store_metapipeline_code" {
  project                     = var.project_id
  name                        = "${var.bkt_prefix}cloud-function-store-meta-pipeline-code"
  location                    = var.region
  force_destroy               = true
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true
  storage_class               = "STANDARD"
}

resource "google_storage_bucket_object" "meta_pipeline_zip" {
  source       = data.archive_file.source_dir.output_path
  content_type = "application/zip"
  name         = "alert_source.${data.archive_file.source_dir.output_md5}.zip"
  bucket       = google_storage_bucket.cloud_function_store_metapipeline_code.name

  depends_on = [
    google_storage_bucket.cloud_function_store_metapipeline_code,
    data.archive_file.source_dir
  ]
}

resource "google_cloudfunctions2_function" "function_trigger_meta_training_pipeline" {
  project     = var.project_id
  location    = var.region
  name        = "run_meta_training_pipeline"
  description = <<EOF
    This function schedule to run weekly. Run the model training pipeline.
    EOF
  build_config {
    runtime     = "python310"
    entry_point = "run_pipeline"
    source {
      storage_source {
        bucket = google_storage_bucket.cloud_function_store_metapipeline_code.name
        object = google_storage_bucket_object.meta_pipeline_zip.name
      }
    }
  }

  service_config {
    max_instance_count = 3
    min_instance_count = 1
    available_memory   = "1G"
    available_cpu = "1"
    timeout_seconds    = 60
    environment_variables = {
      SERVICE_CONFIG_TEST = "config_test"
      PROJECT_ID          = var.project_id
      LOCATION            = var.region
      SERVICE_ACCOUNT     = var.service_account_email
      BUCKET_URI          = var.meta_pipeline_bucket_uri
    }

    ingress_settings               = "ALLOW_ALL"
    all_traffic_on_latest_revision = true
    service_account_email          = var.service_account_email
  }

  depends_on = [google_storage_bucket_object.meta_pipeline_zip, ]

}

resource "google_cloud_scheduler_job" "invoke_meta_training_function" {
  project     = var.project_id
  name        = "invoke-meta-model-training-function"
  schedule    = "0 12 * * 6"
  description = "Schedule to run the meta model training pipeline weekly"
  region = var.region
  http_target {
    uri         = google_cloudfunctions2_function.function_trigger_meta_training_pipeline.url
    http_method = "GET"
    oidc_token {
      service_account_email = var.service_account_email
    }
  }

  depends_on = [google_cloudfunctions2_function.function_trigger_meta_training_pipeline]
}
