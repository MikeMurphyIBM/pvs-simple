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

# 1. PowerVS Workspace Lookup (Finds the CRN of the service instance)
data "ibm_resource_instance" "pvs_workspace" {
  name = "murphy"
}

# 2. Network lookup
data "ibm_pi_network" "pvs_network" {
  # The CRN is required to associate the resource request with the workspace
  pi_cloud_instance_id = data.ibm_resource_instance.pvs_workspace.id
  
  # Using pi_network_id avoids the deprecation warning previously encountered
  pi_network_id        = "396e9198-d7e2-4860-97c4-9a44c146ec19"
  
  # CRITICAL FIX: Replaced unsupported 'pi_data_center' with the generic 'zone' 
  # attribute and set the value to a specific PVS datacenter name.
  zone                 = "dal10" # <-- REPLACE with your specific PVS Datacenter ID/Zone!
}

# 3. VM CREATE — PVS Instance Resource
resource "ibm_pi_instance" "my_power_vm" {
  # Link to the workspace ID (Cloud Resource Name)
  pi_cloud_instance_id = data.ibm_resource_instance.pvs_workspace.id

  # Mandatory Instance Information
  pi_instance_name = "clone-test"
  pi_image_id      = "52f2891b-6e4b-4765-bc0e-43cdc036305a"

  # Compute/Sizing Attributes 
  pi_memory       = 2
  pi_processors   = 0.25
  pi_proc_type    = "shared"

  # System/Storage Attributes
  pi_sys_type     = "s922"
  pi_storage_type = "tier3"

  pi_key_pair_name = "murphy-clone-key"

  # Network Attachment
  pi_network {
    network_id = data.ibm_pi_network.pvs_network.id
  }
}
