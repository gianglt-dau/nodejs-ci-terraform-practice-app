output "container_name" {
  value = docker_container.node_app.name
}

output "image_name" {
  value = var.image_name
}

output "app_url" {
  value = "http://localhost:${var.external_port}"
}