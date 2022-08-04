provider "aws" {
  region = "us-west-2"
}

module "s3backend" {
  source = "terraform-in-action/s3backend/aws"
  namespace = "team-rocket"
}

output "s3backend_config" {
  value = "module.s3backend.config"
}

#1 You can either update the source to the point to your module in the registry
#2 Config required to connect to the backend

#this should be a different terraform project