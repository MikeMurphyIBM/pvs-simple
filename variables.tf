variable "dr_pvs_region" {
  description = "Where to deploy the DR environment"
  default = "us-south"
}

variable "ssh_key_name" {
  description = "Name of the ssh key to be used"
  type        = string
  default     = "murphy-clone-key"
}

variable "ssh_key_rsa" {
  description = "Public ssh key"
  type        = string
  default     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINruWyhVdZXl7IDRfji22iLwBFRYFCnQEdlfmHey0Jn6"
}

variable "pvs_workspace_name" {
  description = "Name of the PowerVS workspace"
  type = string
  default = "murphy"
}


variable "pvs_aix_image_id" {
  description = "The image ID for the AIX Image we want to deploy"
  type = string
  default = "52f2891b-6e4b-4765-bc0e-43cdc036305a"
}

variable "pvs_aix_image_name" {
  description = "The name of the image"
  type = string
  default = "7200-05-10"
}

variable "pvs_dr_instance_cores" {
  description = "The number of cores for the dr instance"
  type = string
  default = ".25"
}

variable "pvs_dr_instance_memory" {
  description = "The amount of memory (GB) for the dr instance"
  type = string
  default = "2"
}

variable "pvs_dr_instance_name" {
  description = "The name of the DR instance"
  type = string
  default = "clone"
}
