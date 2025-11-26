terraform {
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">= 1.85.0"
    }
  }
}

provider "ibm" {
  region = "dal10"      # <-- MUST MATCH YOUR WORKSPACE REGION
}

# PowerVS workspace (classic PI)
data "ibm_resource_instance" "pvs_workspace" {
  name = "murphy"
}

# Image lookup
data "ibm_pi_image" "os_image" {
  pi_cloud_instance_id = data.ibm_resource_instance.pvs_workspace.guid
  pi_image_name        = "7200-05-10"
}

# PowerVS instance
resource "ibm_pi_instance" "my_power_vm" {
  pi_cloud_instance_id = data.ibm_resource_instance.pvs_workspace.guid

  # Instance identity
  pi_instance_name = "clone-test"
  pi_image_id      = data.ibm_pi_image.os_image.id

  # Compute (correct attributes for PI)
  memory            = 2        # in GB
  processors        = 0.25
  proc_type         = "shared"

  # Network (using known ID)
  pi_network {
    network_id = "eb8a0e15-04f5-45e2-81e4-1bffe6131bf8"
  }

  # System & storage
  key_pair_name = "clone"
  sys_type      = "s922"
  storage_type  = "tier3"
}
