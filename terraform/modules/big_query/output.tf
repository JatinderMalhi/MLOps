output "meta_table_id" {
  value = google_bigquery_table.meta_forecasting_table.table_id
  description = "value of the meta table id"
}