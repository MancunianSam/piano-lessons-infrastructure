{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:SubmitAttachmentStateChanges",
        "ecs:SubmitTaskStateChange",
        "ecs:Poll",
        "ecs:StartTelemetrySession",
        "ecs:UpdateContainerInstancesState",
        "ecs:RegisterContainerInstance",
        "ecs:SubmitContainerStateChange",
        "ecs:DeregisterContainerInstance"
      ],
      "Resource": [
        "arn:aws:ecs:eu-west-2:${account_number}:cluster/piano-lessons",
        "arn:aws:ecs:eu-west-2:${account_number}:container-instance/piano-lessons/${instance_id}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecs:DiscoverPollEndpoint",
        "ecs:CreateCluster"
      ],
      "Resource": "*"
    }
  ]
}
