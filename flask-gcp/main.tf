# import/use exisiting network
data "google_compute_network" "default" {
  name = "default"
}

# Allow SSH ingress on the default network
resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = data.google_compute_network.default.name
  
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"] # You can restrict this later
  target_tags   = ["ssh-allowed"]

  depends_on = [
    data.google_compute_network.default
  ]
}

# Create a compute instance with SSH access
resource "google_compute_instance" "flask_instance" {
  name         = "flask-vm"
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

  label = {
    environment = terraform.workspace == "default" ? "dev" : terraform.workspace 
    project = var.project_id
    owner = var.ssh_user
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.ssh_public_key_path)}"
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    apt-get update -y
    apt-get install -y ca-certificates curl gnupg lsb-release

    # Install Docker
    apt-get install -y docker.io
    systemctl enable docker
    systemctl start docker

    # Authenticate GCR
    echo "${credentials}" > /root/key.json
    gcloud auth activate-service-account --key-file=/root/key.json
    gcloud auth configure-docker -q

    # Pull image from GCR
    docker pull gcr.io/${project_id}/${image_name}:${tag}

    # Stop any old container
    docker rm -f myapp || true

    # Run container
    docker run -d -p 5000:5000 --name myapp gcr.io/${project_id}/${image_name}:${tag}

    # homepage?
    echo 'Hello from Terraform via GitHub Actions with SSH enabled! I just try boss!' > /var/www/html/index.html
  EOT
}

