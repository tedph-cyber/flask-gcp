# 🚀 Terraform GCP VM Deployment (via GitHub Actions)

This project automates the provisioning and management of a **Google Cloud Compute Engine VM** using **Terraform**, fully integrated with **GitHub Actions**.  
All infrastructure changes — from creation to destruction — are managed directly from GitHub, ensuring a secure, repeatable, and version-controlled workflow.

---

## 🧱 Features

- **Infrastructure-as-Code (IaC)** using Terraform  
- **GitHub Actions CI/CD** for automated deploys and destroys  
- **GCP VM instance** creation with:
  - External IP and SSH access
  - Debian 12 base image
  - Startup script execution
- **Firewall rule** to allow secure SSH access
- Fully managed authentication via **GCP Service Account**

---

## 🗂️ Project Structure
.
├── app.py
├── Dockerfile
├── flaskform.json
├── flask-gcp
│   ├── main.tf
│   ├── outputs.tf
│   ├── provider.tf
│   ├── startup.sh.tftpl
│   └── variables.tf
├── README.md
└── requirements.txt

---

## ⚙️ Prerequisites

1. A **Google Cloud Project** (with Compute Engine enabled)
2. A **Service Account** with the following roles:
   - `roles/editor` or equivalent permissions
3. Generated **JSON key file** for the service account
4. A **GitHub repository** to store this Terraform code

---

## 🔐 GitHub Secrets Setup

Go to your repo → `Settings → Secrets and variables → Actions → New repository secret`

| Secret Name | Description |
|--------------|-------------|
| `GCP_CREDENTIALS` | Base64-encoded content of your GCP service account key file |
| `GCP_PROJECT_ID`  | Your GCP project ID |
| `GCP_REGION`      | e.g., `us-central1` |

To create the Base64 key:
```bash
cat ~/terraform-key.json | base64 -w0

