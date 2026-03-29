variable "image_name" {
  default = "nodejs-ci-terraform-practice-app:latest"
}

variable "container_name" {
  default = "nodejs-ci-terraform-practice-app"
}

variable "internal_port" {
  default = 3000
}

variable "external_port" {
  default = 3000
}