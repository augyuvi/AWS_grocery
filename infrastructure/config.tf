#############################################
# config.tf – global settings for GroceryMate
#############################################

# I define the Terraform version and AWS provider I want to use.
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# I tell Terraform to use my SSO CLI profile "default" and region from variable.
provider "aws" {
  profile = "default"
  region  = var.aws_region
}

# Basic metadata about my project and environment.
variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "GroceryMate"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "owner" {
  description = "Project owner name"
  type        = string
  default     = "Nithya Srinivasan"
}

# I keep the region configurable but default to Frankfurt.
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "eu-central-1"
}

# I choose a free-tier eligible EC2 instance type.
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

# This must match the key pair I created manually in the AWS console.
variable "key_pair_name" {
  description = "Existing EC2 key pair name"
  type        = string
  default     = "Masterschool- EC2 -key"
}

# For learning I allow SSH from anywhere; in real life I would lock this to my /32 IP.
variable "ssh_allowed_ip" {
  description = "CIDR allowed for SSH access"
  type        = string
  default     = "0.0.0.0/0"
}

# I allow HTTP and app traffic from the internet so I can test from my browser.
variable "http_allowed_cidrs" {
  description = "CIDR blocks allowed for HTTP/app access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# Database settings for my PostgreSQL RDS instance.
variable "db_username" {
  description = "Master username for PostgreSQL"
  type        = string
  default     = "grocery_user"
}

variable "db_password" {
  description = "Master password for PostgreSQL"
  type        = string
  sensitive   = true
}

# I choose a free-tier–eligible RDS instance class.
variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

# I stay within free-tier storage size.
variable "db_allocated_storage" {
  description = "Database storage in GiB"
  type        = number
  default     = 20
}

# I keep common tags here so I can reuse them across all resources.
variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default = {
    Project   = "GroceryMate"
    ManagedBy = "Terraform"
    Owner     = "Nithya Srinivasan"
  }
}
