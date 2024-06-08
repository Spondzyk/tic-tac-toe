# outputs.tf

output "frontend_alb_hostname" {
  value = "${aws_alb.main.dns_name}:${var.container_port_frontend}"
}

output "backend_alb_hostname" {
  value = "${aws_alb.main.dns_name}:${var.container_port_backend}"
}
