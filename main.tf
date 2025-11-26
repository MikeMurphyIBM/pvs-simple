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

# Network lookup (legacy Schematics API)
data "ibm_pi_network" "pvs_network" {
  pi_cloud_instance_id = data.ibm_resource_instance.pvs_workspace.id
  pi_network_name      = "murphy-subnet"
}

# VM CREATE — Correct legacy field names
resource "ibm_pi_instance" "my_power_vm" {
  pi_cloud_instance_id = data.ibm_resource_instance.pvs_workspace.id

  pi_instance_name = "clone-test"

  # Your AIX image ID
  pi_image_id = "52f2891b-6e4b-4765-bc0e-43cdc036305a"

  # MUST use pi_ prefix
  pi_memory       = 2
  pi_processors   = 0.25
  pi_proc_type    = "shared"

  pi_sys_type     = "s922"
  pi_storage_type = "tier3"

  pi_key_pair_name = "murphy-clone-key"

  pi_network {
    network_id = data.ibm_pi_network.pvs_network.id
  }
}
