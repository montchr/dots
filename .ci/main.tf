terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
      version = "1.18.0"
    }
  }
}

provider "linode" {
  token = var.api_token
}

resource "linode_instance" "ubuntu-20-04" {
  image  = "linode/ubuntu20.04"
  label  = "ci-dotfield-${var.branch}-ubuntu20-04"
  group  = "Dotfield CI"
  region = var.region
  type   = "g6-nanode-1"
}

# TODO: enable CI for debian
# resource "linode_instance" "debian10" {
#   image           = "linode/debian10"
#   label           = "ci-dotfield-${var.branch}-debian10"
#   group           = "Dotfield CI"
#   region          = var.region
#   type            = "g6-nanode-1"
# }
