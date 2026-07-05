variable "amplify_repository_url" {
  type        = string
  sensitive   = true
  description = "GitHub repository URL for the React app"
}

variable "amplify_github_access_token" {
  type        = string
  sensitive   = true
  description = "GitHub personal access token for Amplify to access the repository"
}
