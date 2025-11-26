provider "ibm" {
  region = "us-south"          # <-- CHANGE IF YOUR WORKSPACE IS NOT IN US-SOUTH
}

# REQUIRED: Your PowerVS workspace name
data "ibm_resource_instance" "pvs_workspace" {
  name = "murphy"
}

# Image (AIX 7200-05-10)
data "ibm_pi_image" "os_image" {
  pi_cloud_instance_id = data.ibm_resource_instance.pvs_workspace.id
  name                 = "7200-05-10"
}

# REQUIRED: Your subnet name exactly as it appears in PowerVS
data "ibm_pi_subnet" "pvs_network" {
  pi_cloud_instance_id = data.ibm_resource_instance.pvs_workspace.id
  name                 = "murphy-subnet"
}

resource "ibm_pi_instance" "my_power_vm" {
  pi_cloud_instance_id = data.ibm_resource_instance.pvs_workspace.id

  # VM settings
  name        = "clone-test"
  image_id    = data.ibm_pi_image.os_image.image_id
  memory      = 2
  processors  = 0.25
  proc_type   = "shared"

  # Network
  networks = [
    {
      network_id = data.ibm_pi_subnet.pvs_network.id
    }
  ]

  # Additional required fields
  key_pair_name = "clone"      # <-- Your SSH key name in PowerVS
  sys_type      = "s922"
  storage_type  = "tier3"
}
