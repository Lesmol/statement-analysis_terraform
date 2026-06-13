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



moved {
  from = aws_ecr_repository.statement_analysis_repository
  to   = module.artifact-registry.aws_ecr_repository.statement_analysis_repository
}

moved {
  from = aws_s3_bucket.statement_analysis_docs
  to   = module.storage.aws_s3_bucket.statement_analysis_docs
}

moved {
  from = aws_sns_topic.statement_analysis_textract_completion_topic
  to   = module.processing-pipes.aws_sns_topic.statement_analysis_textract_completion_topic
}

moved {
  from = aws_sqs_queue.statement_analysis_textract_completion_queue
  to   = module.processing-pipes.aws_sqs_queue.statement_analysis_textract_completion_queue
}

moved {
  from = aws_sqs_queue.statement_analysis_deadletter_queue
  to   = module.processing-pipes.aws_sqs_queue.statement_analysis_deadletter_queue
}

moved {
  from = aws_sqs_queue_redrive_allow_policy.statement_analysis_textract_completion_queue_redrive_allow_policy
  to   = module.processing-pipes.aws_sqs_queue_redrive_allow_policy.statement_analysis_textract_completion_queue_redrive_allow_policy
}

moved {
  from = aws_sns_topic_subscription.sns_to_sqs_subscription
  to   = module.processing-pipes.aws_sns_topic_subscription.sns_to_sqs_subscription
}

moved {
  from = aws_sqs_queue_policy.sns_to_sqs_policy
  to   = module.processing-pipes.aws_sqs_queue_policy.sns_to_sqs_policy
}

moved {
  from = aws_iam_role.textract_sns_role
  to   = module.processing-pipes.aws_iam_role.textract_sns_role
}

moved {
  from = aws_iam_role_policy.textract_sns_publish_policy
  to   = module.processing-pipes.aws_iam_role_policy.textract_sns_publish_policy
}

moved {
  from = aws_lambda_function.statement_analysis_function
  to   = module.compute.aws_lambda_function.statement_analysis_function
}

moved {
  from = aws_iam_role.lambda_exec
  to   = module.compute.aws_iam_role.lambda_exec
}

moved {
  from = aws_iam_role_policy.lambda_policy
  to   = module.compute.aws_iam_role_policy.lambda_policy
}