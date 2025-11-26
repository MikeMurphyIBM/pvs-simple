provider "ibm" {
  region = "us-south"
  zone   = "dal10"
}


terraform {
  required_providers {
    ibm = {
      source  = "ibm-cloud/ibm"
      version = ">= 1.85.0"
    }
  }
}


