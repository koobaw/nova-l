output "ip" {
    description = "IP address of the instance"
    value = google_compute_instance.instance.network_interface.0.network_ip
}
