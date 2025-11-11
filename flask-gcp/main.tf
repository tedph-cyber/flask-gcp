terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "7.10.0"
    }
  }
}

provider "google" {
  # Configuration options
  project = "terahform"
  region = "us-central-1"
  zone = "us-central1-a"
  credentials = "flaskform.json"

}

resource "google_storage_bucket" "gcp-flask" {
  name          = "flaskform-bucket"
  location      = "us-central-1"
 }
