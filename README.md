# GroceryMate

## 🏆 GroceryMate E-Commerce Platform

[![Python](https://img.shields.io/badge/Language-Python%2C%20JavaScript-blue)](https://www.python.org/)
[![OS](https://img.shields.io/badge/OS-Linux%2C%20Windows%2C%20macOS-green)](https://www.kernel.org/)
[![Database](https://img.shields.io/badge/Database-PostgreSQL-336791)](https://www.postgresql.org/)
[![IaC](https://img.shields.io/badge/IaC-Terraform-7B42BC)](https://www.terraform.io/)
[![CI/CD](https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-black)](https://github.com/features/actions)
[![AWS](https://img.shields.io/badge/Cloud-AWS-orange)](https://aws.amazon.com/)

⭐ **Star us on GitHub** — it motivates us a lot!  
> **Credits:** Original application by **Alejandro Román Ibañez**  
> **Cloud deployment + infrastructure work:** **Nithya Srinivasan**

--- 

## 📌 Table of Contents

- [Overview](#-overview)
- [What I Built (Cloud Track)](#-what-i-built-cloud-track)
- [Architecture Diagrams](#-architecture-diagrams)
- [AWS Services Used](#-aws-services-used)
- [Repo Structure](#-repo-structure)
- [Environment Variables](#-environment-variables)
- [Deployment (Terraform + GitHub Actions)](#-deployment-terraform--github-actions)
- [Screenshots](#-screenshots)
- [Troubleshooting](#-troubleshooting)
- [Rollback / Cleanup](#-rollback--cleanup)
- [FAQ](#-faq)
- [Glossary](#-glossary)
- [My Contributions](#-my-contributions)
- [Future Enhancements](#-future-enhancements)
- [License & Credits](#-license--credits)

---

## 🚀 Overview

**GroceryMate** is a full-stack grocery e-commerce app (**React + Flask**) deployed on AWS.

This README is written from a **Cloud Engineer** perspective: it explains the **AWS infrastructure + deployment setup** I implemented around the application.

Core user flows:
- Browse products
- Search products
- Favorites
- Profile avatar upload (S3)

---

## 🧱 What I Built (Cloud Track)

- Provisioned AWS infrastructure using **Terraform**
- Deployed the app on **EC2** (containerized/Docker)
- Configured **RDS (PostgreSQL)** for the application database
- Enabled **S3** for avatar uploads (and storage for artifacts/reports if needed)
- Centralized logs using **CloudWatch Logs**
- Automated deployment via **GitHub Actions** (Terraform workflow)

---

## 🗺️ Architecture Diagrams

### ✅ Main Architecture (Flow Diagram)

![Project Diagram](assets/Diagram/project-diagram.png)

---

## ☁️ AWS Services Used

| Service | Purpose |
|---|---|
| **EC2** | Runs the application (frontend + backend) |
| **ALB** | Public entrypoint and routing to EC2 |
| **RDS (PostgreSQL)** | Managed database |
| **S3** | Avatar storage (and optional artifacts/reports) |
| **IAM** | Roles/policies for EC2 + CI/CD |
| **CloudWatch Logs** | Centralized application logs |
| **VPC + Subnets + Route Tables** | Network isolation (public + private) |
| **Security Groups** | Traffic control between components |

---

## 🗂️ Repo Structure

```text
.
├── backend/
├── frontend/
├── infrastructure/        # Terraform (main deployment)
├── bootstrap/             # Terraform (remote state / initial setup) - if present
├── assets/
│   ├── Diagram/
│   │   └── project-diagram.png
│   └── Screenshots/
│       ├── homepage.png
│       ├── product-search.png
│       ├── favorites.png
│       └── avatar-upload.png
└── README.md
````

---

## 🔐 Environment Variables

Create a `.env` file (example shown below).
✅ Do **not** commit `.env` to GitHub.

Example:

```ini
JWT_SECRET_KEY=your_generated_key

POSTGRES_USER=grocery_user
POSTGRES_PASSWORD=your_password
POSTGRES_DB=grocerymate_db
POSTGRES_HOST=localhost
POSTGRES_URI=postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST}:5432/${POSTGRES_DB}
```

(Optional AWS-related variables if your code uses them)

```ini
AWS_REGION=eu-central-1
S3_BUCKET_NAME=your_bucket_name
```

---

## 🚀 Deployment (Terraform + GitHub Actions)

### Prerequisites

* AWS Account
* Terraform installed (if using local apply)
* GitHub Actions configured for deploy (and role/credentials set)

### GitHub Secrets (typical)

Keep names aligned with your workflow. Common ones:

* `TF_VAR_region`
* `TF_VAR_db_user`
* `TF_VAR_db_password`
* `TF_VAR_db_name`
* `TF_VAR_bucket_name`
* `TF_VAR_allowed_ssh_ip` *(optional)*
* `AWS_ROLE_ARN` *(if using OIDC role for GitHub Actions)*

### Deploy Steps (typical)

1. Push to your deploy branch (often `main`)
2. GitHub Actions runs Terraform (init/plan/apply)
3. Verify:

   * Application is reachable via **ALB DNS**
   * `/health` endpoint (if present) returns OK
   * App features work (browse/search/favorites/avatar)

---

## 📸 Screenshots

### ✅ Home / Landing

![Home](assets/Screenshots/homepage.png)

### ✅ Product Search

![Search](assets/Screenshots/product-search.png)

### ✅ Favorites Page

![Favorites](assets/Screenshots/favorites.png)

### ✅ Avatar Upload

![Avatar Upload](assets/Screenshots/avatar-upload.png)

---

## 🧯 Troubleshooting

**Terraform apply fails**

* Missing GitHub secrets / TF_VARs
* Wrong region / AMI / permissions
* State lock issues (if DynamoDB used)

**App not loading**

* Check EC2 user-data / cloud-init logs
* Confirm ALB target health checks
* Verify security group rules (ALB → EC2)

**RDS connection errors**

* DB is private: connection must be from EC2 inside VPC
* Missing SG rule: `RDS 5432` from `EC2 SG`
* Wrong endpoint or credentials in `.env`

**S3 upload fails**

* EC2 IAM role missing `s3:PutObject` / `s3:GetObject`
* Wrong bucket name/region

---

## 🔁 Rollback / Cleanup

### Destroy infrastructure

```sh
cd infrastructure
terraform destroy
```

If you have bootstrap resources:

```sh
cd ../bootstrap
terraform destroy
```

---

## ❓ FAQ

**How do I change the instance type?**
Update the Terraform variable for `instance_type` and apply.

**How do I access the database?**
Connect from an EC2 instance inside the VPC to the RDS endpoint (RDS is private by design).

**Where are avatars stored?**
In the configured S3 bucket.

---

## 📚 Glossary

* **VPC**: Private network in AWS
* **ALB**: Routes incoming traffic to EC2
* **EC2**: Virtual server to run the app
* **RDS**: Managed PostgreSQL database
* **S3**: Object storage (avatars/files)
* **IAM**: Permissions and roles
* **CloudWatch Logs**: Central logging

---

## 🙋‍♀️ My Contributions

* AWS deployment setup (VPC, Subnets, SGs, IAM, ALB, EC2)
* RDS PostgreSQL integration
* S3 integration for avatar upload
* CloudWatch logging
* Terraform structure + deployment workflow (GitHub Actions)
* README documentation + diagrams

---

## 🔮 Future Enhancements

* HTTPS using **ACM + ALB listener**
* **CloudFront** for static assets
* Monitoring dashboards + alarms
* Autoscaling improvements
* Add caching layer (Redis/ElastiCache)

---

## 📝 License & Credits

MIT License.

**Original project:** Alejandro Román Ibañez
**Cloud deployment + infrastructure documentation:** Nithya Srinivasan (2025)

```
```
