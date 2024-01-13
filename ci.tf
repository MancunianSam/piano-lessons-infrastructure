resource "aws_iam_role" "github_deploy_role" {
  assume_role_policy = templatefile("${path.module}/templates/github_assume_role.json.tpl", {})
  name               = "GithubDeployPianoLessonsToECR"
}

resource "aws_iam_policy" "github_deploy_policy" {
  policy = templatefile("${path.module}/templates/push_to_ecr_policy.json.tpl", {})
  name   = "GithubDeployPianoLessonsPolicy"
}

resource "aws_iam_role_policy_attachment" "github_policy_attach" {
  policy_arn = aws_iam_policy.github_deploy_policy.arn
  role       = aws_iam_role.github_deploy_role.name
}
