provider "aws" {
  region = "us-east-1"
}


module "vpc" {
  source = "github.com/terraform-community-modules/tf_aws_vpc"

  name = "demo"

  cidr = "10.10.0.0/16"
  private_subnets = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
  public_subnets  = ["10.10.101.0/24", "10.10.102.0/24", "10.10.103.0/24"]

  azs      = ["us-east-1a", "us-east-1b", "us-east-1c"]

  tags {
    "Environment" = "demo"
  }
}