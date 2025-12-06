Particle41 DevOps Challenge – Submission by Deepak Yadav

This repository contains my solution for the Particle41 DevOps Team Challenge.

It includes:
-A minimal web service (SimpleTimeService)
-A Docker image published to DockerHub
-AWS infrastructure using Terraform (server-based: ECS on EC2)
-A Jenkins pipeline (extra credit)
-A remote Terraform backend using S3 + DynamoDB (extra credit)

Summary

This solution demonstrates:
-Building a tiny web API that returns JSON
-Containerizing it with Docker
-Running the container as a non-root user
-Deploying to AWS ECS (EC2 launch type) using Terraform
-Using an S3 + DynamoDB backend for Terraform state
-Automating image build and push with Jenkins

Task 1 – SimpleTimeService (Application + Docker)

About the Service
SimpleTimeService is a small FastAPI app that returns:

{
  "timestamp": "<current date and time>",
  "ip": "<client ip>"
}

Build & Run Locally
cd app
docker build -t deepakyadavj6/simple-time-service:latest .
docker run -p 8000:8000 deepakyadavj6/simple-time-service:latest

Open in browser:

http://localhost:8000

Run Directly From DockerHub
docker pull deepakyadavj6/simple-time-service:latest
docker run -p 8000:8000 deepakyadavj6/simple-time-service:latest


The container runs as a non-root user (appuser)
-Uses python:3.11-slim as base image
-Image size is around 57 MB

Task 2 – Terraform + AWS (Server-Based: ECS on EC2):

For Task 2, I chose the server-based option
ECS on EC2 in a VPC (not serverless/Lambda)

Infrastructure Provisioned
Terraform creates:
A VPC with:
-2 public subnets
-2 private subnets
An ECS Cluster (EC2 launch type)
An Auto Scaling Group for ECS worker nodes (private subnets)
An Application Load Balancer (public subnets)
An ECS Service running my Docker image
Supporting networking and IAM roles

ECS tasks run in private subnets.
Traffic comes in via the ALB in public subnets.
Terraform Variables

All configurable values are in:
terraform/terraform.tfvars
Example:

aws_region      = "ap-south-1"
project_name    = "particle41-devops"
container_image = "deepakyadavj6/simple-time-service:latest"
desired_count   = 2
instance_type   = "t3.small"

Deploying the Infrastructure

From the terraform directory:
cd terraform
terraform init
terraform plan
terraform apply


When apply completes, Terraform prints an ALB DNS name, for example:

alb_dns_name = http://<your-alb-dns>.elb.amazonaws.com

Open that URL in your browser to see the JSON response from the service.

Destroying the Infrastructure
To remove all resources:
cd terraform
terraform destroy

This tears down:
VPC and subnets
ECS cluster and service
EC2 instances
ALB and related resources
Security groups and IAM roles
Extra Credit – Remote Terraform Backend (S3 + DynamoDB)

Terraform state is stored remotely using an S3 bucket with DynamoDB for locking.

Backend configuration:

terraform {
  backend "s3" {
    bucket         = "particle41-devops-tfstate-deepakyadav"
    key            = "terraform/infra.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}


This enables:

Remote state
State locking
No local .tfstate

Extra Credit – Jenkins Pipeline

A Jenkinsfile is included in the repo.

The pipeline:

Checks out the repository
-Builds the Docker image from app/
-Pushes the image to DockerHub
-Runs Terraform commands (init, fmt, plan)
-Jenkins uses DockerHub credentials (dockerhub-creds).
-No credentials are stored in this repository.

Repository Structure:
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

Final Notes:
-Application runs as non-root
-Docker image is small and based on a slim Python image
-ECS tasks are in private subnets
-ALB exposes the service externally
-No secrets or keys are committed
-Terraform can deploy and destroy the whole stack with 2 commands
