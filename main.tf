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

# PowerVS Workspace
data "ibm_resource_instance" "pvs_workspace" {
  name = "murphy"
}

# PowerVS Image (correct arguments for v1.85)
data "ibm_pi_image" "os_image" {
  pi_cloud_instance_id = data.ibm_resource_instance.pvs_workspace.guid
  pi_image_name        = "7200-05-10"
}

# PowerVS Network (correct arguments for v1.85)
data "ibm_pi_network" "pvs_network" {
  pi_cloud_instance_id = data.ibm_resource_instance.pvs_workspace.guid
  pi_network_name      = "murphy-subnet"
}

# PowerVS Instance (correct arguments for v1.85)
resource "ibm_pi_instance" "my_power_vm" {
  pi_cloud_instance_id = data.ibm_resource_instance.pvs_workspace.guid

  pi_instance_name = "clone-test"
  pi_image_id      = data.ibm_pi_image.os_image.pi_image_id

  memory      = 2
  processors  = 0.25
  proc_type   = "shared"

  pi_network {
    network_id = data.ibm_pi_network.pvs_network.network_id
  }

  key_pair_name = "clone"
  sys_type      = "s922"
  storage_type  = "tier3"
}
