# DevOps Project - Part 2  
# AWS Infrastructure Automation with Terraform and Ansible

## Overview

This project demonstrates a fully automated cloud-based application environment deployed on AWS using:

- Terraform for Infrastructure as Code
- Ansible for Configuration Management

The project simulates a production-style environment with separated services and automated deployment.

The infrastructure and server configuration are created automatically without manual setup.

---

# Architecture

User
 |
 v
Frontend (NGINX - EC2)
 |
 v
Backend (Flask API - EC2)
 |
 +--> RDS PostgreSQL
 |
 +--> S3 Bucket
 |
 +--> SNS Topic
 |
 v
Worker Service (EC2)

---

# Architecture Components

| Component | Type | Purpose |
|---|---|---|
| Frontend | EC2 + NGINX | Reverse proxy and HTTP access |
| Backend | EC2 + Flask | API service and AWS integrations |
| Worker | EC2 | Background processing tasks |
| RDS | PostgreSQL | Database storage |
| S3 | AWS S3 | File storage |
| SNS | AWS SNS | Email notifications |
| Terraform | Infrastructure as Code | Infrastructure provisioning |
| Ansible | Automation | Server configuration |

---

# Data Flow

1. User sends HTTP request to the frontend server.
2. NGINX forwards traffic to the backend Flask application.
3. Backend service:
   - Reads and writes data to PostgreSQL
   - Uploads files to S3
   - Sends notifications using SNS
4. Worker service performs background processing tasks.

---

# Terraform Responsibilities

Terraform automatically creates:

- VPC
- Public and private subnets
- Internet Gateway
- Route Tables
- Security Groups
- EC2 Instances
- RDS PostgreSQL Database
- S3 Bucket
- SNS Topic
- IAM Roles and Policies

---

# Terraform Commands

Initialize Terraform:

```bash
terraform init

Review execution plan:

terraform plan

Create infrastructure:

terraform apply

Destroy infrastructure:

terraform destroy
Terraform State Management

Terraform state is managed locally using the terraform.tfstate file.

The state file stores:

Infrastructure resource mappings
Resource IDs
Current infrastructure state

The .tfstate files are excluded from GitHub using .gitignore because they may contain sensitive information.

Ansible Responsibilities

Ansible automatically configures all EC2 instances after Terraform deployment.

Ansible Roles
Role	Purpose
common	Common server configuration
nginx	Install and configure NGINX
backend	Deploy Flask backend application
worker	Configure worker service
Ansible Playbook
- hosts: all
  become: yes
  roles:
    - common

- hosts: frontend
  become: yes
  roles:
    - nginx

- hosts: backend
  become: yes
  roles:
    - backend

- hosts: worker
  become: yes
  roles:
    - worker
Ansible Inventory
[frontend]
<FRONTEND_PUBLIC_IP>

[backend]
<BACKEND_PUBLIC_IP>

[worker]
<WORKER_PUBLIC_IP>
Run Ansible
ansible-playbook -i inventory.ini playbook.yml
Backend Service

The backend service is a Flask application that:

Exposes REST API endpoints
Stores data in PostgreSQL
Uploads files to S3
Sends notifications using SNS
Backend API Endpoints
Method	Endpoint	Description
GET	/	Health check
GET	/users	Get users
POST	/add_user	Add user
POST	/upload	Upload file
NGINX Reverse Proxy

NGINX runs on the frontend EC2 instance and forwards requests to the backend server.

Example configuration:

server {
    listen 80;

    location / {
        proxy_pass http://<BACKEND_PRIVATE_IP>:5000;
    }
}
Security Groups

Security Groups were configured using least privilege access.

Frontend Security Group
Allow HTTP (80) from 0.0.0.0/0
Allow SSH (22) only when required
Backend Security Group
Allow port 5000 only from frontend security group
Allow outbound access to RDS, S3, SNS
RDS Security Group
Allow PostgreSQL port 5432 only from backend and worker instances
Variables

Terraform variables are used for:

AWS region
EC2 instance types
Database configuration
Key pair name
VPC CIDR ranges

Sensitive values are not stored in GitHub.

Secrets Management

Secrets and sensitive values are excluded from the repository.

Examples:

Database password
RDS endpoint
SNS topic ARN
PEM private keys

Sensitive values are replaced with placeholders such as:

<DB_PASSWORD>
<RDS_ENDPOINT>
<SNS_TOPIC_ARN>
Testing
Verify Terraform Infrastructure
terraform output
Verify Ansible Deployment
ansible-playbook -i inventory.ini playbook.yml
Test HTTP Access
curl http://<FRONTEND_PUBLIC_IP>
Test Backend API
curl http://<FRONTEND_PUBLIC_IP>/users
Add User
curl -X POST \
-H "Content-Type: application/json" \
-d '{"name":"Alice"}' \
http://<FRONTEND_PUBLIC_IP>/add_user
Cleanup

Destroy all AWS resources:

terraform destroy
Challenges and Solutions
Challenge

Managing communication between multiple services across EC2 instances.

Solution

Used Security Groups and private networking for controlled communication.

Challenge

Automating infrastructure and application deployment.

Solution

Separated responsibilities:

Terraform for infrastructure provisioning
Ansible for server configuration and application deployment
Best Practices
Infrastructure as Code using Terraform
Configuration management using Ansible
Separation of infrastructure and application layers
Least privilege IAM permissions
Security Group isolation
Automated deployment workflow
Secrets excluded from GitHub
Technologies Used
AWS EC2
AWS RDS PostgreSQL
AWS S3
AWS SNS
Terraform
Ansible
Python
Flask
NGINX
Linux
GitHub
Repository Structure
project-part2/
│
├── terraform/
│   ├── provider.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── main.tf
│
├── ansible/
│   ├── inventory.ini
│   ├── playbook.yml
│   └── roles/
│       ├── common/
│       ├── nginx/
│       ├── backend/
│       └── worker/
│
├── README.md
