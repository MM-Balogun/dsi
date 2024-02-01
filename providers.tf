provider "aws" {
  #   profile = "dsi_dev"
  region     = "us-east-1"
  access_key = "sdfghjkl"
  secret_key = "dfghjksdfghjedefdg/0z"
} 

terraform {
  cloud {
    organization = "DSI-Dev-test"

    workspaces {
      name = "DSI-DEV"
    }
  }
}
