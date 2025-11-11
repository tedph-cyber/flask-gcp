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

resource "google_compute_instance" "vm_instance" {
  name         = "tf-vm"
  machine_type = "e2-micro"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata_startup_script = "echo Hello from Terraform > /var/www/html/index.html"
}

