# SQS Service Provisioning
resource "aws_sqs_queue" "statement_analysis_textract_completion_queue" {
  name = "textract-completion-queue"
  visibility_timeout_seconds = 300

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.statement_analysis_deadletter_queue.arn
    maxReceiveCount     = 2
  })
}

resource "aws_sqs_queue" "statement_analysis_deadletter_queue" {
  name = "textract-deadletter-queue"
}

resource "aws_sqs_queue_redrive_allow_policy" "statement_analysis_textract_completion_queue_redrive_allow_policy" {
  queue_url = aws_sqs_queue.statement_analysis_deadletter_queue.id

  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue",
    sourceQueueArns   = [aws_sqs_queue.statement_analysis_textract_completion_queue.arn]
  })
}

resource "aws_sns_topic_subscription" "sns_to_sqs_subscription" {
  topic_arn = aws_sns_topic.statement_analysis_textract_completion_topic.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.statement_analysis_textract_completion_queue.arn
  provider  = aws.textract-region

  depends_on = [aws_sns_topic.statement_analysis_textract_completion_topic, aws_sqs_queue.statement_analysis_textract_completion_queue]
}

data "aws_iam_policy_document" "sns_to_sqs" {
  statement {
    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.statement_analysis_textract_completion_queue.arn]
    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }
    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_sns_topic.statement_analysis_textract_completion_topic.arn]
    }
  }
}

resource "aws_sqs_queue_policy" "sns_to_sqs_policy" {
  queue_url = aws_sqs_queue.statement_analysis_textract_completion_queue.id
  policy    = data.aws_iam_policy_document.sns_to_sqs.json
}


# SNS Service Provisioning
resource "aws_sns_topic" "statement_analysis_textract_completion_topic" {
  name = "textract-completion-topic"
  provider = aws.textract-region
}


# IAM Roles
data "aws_iam_policy_document" "textract_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["textract.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "textract_sns_publish" {
  statement {
    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.statement_analysis_textract_completion_topic.arn]
  }
}

resource "aws_iam_role" "textract_sns_role" {
  name               = "TextractSNSPublishRole"
  assume_role_policy = data.aws_iam_policy_document.textract_assume_role.json
}

resource "aws_iam_role_policy" "textract_sns_publish_policy" {
  name   = "TextractSNSPublishPolicy"
  role   = aws_iam_role.textract_sns_role.id
  policy = data.aws_iam_policy_document.textract_sns_publish.json
}