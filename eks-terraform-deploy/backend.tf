terraform {
  required_version = ">=0.12.0"
  backend "s3" {
    key            = "terraformstatefile"
    bucket         = "djtech-2a6e45ff25211320"
    region         = "eu-west-2"
    dynamodb_table = "terraform-state-locking"
  }
}
