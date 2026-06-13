# Statement Analysis Infrastructure 🏗️

This repository contains the Terraform Infrastructure as Code (IaC) configuration for a serverless, asynchronous bank statement analysis backend. The infrastructure provisions a multi-region AWS environment designed to process documents using AWS Textract and draw insights using the Claude API.

## 🚀 Features

* **Modular Architecture**: Cleanly separated Terraform modules isolating compute, storage, artifact registries, and messaging pipes to minimize blast radius.
* **Multi-Region Deployment**: Intelligently routes core infrastructure (S3 state, IAM, compute) to `af-south-1` while provisioning Textract pipelines and messaging components in `eu-west-1` for optimal service availability.
* **Asynchronous Processing Pipeline**: Fully configured AWS SNS and SQS integration (including Dead Letter Queues and redrive policies) to handle asynchronous Textract job completions securely.
* **Serverless Compute**: Provisions AWS Lambda to run containerized image deployments directly from Amazon ECR.
* **Secure State Management**: Utilizes remote S3 backend state tracking, state locking and encryption.

## 💻 Tech Stack

* **IaC Framework**: Terraform (v1.10+).
* **Cloud Provider**: AWS (Regions: af-south-1, eu-west-1).
* **Compute**: AWS Lambda, Amazon ECR.
* **Storage**: Amazon S3.
* **Messaging & AI**: Amazon SQS, Amazon SNS, AWS Textract.

## 📦 Infrastructure Modules

The project is organized into dedicated, reusable child modules:

### 1. Artifact Registry (`/modules/artifact-registry`)
Provisions the ECR repository with image scanning on push enabled.

### 2. Storage (`/modules/storage`)
Provisions the S3 bucket used for uploading and storing the raw bank statements.

### 3. Processing Pipes (`/modules/processing-pipes`)
Sets up the asynchronous messaging backbone in `eu-west-1`.
* **SNS**
* **SQS**
* **IAM**

### 4. Compute (`/modules/compute`)
Provisions the Lambda function. It pulls the latest Docker image from the artifact registry..

## ⚙️ Configuration and Deployment

### CI/CD 🛠️
This project includes automated GitHub Actions workflows for safe infrastructure management:
* **Provision Infrastructure** (`.github/workflows/provision-infra.yml`): Runs `terraform plan` and `terraform apply` upon manual dispatch to safely deploy or update resources.
* **Destroy Infrastructure** (`.github/workflows/destroy-infra.yml`): Safely tears down the environment via `terraform destroy` upon manual dispatch to prevent orphaned resources.