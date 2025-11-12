variable "gcp_credentials" {
  description = "Base64 encoded GCP service account JSON key"
  type        = string
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "ssh_user" {
  description = "Username for SSH access"
  type        = string
  default     = "ted"
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key"
  type        = string
  default     = "/tmp/ssh/id_rsa.pub"
}

