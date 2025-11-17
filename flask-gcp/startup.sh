# flask-gcp/startup.sh
#!/bin/bash
set -euo pipefail

# Log everything for debugging
exec >/var/log/startup.log 2>&1
echo "=== STARTUP SCRIPT STARTED: $(date) ==="

# Update system
apt-get update -y

# Install Apache (for quick health check on port 80)
apt-get install -y apache2 ufw curl gnupg lsb-release

# Enable and start Apache
systemctl enable apache2
systemctl start apache2

# Write a nice homepage
cat >/var/www/html/index.html <<'EOF'
<!DOCTYPE html>
<html>
<head><title>Flask VM – ${ENVIRONMENT}</title></head>
<body style="font-family: system-ui; text-align: center; margin-top: 5rem;">
  <h1>Hello from ${ENVIRONMENT}!</h1>
  <p>Terraform workspace: <strong>${TERRAFORM_WORKSPACE}</strong></p>
  <p>Flask app will be available on port 5000 once Docker setup is added.</p>
  <p>SSH: <code>ssh ${SSH_USER}@$(curl -s http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip -H 'Metadata-Flavor: Google')</code></p>
  <p>Check logs: <code>cat /var/log/startup.log</code></p>
</body>
</html>
EOF

# Open ports with ufw (safe on Debian)
ufw allow 22 || true
ufw allow 80 || true
ufw allow 5000 || true # future Flask port
ufw --force enable || true

echo "=== STARTUP SCRIPT COMPLETED: $(date) ==="
