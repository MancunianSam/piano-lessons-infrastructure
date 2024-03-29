provider "aws" {
  region = "eu-west-2"

  assume_role {
    role_arn     = local.assume_role
    session_name = "terraform"
  }
}

provider "aws" {
  region = "us-east-1"
  alias  = "virginia"
  assume_role {
    role_arn     = local.assume_role
    session_name = "terraform"
  }
}
