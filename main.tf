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

# 1. PowerVS Workspace Lookup (Correct)
data "ibm_resource_instance" "pvs_workspace" {
  name = "murphy"
}

# 2. Network lookup (Warning: pi_network_name is deprecated)
# You should transition to looking up by ID if possible, but lookup by name is used here.
data "ibm_pi_network" "pvs_network" {
  pi_cloud_instance_id = data.ibm_resource_instance.pvs_workspace.id
  pi_network_name      = "murphy-subnet"
}

# 3. VM CREATE — Corrected PVS Instance Resource
resource "ibm_pi_instance" "my_power_vm" {
  # Link to the workspace ID (Cloud Resource Name)
  pi_cloud_instance_id = data.ibm_resource_instance.pvs_workspace.id

  # Mandatory Instance Information
  pi_instance_name = "clone-test"
  pi_image_id      = "52f2891b-6e4b-4765-bc0e-43cdc036305a" # Hardcoded Image ID provided by you

  # Compute/Sizing Attributes (Using pi_ prefix as seen in example resources [1])
  pi_memory       = 2       # [1]
  pi_processors   = 0.25    # [1]
  pi_proc_type    = "shared" # [1]

  # System/Storage Attributes (Using pi_ prefix as seen in example resources [1])
  pi_sys_type     = "s922" # [1]
  pi_storage_type = "tier3"

  # SSH Key
  pi_key_pair_name = "murphy-clone-key"

  # Network Attachment
  pi_network {
    # Reference the ID of the network fetched by the data source
    network_id = data.ibm_pi_network.pvs_network.id
  }
}
