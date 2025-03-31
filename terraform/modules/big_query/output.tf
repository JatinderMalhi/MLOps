output "meta_table_id" {
  value       = google_bigquery_table.meta_forecasting_table.table_id
  description = "value of the meta table id"
}

output "meta_dataset_id" {
  value       = google_bigquery_dataset.meta_forecasting_dataset.dataset_id
  description = "value of the meta dataset id"
}