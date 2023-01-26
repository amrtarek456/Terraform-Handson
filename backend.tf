terraform {
  backend "s3" {
    bucket         = "mys3bucketterraformamr" # should already exist on AWS S3
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "s3-state-lock-amr" # should already exist on AWS
  }
}