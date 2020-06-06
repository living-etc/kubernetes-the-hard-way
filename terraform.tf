terraform {
  required_version = ">= 0.12.26"

  backend "s3" {
    bucket = "terraform-remote-state-o234hroquef"
    key    = "kubernetes-the-hard-way"
    region = "eu-west-1"
    acl    = "bucket-owner-full-control"
  }
}
