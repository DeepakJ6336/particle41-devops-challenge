
# **Particle41 DevOps Challenge – Submission by Deepak Yadav**

This repository contains my completed solution for the Particle41 DevOps Team Challenge.

It includes:

* A minimal web service (`SimpleTimeService`)
* A Docker image published to DockerHub
* AWS infrastructure using Terraform (server-based: ECS on EC2)
* A Jenkins pipeline (extra credit)
* A remote Terraform backend using S3 + DynamoDB (extra credit)

---

# **Table of Contents**

1. [Overview](#overview)
2. [Task 1 – Application & Docker](#task-1--simpletimeservice-application--docker)

   * Build & Run Locally
   * Run from DockerHub
3. [Task 2 – Terraform & AWS](#task-2--terraform--aws-server-based-ecs-on-ec2)

   * Infrastructure Diagram (Text)
   * Variables
   * Deployment
   * Destruction
4. [Extra Credit – Remote Backend](#extra-credit--remote-terraform-backend-s3--dynamodb)
5. [Extra Credit – Jenkins Pipeline](#extra-credit--jenkins-pipeline)
6. [Repository Structure](#repository-structure)
7. [Final Notes](#final-notes)

---

# **Overview**

This challenge demonstrates:

* Designing a minimal JSON API
* Packaging it into a Docker container
* Running the container as a **non-root** user
* Deploying everything on AWS via **Terraform**
* Using ECS (EC2 launch type) — **server-based option chosen**
* Storing Terraform state in **S3 + DynamoDB**
* Adding a Jenkins CI/CD pipeline for automation

The project is structured so that **any reviewer can clone the repository and deploy the setup easily**.

---

# **Task 1 – SimpleTimeService (Application + Docker)**

##  About the Service

A minimal FastAPI app that returns the current timestamp and the client IP.

Example output:

```
{
  "timestamp": "<current date and time>",
  "ip": "<client ip>"
}
```

---

##  Build & Run Locally

```
cd app
docker build -t deepakyadavj6/simple-time-service:latest .
docker run -p 8000:8000 deepakyadavj6/simple-time-service:latest
```

Open in browser:

```
http://localhost:8000
```

---

##  Run Directly From DockerHub

```
docker pull deepakyadavj6/simple-time-service:latest
docker run -p 8000:8000 deepakyadavj6/simple-time-service:latest
```

---

##  Container Practices Followed

* Runs as a **non-root user** (`appuser`)
* Uses `python:3.11-slim` (lightweight)
* Final image size ~57 MB

---

# **Task 2 – Terraform & AWS (Server-Based: ECS on EC2)**

For this challenge, I selected:

 **Server-based option → AWS ECS (EC2 Launch Type)**
(not using serverless/Lambda)

Terraform provisions the entire AWS environment.

---

##  Infrastructure Created (Text Diagram)

```
VPC
├── Public Subnets (2)
│     └── Application Load Balancer
└── Private Subnets (2)
      └── ECS Cluster (EC2 Launch Type)
            └── ECS Service running Docker container
```

ECS tasks run in **private** subnets.
ALB exposes the service to the Internet.

---

##  Terraform Variables

All user-editable values live here:

```
terraform/terraform.tfvars
```

Example:

```
aws_region      = "ap-south-1"
project_name    = "particle41-devops"
container_image = "deepakyadavj6/simple-time-service:latest"
desired_count   = 2
instance_type   = "t3.small"
```

---

##  Deploy the Infrastructure

```
cd terraform
terraform init
terraform plan
terraform apply
```

Terraform prints an ALB DNS name:

```
http://<alb-dns-name>.elb.amazonaws.com
```

Open it to view the running service.

---

##  Destroy the Infrastructure

```
terraform destroy
```

This removes all resources:

* VPC
* Subnets
* ECS cluster
* ECS nodes (EC2 instances)
* ALB
* IAM roles / security groups

---

# **Extra Credit – Remote Terraform Backend (S3 + DynamoDB)**

Terraform state is stored remotely using:

```
S3 Bucket       → state storage
DynamoDB Table  → state locking
```

Backend configuration (in `provider.tf`):

```
terraform {
  backend "s3" {
    bucket         = "particle41-devops-tfstate-deepakyadav"
    key            = "terraform/infra.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

This provides:

* Centralized, durable state
* Locking to prevent parallel applies
* No local `.tfstate` file

---

# **Extra Credit – Jenkins Pipeline**

A `Jenkinsfile` is included.

### The pipeline does:

1. Checks out the repository
2. Builds Docker image from `/app`
3. Pushes image to DockerHub
4. (Optional) Runs Terraform `init`, `fmt`, and `plan`

### Jenkins Credentials

* Jenkins uses a secure **DockerHub credential** (`dockerhub-creds`)
* No secrets are committed to this repository

---

# **Repository Structure**

```
app/
  Dockerfile
  main.py
  requirements.txt

terraform/
  main.tf
  provider.tf
  variables.tf
  outputs.tf
  terraform.tfvars

Jenkinsfile
README.md
```

---

**Final Notes**

* App runs as **non-root** (security best practice)
* Lightweight Docker image
* ECS tasks run privately; ALB handles public traffic
* No secrets or AWS keys stored in repo
* Terraform backend stored remotely (S3 + DynamoDB)
* Deployment and destruction require only:

  * terraform apply
  * terraform destroy

This repository is prepared and ready for review.

---

