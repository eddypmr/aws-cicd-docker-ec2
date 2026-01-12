# CI/CD Pipeline with Docker on AWS EC2

This project demonstrates a complete **CI/CD pipeline** that automatically deploys a Dockerized web application to an **AWS EC2** instance using **GitHub Actions**.

The infrastructure is provisioned using **Terraform**, following Infrastructure as Code (IaC) best practices.

---

## What this project shows

- Automated infrastructure provisioning with Terraform
- Dockerized application deployment
- CI/CD pipeline using GitHub Actions
- Automatic deployment on every `git push`
- Real-world DevOps workflow (build → deploy → run)

---

## Architecture Overview
```
GitHub (push to main)
↓
GitHub Actions (CI/CD pipeline)
↓
SSH connection
↓
AWS EC2 (Docker installed)
↓
Docker container (Nginx serving the app)
```
---



---

## Tech Stack

- AWS EC2
- Terraform
- Docker
- GitHub Actions
- Amazon Linux 2023
- Nginx

---

## Repository Structure
```
.
├── app/
│ ├── Dockerfile
│ └── index.html
├── infra/
│ ├── main.tf
│ └── .gitignore
└── .github/
 └── workflows/
  └── deploy.yml
```
---

## Infrastructure (Terraform)

The infrastructure is defined in the `infra/` directory and includes:

- Custom VPC and public subnet
- Internet Gateway and routing
- Security Group (HTTP + SSH)
- EC2 instance with Docker and Git installed
- SSH key pair configuration

### Create infrastructure
```bash
cd infra
terraform init
terraform apply
```

### Destroy infrastructure
terraform destroy


### 📌 Notes

Infrastructure can be destroyed safely after testing to avoid unnecessary AWS costs.

SSH access is temporarily opened to allow GitHub Actions to deploy.

