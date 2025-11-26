terraform {
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
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

# PowerVS image lookup
# (Note: provider v1.85 expects pi_cloud_instance_id + pi_image_name)
data "ibm_pi_image" "os_image" {
  pi_cloud_instance_id = data.ibm_resource_instance.pvs_workspace.guid
  pi_image_name        = "7200-05-10"
}

# PowerVS instance
resource "ibm_pi_instance" "my_power_vm" {
  pi_cloud_instance_id = data.ibm_resource_instance.pvs_workspace.guid

  # Required instance fields (v1.85 uses pi_instance_name + pi_image_id)
  pi_instance_name = "clone-test"
  pi_image_id      = data.ibm_pi_image.os_image.image_id

  memory      = 2
  processors  = 0.25
  proc_type   = "shared"

  # Network: use your known network ID directly
  pi_network {
    network_id = "eb8a0e15-04f5-45e2-81e4-1bffe6131bf8"
  }

  # SSH key & system details
  key_pair_name = "clone"   # must match your SSH key name in the PVS workspace
  sys_type      = "s922"
  storage_type  = "tier3"
}
