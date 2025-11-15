
terraform {
  backend "s3" {
    bucket = "tf-state-294637015793"
    key    = "terraform/playground/tfstate"
    region = "us-east-1"
    use_lockfile = true
  }
}
