data "ibm_resource_group" "group" {
  name = "Default"
}

resource "ibm_resource_instance" "pvs_workspace" {
  name              = var.pvs_workspace_name
  service           = "power-iaas"
  location          = var.dr_pvs_region
  plan              = "power-virtual-server-group"
  resource_group_id = data.ibm_resource_group.group.id
}

resource "ibm_pi_key" "key" {
  pi_cloud_instance_id = ibm_resource_instance.pvs_workspace.guid
  pi_key_name          = var.ssh_key_name
  pi_ssh_key           = var.ssh_key_rsa
}



resource "ibm_pi_image" "aix_image" {
  pi_cloud_instance_id = ibm_resource_instance.pvs_workspace.guid
  pi_image_id          = var.pvs_aix_image_id
  pi_image_name        = var.pvs_aix_image_name
  timeouts {
    create = "9m"
  }
}

resource "ibm_pi_instance" "clone" {
    pi_memory             = var.pvs_dr_instance_memory
    pi_processors         = var.pvs_dr_instance_cores
    pi_instance_name      = var.pvs_dr_instance_name
    pi_proc_type          = "shared"
    pi_image_id           = ibm_pi_image.aix_image.image_id
    pi_key_pair_name      = ibm_pi_key.key.pi_key_name
    pi_sys_type           = "s922"
    pi_cloud_instance_id  = ibm_resource_instance.pvs_workspace.guid
    pi_pin_policy         = "none"
    pi_health_status      = "WARNING"
    pi_storage_type = "tier3"
}
