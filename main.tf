data "aws_region" "current" {}

resource "random_string" "rand" {
    length = 24
    special = false
    upper = false
}

locals {
  namespace = substr(join("-", [var.namespace, random_string.rand.result]),0, 24)
}

# this is responsible for resource grouping
resource "aws_resourcegroups_group" "aws_resourcegroups_group" {
  name = "${local.namespace}-group"

  resource_query {
    query = <<-JSON
    {
        "ResourceTypeFilters": [
            "AWS::AllSupported"
        ],
        "TagFilters": [
            {
                "Key": "ResourceGroup",
                "Values": ["${local.namespace}]
            }
        ]
    }
    JSON
  }
}
  
  resource "aws_kms_key" "kms_key" {
    tags = {
      "ResourceGroup" = "local.namespace"
    }
  }

  resource "aws_s3__bucket" "s3_buscket" {
    bucket = "${local.namespace}-state-busket"
    force_destroy_state = var.force_destroy_state

    versioning {
        enabled = true
    }
  }

  server_side_encription_configuration {
    rule {
        apply_server_side_encryption_by_default {
            sse_algirithm = "aws:kms"
            kms_master_key_id = aws_kms_key.kms_key.arn
        }
    }
  
  tags = {
    ResourceGroup = local.namespace
  }
  }

  resource "aws_s3_bucket_public_access_block" "s3_bucket" {
    bucket = aws_s3_bucket.s3_bucket.id

    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  }

  resource "aws_dynamodb_table" "dynamodb_table" {
    name = "${local.namespace}-state-lock"
    hash_key = "LockID"
    billing_mode = "PAY_PER_REQUEST"
    attribute {
      name = "LockID"
      type = "S"
    }
    tags = {
      ResourceGroup = local.namespace
    }
  }

  # Puts resources into a group based on a tag
  #2 Where the state is stored
  #3 Makes the database serverless instead of provisioned

  # Sample for sourcing a moduke from a git hub repo

  #code

  # module "s3backend" {
  #  source = "git hub url"
  #}

  #code end