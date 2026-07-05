variable "app_name" {
  type    = string
  default = "statement-analysis"
}

variable "repository_url" {
  type        = string
  description = "GitHub repository URL for the React app"
}

variable "github_access_token" {
  type        = string
  sensitive   = true
  description = "GitHub personal access token for Amplify to access the repository"
}

variable "branch_name" {
  type    = string
  default = "main"
}

variable "api_gateway_url" {
  type        = string
  description = "API Gateway endpoint URL"
}
