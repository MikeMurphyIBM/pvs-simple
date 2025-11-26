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

# PowerVS workspace
data "ibm_resource_instance" "pvs_workspace" {
  name = "murphy"
}

# AIX Image Lookup (old naming required by Schematics)
data "ibm_pi_image" "os_image" {
  pi_cloud_instance_id = data.ibm_resource_instance.pvs_workspace.id
  pi_image_name        = "AIX 7200-05-10"
}

# Network lookup (old naming)
data "ibm_pi_network" "pvs_network" {
  pi_cloud_instance_id = data.ibm_resource_instance.pvs_workspace.id
  pi_network_name      = "murphy-subnet"
}

# VM creation (old block naming)
resource "ibm_pi_instance" "my_power_vm" {
  pi_cloud_instance_id = data.ibm_resource_instance.pvs_workspace.id

  pi_instance_name = "clone-test"
  pi_image_id      = data.ibm_pi_image.os_image.image_id

  # CPU/memory
  memory     = 2
  processors = 0.25
  proc_type  = "shared"

  # system type
  sys_type     = "s922"
  storage_type = "tier3"

  # SSH Key
  key_pair_name = "murphy-clone-key"

  # Network block
  pi_network {
    network_id = data.ibm_pi_network.pvs_network.network_id
  }
}
