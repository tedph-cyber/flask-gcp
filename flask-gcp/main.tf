data "google_compute_network" "default" {
  name = "default"
}

# Allow SSH ingress on the default network
resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"] # You can restrict this later
  target_tags   = ["ssh-allowed"]

  depends_on = [
    google_compute_network.default
  ]
}

# Create a compute instance with SSH access
resource "google_compute_instance" "vm_instance" {
  name         = "tf-vm"
  machine_type = "e2-micro"
  zone         = "us-central1-a"
  tags         = ["ssh-allowed"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    network = "default"
    access_config {} # gives external IP
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.ssh_public_key_path)}"
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    echo 'Hello from Terraform via GitHub Actions with SSH enabled!' > /var/www/html/index.html
  EOT
}

