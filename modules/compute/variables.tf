variable "ecr_repository_url" { type = string }
variable "s3_bucket_name"     { type = string }
variable "statement_analysis_function_name" {
    default = "statement-analysis-function"
}