resource "aws_sns_topic" "billing_topic" {
  name     = "billing-alert-topic"
  provider = aws.virginia
}

data "aws_ssm_parameter" "billing_email" {
  name = "/mgmt/billing/email"
}

resource "aws_sns_topic_subscription" "billing_email_subscription" {
  endpoint  = data.aws_ssm_parameter.billing_email.value
  protocol  = "email"
  topic_arn = aws_sns_topic.billing_topic.arn
  provider  = aws.virginia
}

resource "aws_cloudwatch_metric_alarm" "billing_alarm" {
  provider            = aws.virginia
  alarm_name          = "billing-alert"
  comparison_operator = "GreaterThanThreshold"
  datapoints_to_alarm = 1
  evaluation_periods  = 1
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  period              = 21600
  statistic           = "Maximum"
  threshold           = 20
  alarm_actions       = [aws_sns_topic.billing_topic.arn]
  dimensions = {
    Currency : "USD"
  }
}


