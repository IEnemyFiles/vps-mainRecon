// Terraform plugin for creating random ids
resource "random_id" "instance_id" {
  count       = var.vps_number
  byte_length = 8
}

resource "digitalocean_droplet" "vm_instance" {
  count       = var.vps_number
  image       = "ubuntu-18-04-x64"
  name        = "mainRecon-vps-${random_id.instance_id[count.index].hex}"
  region      = var.region 
  size        = "s-1vcpu-1gb"
  vpc_uuid    = digitalocean_vpc.vpc_network.id
  ssh_keys    = [digitalocean_ssh_key.ssh_public_key.fingerprint]
  user_data   = data.template_file.cloud_init_yaml.rendered
}

resource "digitalocean_ssh_key" "ssh_public_key" {
  name       = "ssh_public_key"
  public_key = file(var.ssh_public_key)
}

data "template_file" "cloud_init_yaml" {
  template = file("cloud-init.yaml")
  vars = {
    ssh_public_key = file(var.ssh_public_key)
    username = var.username
  }
}