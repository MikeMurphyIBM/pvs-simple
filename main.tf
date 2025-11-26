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

# PowerVS workspace lookup
data "ibm_resource_instance" "pvs_workspace" {
  name = "murphy"
}

# Network lookup (Schematics legacy API)
data "ibm_pi_network" "pvs_network" {
  pi_cloud_instance_id = data.ibm_resource_instance.pvs_workspace.id
  pi_network_name      = "murphy-subnet"
}

# VM create (Schematics legacy API)
resource "ibm_pi_instance" "my_power_vm" {
  pi_cloud_instance_id = data.ibm_resource_instance.pvs_workspace.id

  pi_instance_name = "clone-test"

  # ✅ AIX image ID you provided
  pi_image_id = "52f2891b-6e4b-4765-bc0e-43cdc036305a"

  memory       = 2
  processors   = 0.25
  proc_type    = "shared"

  sys_type     = "s922"
  storage_type = "tier3"

  key_pair_name = "murphy-clone-key"

  pi_network {
    network_id = data.ibm_pi_network.pvs_network.id
  }
}
