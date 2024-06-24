terraform {
  backend "s3" {
    bucket = "piano-lessons24-infrastructure-state"
    key    = "terraform.state"
    region = "eu-west-2"
  }
}
