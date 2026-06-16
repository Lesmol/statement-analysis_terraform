module "artifact-registry" {
  source = "./modules/artifact-registry"
}

module "storage" {
  source = "./modules/storage"
  providers = {
    aws = aws.textract-region
    aws.textract-region = aws.textract-region
  }
}

module "processing-pipes" {
  source = "./modules/processing-pipes"
  providers = {
    aws = aws.textract-region
    aws.textract-region = aws.textract-region
  }
}

module "compute" {
  source             = "./modules/compute"
  ecr_repository_url = module.artifact-registry.repository_url
  s3_bucket_name     = module.storage.bucket_name
}

module "api_gateway" {
  source = "./modules/api-gateway"
  lambda_integration_invoke_arn = module.compute.statement_analysis_function_invoke_arn
  lambda_function_name = module.compute.statement_analysis_function_name
}
