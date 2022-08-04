variable "namespace" {
  description = " This project namespace to use for unique resource naming"
  default = "s3backend"
  type = "string"
}

variable "principal_arns" {
  description = "A list of principal arns allowed to assume the IAM role"
  default = null
  type = list(string)
}

variable "force_destroy_state" {
  description = "Force destroy the s3 bucket containing state files"
  default = true
  type = bool
}


# parts required to deploy an s3 buket

# Dynamo db table for state locking 
# s3 bucket and kms (Key management service) for state storage and encryption at rest.
# identity and access management iam least privilegde role, as other aws accounts are going to assume a role to this account and deploy to it
