variable "region" {
  description = "AWS region to deploy resources into"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"

  # validation {
  #   condition     = contains(["t3.micro", "t3.small", "t3.medium"], var.instance_type)
  #   error_message = "Instance type must be t3.micro, t3.small, or t3.medium."
  # }
}

variable "key_name" {
  description = "Name of an existing EC2 key pair for SSH access"
  type        = string
  default     = "linux-demo-kp"
}

variable "server" {
  description = "Base name for the web server resource"
  type        = string
  default     = "web-server"
}

variable "demo" {
  description = "Demo tag value for resource identification"
  type        = string
  default     = "tf-demo"
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
  default     = "dev"

  # validation {
  #   condition     = contains(["dev", "staging", "prod"], var.environment)
  #   error_message = "Environment must be one of: dev, staging, prod."
  # }
}

variable "owner" {
  description = "Owner tag for resource tracking"
  type        = string
  default     = "SE Team"
}

# -----------------------------------------------
# GitHub Actions deployment provenance
# Set automatically by the apply workflow via -var flags.
# Defaults to "local" so manual terraform runs still work.
# -----------------------------------------------
variable "github_run_id" {
  description = "GitHub Actions Run ID that triggered this deploy"
  type        = string
  default     = "local"
}

variable "github_sha" {
  description = "Git commit SHA that was deployed"
  type        = string
  default     = "local"
}

variable "github_actor" {
  description = "GitHub username that triggered the workflow"
  type        = string
  default     = "local"
}
