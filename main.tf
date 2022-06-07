// Configure the Yandex.Cloud provider
provider "yandex" {
  cloud_id                 = "b1gs4sjqbi3m84ii35ou"
  folder_id                = "b1gu1oe1m0qlnkj61u6a"
  zone                     = "ru-central1-a"
}


locals {
  web_instance_resources_map = {
    stage = {
      cores  = 1
      memoty = 2
    }
    prod = {
      cores  = 2
      memory = 4
    }
  }
  web_instance_count_map = {
    stage = 1
    prod  = 2
  }
  instances = {
    "centos7"      = "fd80le4b8gt2u33lvubr"
    "ubuntu18-04"  = "fd83bj827tp2slnpp7f0"
  }
  vpc_subnet_map = {
    stage = ["192.168.118.0/16"]
    prod  = ["10.2.0.0/16"]
  }
}

resource "yandex_compute_instance" "vm-workspace" {
  name        = "vm-${terraform.workspace}-state-${count.index + 1}"
  platform_id = "standard-v2"
  
  resources {
    cores  = local.web_instance_resources_map[terraform.workspace].cores
    memory = local.web_instance_resources_map[terraform.workspace].memory
  } 

  count = local.web_instance_count_map[terraform.workspace]

  boot_disk {
    initialize_params {
      image_id = "fd81hgrcv6lsnkremf32"
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.netology-subnet.id}"
    nat = true
  }

  metadata = {
    foo      = "bar"
    ssh-keys = "ubuntu:${file("~/.ssh/for_netology_rsa")}"
  }
}

resource "yandex_vpc_network" "netology" {
  name = "netology-network"
}

resource "yandex_vpc_subnet" "netology-subnet" {
  name           = "netology-subnet"
  v4_cidr_blocks = local.vpc_subnet_map[terraform.workspace]
  network_id     = "${yandex_vpc_network.netology.id}"
}

resource "yandex_vpc_address" "ext_netology" {
  name = "ext_ip"

  external_ipv4_address {
    zone_id = "ru-central1-a"
  }
}

resource "yandex_compute_instance" "vm-other" {
  for_each = local.instances

  name = each.key
  platform_id = "standard-v1"
  
  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = each.value
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.netology-subnet.id}"
    nat = true
  }

  metadata = {
    foo      = "bar"
    ssh-keys = "ubuntu:${file("~/.ssh/for_netology_rsa")}"
  }

  lifecycle {
  create_before_destroy = true
  prevent_destroy = true
  }
}

data "yandex_client_config" "client" {}