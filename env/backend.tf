terraform {
  backend "s3" {
    bucket  = "aws-terraform-statefiles-bucket"   # Your S3 bucket name
    key     = "terraform/state/terraform.tfstate" # Path to the state file
    region  = "us-east-2"                         # Change to your AWS region
    encrypt = true                                # Enable encryption for security
    #dynamodb_table = "terraform-state-lock"      # DynamoDB table for state locking
  }
}


