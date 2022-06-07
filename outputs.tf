output "account_id" {
  value = "${data.yandex_client_config.client.cloud_id}"
  description = "YC cloud ID."
}

output "region" {
  value = "${data.yandex_client_config.client.zone}"
  description = "YC zone."
}

output "internal_ip_address_vm-workspace" {
  value = yandex_compute_instance.vm-workspace[*].network_interface.0.ip_address
}

output "external_ip_address_vm-workspace" {
  value = yandex_compute_instance.vm-workspace[*].network_interface.0.nat_ip_address
}

output "subnet_id" {
  value = yandex_vpc_subnet.netology-subnet.network_id
  description = "Subnet ID."
}