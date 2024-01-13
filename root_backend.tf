terraform {
  backend "s3" {
    bucket = "piano-lessons-infrastructure-state"
    key    = "terraform.state"
    region = "eu-west-2"
  }
}
