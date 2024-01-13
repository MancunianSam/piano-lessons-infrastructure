{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "ecr:BatchCheckLayerAvailability",
        "ecr:BatchGetImage",
        "ecr:GetDownloadUrlForLayer",
        "ssm:GetParameter",
        "ssm:GetParameters"
      ],
      "Resource": [
        "${log_group_arn}",
        "${log_group_arn}:log-stream:*",
        "${repository_arn}",
        "arn:aws:ssm:eu-west-2:${account_number}:parameter/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ssm:DescribeParameters"
      ],
      "Resource" : "*"
    }
  ]
}

