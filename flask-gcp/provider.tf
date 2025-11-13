terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "7.10.0"
    }
  }

  backend "gcs" {
    bucket = "tedahform"
    # key = "state"
    # region = "us-central-1"
    prefix = "flaskform"
  }
}

provider "google" {
  # Configuration options
  project = "terahform"
  region = "us-central-1"
  zone = "us-central1-a"
  credentials = var.gcp_credentials
}

