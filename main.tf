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

# ----------------------------------------------------
# 1. GET THE POWERVS WORKSPACE INSTANCE
# ----------------------------------------------------
data "ibm_resource_instance" "pvs_workspace" {
  name = "murphy"
}

# ----------------------------------------------------
# 2. GET THE AIX IMAGE
# Use the EXACT image name as shown in PowerVS UI
# (example: "7200-05-10")
# ----------------------------------------------------
data "ibm_pi_image" "os_image" {
  cloud_instance_id = data.ibm_resource_instance.pvs_workspace.guid
  name              = "AIX 7200-05-10"
}

# ----------------------------------------------------
# 3. GET THE SUBNET
# PowerVS calls networks “pi_network”
# ----------------------------------------------------
data "ibm_pi_network" "pvs_network" {
  cloud_instance_id = data.ibm_resource_instance.pvs_workspace.guid
  pi_network_name   = "murphy-subnet"
}

# ----------------------------------------------------
# 4. CREATE THE VM INSTANCE
# ----------------------------------------------------
resource "ibm_pi_instance" "my_power_vm" {
  cloud_instance_id = data.ibm_resource_instance.pvs_workspace.guid

  instance_name = "clone-test"
  pi_image_id   = data.ibm_pi_image.os_image.id

  # Compute configuration
  pi_memory     = 2            # GB
  pi_processors = 0.25         # processor units
  pi_proc_type  = "shared"     # shared | dedicated

  # System type and storage
  pi_sys_type   = "s922"       # your hardware type
  storage_type  = "tier3"      # tier1 | tier3

  # SSH Key
  pi_key_pair_name = "murphy-clone-key"

  # Network
  network {
    network_id = data.ibm_pi_network.pvs_network.network_id
  }
}
