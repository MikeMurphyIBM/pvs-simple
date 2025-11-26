terraform {
  required_providers {
    ibm = {
      source  = "ibm-cloud/ibm"
      version = ">= 1.85.0"
    }
  }
}

provider "ibm" {
  region = "us-south"
}

# PowerVS Workspace
data "ibm_resource_instance" "pvs_workspace" {
  name = "murphy"
}

# Get ALL images in the workspace
data "ibm_pi_images" "all_images" {
  cloud_instance_id = data.ibm_resource_instance.pvs_workspace.guid
}

# Select the AIX image by name
locals {
  aix_image = [
    for img in data.ibm_pi_images.all_images.images :
    img if img.name == "AIX 7200-05-10"
  ][0]
}

# Network lookup
data "ibm_pi_network" "pvs_network" {
  cloud_instance_id = data.ibm_resource_instance.pvs_workspace.guid
  pi_network_name   = "murphy-subnet"
}

# Create VM
resource "ibm_pi_instance" "my_power_vm" {
  cloud_instance_id = data.ibm_resource_instance.pvs_workspace.guid

  pi_instance_name = "clone-test"
  pi_image_id      = local.aix_image.id

  memory       = 2
  processors   = 0.25
  proc_type    = "shared"

  sys_type     = "s922"
  storage_type = "tier3"

  key_pair_name = "murphy-clone-key"

  pi_network {
    network_id = data.ibm_pi_network.pvs_network.network_id
  }
}
