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

resource "aws_sqs_queue_subscription" "sns_to_sqs_subscription" {
  topic_arn = aws_sns_topic.statement_analysis_textract_completion_topic.arn
  queue_url = aws_sqs_queue.statement_analysis_textract_completion_queue.id
  protocol  = "sqs"
}

resource "aws_sqs_queue_policy" "sns_to_sqs_policy" {
  queue_url = aws_sqs_queue.statement_analysis_textract_completion_queue.id
  policy    = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "sns.amazonaws.com" }
        Action    = "sqs:SendMessage"
        Resource  = aws_sqs_queue.statement_analysis_textract_completion_queue.arn
        Condition = {
          ArnEquals = { "aws:SourceArn" = aws_sns_topic.statement_analysis_textract_completion_topic.arn }
        }
      }
    ]
  })
}
