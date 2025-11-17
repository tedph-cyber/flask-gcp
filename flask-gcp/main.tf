# main.tf
locals {
  environment = terraform.workspace == "default" ? "dev" : terraform.workspace
  name_prefix = "flask-vm-${local.environment}"

  # Common labels – appear on VM, firewall, billing reports, etc.
  common_labels = {
    environment = local.environment
    managed-by  = "terraform"
    app         = "flask"
    owner       = "tedph"
  }
}

data "google_compute_network" "default" {
  name = "default"
}

# Firewall – only created once (idempotent across workspaces)
resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh-${local.environment}"
  network = data.google_compute_network.default.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]  # Restrict this in prod!
  target_tags   = ["ssh-allowed-${local.environment}"]

  # labels = local.common_labels
}

# VM instance – different name & tags per workspace
resource "google_compute_instance" "flask_instance" {
  name         = local.name_prefix
  machine_type = local.environment == "prod" ? "e2-small" : "e2-micro"
  zone         = "us-central1-a"
  tags         = ["ssh-allowed-${local.environment}"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    network = data.google_compute_network.default.name
    access_config {} # Ephemeral public IP
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.ssh_public_key_path)}"
  }

  # Simple startup script – feel free to replace with your full Docker one later
  metadata_startup_script = templatefile(
    "${path.module}/startup.sh",
    {
      ENVIRONMENT         = local.environment
      TERRAFORM_WORKSPACE = terraform.workspace
      SSH_USER            = var.ssh_user
    }
  )

  labels = merge(local.common_labels, {
    instance-type = local.environment == "prod" ? "production" : "development"
  })

  # Make sure firewall exists first
  depends_on = [google_compute_firewall.allow_ssh]
}
