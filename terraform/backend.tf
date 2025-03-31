terraform {
  backend "gcs" {
    bucket = "bukt-store-terraform-state-file"
    prefix = "terraf/state"
  }
}