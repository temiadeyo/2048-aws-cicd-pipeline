variable "region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_cidr" {
  default = "10.1.0.0/16"
}

variable "public_subnet_a_cidr" {
  description = "CIDR block for subnet a"
  type        = string
  default     = "10.1.1.0/24"
}

variable "public_subnet_b_cidr" {
  description = "CIDR block for subnet b"
  type        = string
  default     = "10.1.2.0/24"
}

variable "private_subnet_a_cidr" {
  description = "CIDR block for private subnet A"
  type        = string
  default     = "10.1.11.0/24"
}

variable "private_subnet_b_cidr" {
  description = "CIDR block for private subnet B"
  type        = string
  default     = "10.1.12.0/24"
}

variable "github_owner" {
  description = "GitHub username or organization"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}

variable "github_repository_url" {
  description = "GitHub repository URL"
  type        = string
}

variable "github_connection_arn" {
  description = "AWS CodeConnections ARN for GitHub"
  type        = string
}