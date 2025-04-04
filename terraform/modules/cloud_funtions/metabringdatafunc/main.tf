data "archive_file" "source" {
  type        = "zip"
  source_dir  = "${path.module}/src"
  output_path = "${path.module}/src/alert_source.zip"
}

resource "google_storage_bucket" "cloud_function_store_metafetchdata_code" {
  project                     = var.project_id
  name                        = "${var.bkt_prefix}cloud-function-store-metafetchdata-code"
  location                    = var.region
  force_destroy               = true
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true
  storage_class               = "STANDARD"
}

resource "google_storage_bucket_object" "zip" {
  source       = data.archive_file.source.output_path
  content_type = "application/zip"
  name         = "alert_source.${data.archive_file.source.output_md5}.zip"
  bucket       = google_storage_bucket.cloud_function_store_metafetchdata_code.name

  depends_on = [
    google_storage_bucket.cloud_function_store_metafetchdata_code,
    data.archive_file.source
  ]
}
######
resource "google_cloudfunctions2_function" "func_trigger_bucket_to_bigquery" {
  project     = var.project_id
  location    = var.region
  name        = "fetch_meta_data_func_load_to_bigquery"
  description = <<EOF
    This function schedule to run weekly. Read the delta load through API from stock market.
    Load the data into the bigquery table.
    EOF
  build_config {
    runtime     = "python310"
    entry_point = "fetch_and_store_data"
    source {
      storage_source {
        bucket = google_storage_bucket.cloud_function_store_metafetchdata_code.name
        object = google_storage_bucket_object.zip.name
      }
    }
  }

  service_config {
    max_instance_count = 3
    min_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 600
    environment_variables = {
      SERVICE_CONFIG_TEST = "config_test"
      TABLE_ID            = var.table_id
      SYMBOL              = var.symbol
      API_KEY             = var.meta_api_token
    }

    ingress_settings               = "ALLOW_ALL"
    all_traffic_on_latest_revision = true
    service_account_email          = var.service_account_email
  }

  depends_on = [
    google_storage_bucket_object.zip,
  ]
}

resource "google_cloud_scheduler_job" "invoke_cloud_function" {
  paused           = true
  name             = "invoke-meta-fetch-data-function"
  description      = "Schedule the HTTPS trigger for cloud function"
  schedule         = "0 6 * * 6"
  time_zone        = "America/New_York"
  project          = var.project_id
  region           = var.region
  attempt_deadline = "600s"

  http_target {
    uri         = google_cloudfunctions2_function.func_trigger_bucket_to_bigquery.url
    http_method = "GET"

    oidc_token {
      service_account_email = var.service_account_email
    }
  }

  depends_on = [
    google_cloudfunctions2_function.func_trigger_bucket_to_bigquery
  ]
}
