resource "aws_ecr_repository" "statement_analysis_repository" {
  name                 = "statement-analysis-repository"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }
}