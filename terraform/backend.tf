terraform {
 backend "gcs" {
   bucket  = "bukt-store-state-file"
   prefix  = "terraf/state"
 }
}