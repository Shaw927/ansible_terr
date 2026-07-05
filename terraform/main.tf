locals {
  hosts = {
    clickhouse = { cores = 2, memory = 4 }
    vector     = { cores = 2, memory = 2 }
    lighthouse = { cores = 2, memory = 2 }
  }
}

resource "yandex_vpc_network" "net" {
  name = "ansible-hw-net"
}

resource "yandex_vpc_subnet" "subnet" {
  name           = "ansible-hw-subnet"
  zone           = var.yc_zone
  network_id     = yandex_vpc_network.net.id
  v4_cidr_blocks = ["10.10.0.0/24"]
}

resource "yandex_compute_instance" "vm" {
  for_each    = local.hosts
  name        = each.key
  hostname    = each.key
  platform_id = "standard-v3"

  resources {
    cores  = each.value.cores
    memory = each.value.memory
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
      size     = 20
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.ssh_public_key_path)}"
  }
}

resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/templates/inventory.tftpl", {
    instances = { for k, v in yandex_compute_instance.vm : k => v.network_interface.0.nat_ip_address }
  })
  filename = "${path.module}/../ansible/prod.yml"
}
