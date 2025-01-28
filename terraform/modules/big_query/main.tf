resource "google_bigquery_dataset" "meta_forecasting_dataset" {
  project = var.project_id
  dataset_id = "${var.dataset_prefix}_meta_forecasting"
  location = var.region
}

resource "google_bigquery_table" "meta_forecasting_table" {
  project = var.project_id
  dataset_id = google_bigquery_dataset.meta_forecasting_dataset.dataset_id
  table_id = "${var.table_prefix}meta_landing_data"
  time_partitioning {
    type = "DAY"
  }
  deletion_protection = false
   
  schema = <<EOF
    [
        {
            "name": "timestamp",
            "type": "TIMESTAMP",
            "mode": "NULLABLE"
        },
        {
            "name": "open",
            "type": "FLOAT",
            "mode": "NULLABLE"
        },
        {
            "name": "high",
            "type": "FLOAT",
            "mode": "NULLABLE"
        },
        {
            "name": "low",
            "type": "FLOAT",
            "mode": "NULLABLE"
        },
        {
            "name": "close",
            "type": "FLOAT",
            "mode": "NULLABLE"
        },
        {
            "name": "volume",
            "type": "INTEGER",
            "mode": "NULLABLE"
        }
    ] 
    EOF

    depends_on = [ google_bigquery_dataset.meta_forecasting_dataset ]
}

resource "google_bigquery_table" "meta_forecasting_table_train" {
  project = var.project_id
  dataset_id = google_bigquery_dataset.meta_forecasting_dataset.dataset_id
  table_id = "${var.table_prefix}_meta_forecasting_train"
  deletion_protection = false
  schema = <<EOF
    [
        {
            "name": "id",
            "type": "STRING",
            "mode": "NULLABLE"
        },
        {
            "name": "timestamp",
            "type": "TIMESTAMP",
            "mode": "NULLABLE"
        },
        {
            "name": "close",
            "type": "FLOAT",
            "mode": "NULLABLE"
        },
        {
            "name": "split",
            "type": "STRING",
            "mode": "NULLABLE"
        }
    ] 
    EOF
  
    depends_on = [ google_bigquery_dataset.meta_forecasting_dataset ]
}