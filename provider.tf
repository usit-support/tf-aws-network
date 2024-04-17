variable "aws_access_key" {}
variable "aws_secret_key" {}

provider "aws" {
  alias      = "network"
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key

  default_tags {
    tags = {
      Environment = "network"
      Project_id  = "111"
    }
  }
}