variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "af-south-1"
}

variable "cognito_domain_prefix" {
  description = "Prefix for Cognito hosted UI domain"
  type        = string
  default     = "statement-analysis"
}
