terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = ">= 3.0.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0.0"
    }
  }
  required_version = ">= 1.0.0"
}

provider "docker" {}

resource "null_resource" "build_image" {
  triggers = {
    dockerfile = filemd5("${path.module}/../Dockerfile")
    package    = filemd5("${path.module}/../package.json")
  }

  provisioner "local-exec" {
    command     = "docker build -t ${var.image_name} ."
    working_dir = abspath("${path.module}/..")
  }
}

resource "docker_container" "node_app" {
  depends_on = [null_resource.build_image]

  name  = var.container_name
  image = var.image_name

  ports {
    internal = var.internal_port
    external = var.external_port
  }
}
