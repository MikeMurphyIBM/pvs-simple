# Resource Group
data "ibm_resource_group" "group" {
  name = "Default"
}

# Existing PowerVS workspace
data "ibm_resource_instance" "pvs_workspace" {
  name = var.pvs_workspace_name
}

# Add SSH Key to PowerVS
resource "ibm_pi_key" "key" {
  pi_cloud_instance_id = data.ibm_resource_instance.pvs_workspace.id
  pi_key_name          = var.ssh_key_name
  pi_ssh_key           = var.ssh_key_rsa
}

# Get existing subnet
data "ibm_pi_network" "pvs_network" {
  pi_cloud_instance_id = data.ibm_resource_instance.pvs_workspace.id
  pi_network_name      = "murphy-subnet"
}

# Create AIX LPAR
resource "ibm_pi_instance" "clone" {
  pi_cloud_instance_id = data.ibm_resource_instance.pvs_workspace.id

  pi_instance_name = var.pvs_dr_instance_name
  pi_image_id      = var.pvs_aix_image_id    # we use your existing image ID

  pi_memory     = var.pvs_dr_instance_memory
  pi_processors = var.pvs_dr_instance_cores
  pi_proc_type  = "shared"
  pi_sys_type   = "s922"
  pi_storage_type = "tier3"

  pi_key_pair_name = ibm_pi_key.key.pi_key_name

  pi_network {
    network_id = data.ibm_pi_network.pvs_network.network_id
  }

  pi_pin_policy = "none"
}
