variable "grafana_cloud_aws_account_id" {
  description = "AWS account ID that Grafana Cloud uses to assume the CloudWatch read-only role"
  type        = string
  sensitive   = false
}

variable "grafana_external_id" {
  description = "External ID Grafana Cloud presents when assuming the CloudWatch read-only role"
  type        = string
  sensitive   = false
}

data "aws_iam_policy_document" "grafana_cloudwatch_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.grafana_cloud_aws_account_id}:root"]
    }

    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [var.grafana_external_id]
    }
  }
}

resource "aws_iam_role" "grafana_cloudwatch_datasource" {
  name               = "grafana-cloudwatch-datasource"
  assume_role_policy = data.aws_iam_policy_document.grafana_cloudwatch_assume_role.json
}

data "aws_iam_policy_document" "grafana_cloudwatch_readonly" {
  statement {
    sid    = "AllowReadingMetricsFromCloudWatch"
    effect = "Allow"
    actions = [
      "cloudwatch:ListMetrics",
      "cloudwatch:GetMetricData",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:ListTagsForResource",
      "cloudwatch:DescribeAlarmsForMetric",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowReadingLogsFromCloudWatch"
    effect = "Allow"
    actions = [
      "logs:DescribeLogGroups",
      "logs:GetLogGroupFields",
      "logs:StartQuery",
      "logs:StopQuery",
      "logs:GetQueryResults",
      "logs:GetLogEvents",
      "logs:DescribeLogStreams",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowReadingTagsInstancesRegionsFromEC2"
    effect = "Allow"
    actions = [
      "ec2:DescribeTags",
      "ec2:DescribeInstances",
      "ec2:DescribeRegions",
    ]
    resources = ["*"]
  }

  statement {
    sid       = "AllowReadingResourcesForTags"
    effect    = "Allow"
    actions   = ["tag:GetResources"]
    resources = ["*"]
  }

  statement {
    sid    = "AllowReadingXrayTraces"
    effect = "Allow"
    actions = [
      "xray:BatchGetTraces",
      "xray:GetTraceSummaries",
      "xray:GetTraceGraph",
      "xray:GetGroups",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "grafana_cloudwatch_readonly" {
  name   = "grafana-cloudwatch-datasource-policy"
  role   = aws_iam_role.grafana_cloudwatch_datasource.id
  policy = data.aws_iam_policy_document.grafana_cloudwatch_readonly.json
}

output "grafana_cloudwatch_role_arn" {
  description = "ARN of the IAM role Grafana Cloud assumes to read CloudWatch data"
  value       = aws_iam_role.grafana_cloudwatch_datasource.arn
}