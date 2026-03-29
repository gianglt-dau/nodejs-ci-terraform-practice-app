# REPORT: Các vấn đề Terraform + Docker trên Windows và cách giải quyết

**Ngày:** 29/03/2026  
**Dự án:** nodejs-ci-terraform-practice-app  
**Môi trường:** Windows + Docker Desktop (WSL2 backend) + Terraform >= 1.0.0

---

## Vấn đề 1: Dockerfile sai kiến trúc (React/nginx thay vì Node.js backend)

### Triệu chứng
Build thất bại hoặc container chạy nginx thay vì ứng dụng Node.js.

### Nguyên nhân
Dockerfile ban đầu dùng multi-stage build cho ứng dụng React (npm run build + nginx), không phù hợp với backend Express API.

### Giải pháp
Viết lại Dockerfile chuẩn cho Node.js backend:

```dockerfile
FROM node:18

WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .

EXPOSE 3000

CMD ["node", "src/index.js"]
```

---

## Vấn đề 2: Terraform provider `kreuzwerker/docker` v3.x lỗi EOF khi build image trên Windows

### Triệu chứng
```
Error: Error running legacy build: failed to read dockerfile: unexpected EOF

  with docker_image.node_app,
  on main.tf line 13, in resource "docker_image" "node_app":
  13: resource "docker_image" "node_app" {
```

### Nguyên nhân
Provider `kreuzwerker/docker` v3.x có bug khi sử dụng `build {}` block để build Docker image trực tiếp từ Terraform trên Windows — provider gọi Docker API theo cách "legacy build" và bị lỗi đọc Dockerfile qua WSL2 bridge.

Các cách thử không giải quyết được:
- Thêm dòng trống cuối file Dockerfile.
- Dùng đường dẫn tuyệt đối `abspath()` cho context/dockerfile.
- Dùng đường dẫn tương đối cho dockerfile.

### Giải pháp
Thay `docker_image` resource + `build {}` bằng `null_resource` + `local-exec` gọi Docker CLI trực tiếp:

```hcl
# Thêm provider null
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
}

# Build image bằng Docker CLI
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

# Tạo container, depends_on build_image
resource "docker_container" "node_app" {
  depends_on = [null_resource.build_image]
  name  = var.container_name
  image = var.image_name
  ports {
    internal = var.internal_port
    external = var.external_port
  }
}
```

Sau đó chạy `terraform init -upgrade` để tải provider `null`.

**Ưu điểm của giải pháp này:**
- Tránh hoàn toàn bug của provider trên Windows.
- `triggers` dựa trên MD5 của Dockerfile và package.json, tự động rebuild khi có thay đổi.
- Docker CLI chạy trực tiếp trên host, không qua API bridge.

---

## Vấn đề 3: Build context quá lớn — bước `load build context` chậm hàng phút

### Triệu chứng
Bước `#6 [internal] load build context` bị treo hàng phút do Docker client phải scan toàn bộ `node_modules` (~200MB+) và thư mục `terraform/` (chứa provider binaries).

### Nguyên nhân
Không có file `.dockerignore`, Docker client đọc và gửi toàn bộ thư mục dự án (kể cả node_modules, .terraform, .git) vào build daemon qua WSL2 bridge — đặc biệt chậm trên Windows.

### Giải pháp
Tạo file `.dockerignore` ở thư mục gốc:

```
node_modules
terraform/
.terraform
**/.terraform.lock.hcl
*.log
.git
docs
__tests__
coverage
```

**Kết quả:** Build context giảm từ hàng trăm MB xuống còn vài KB (`transferring context: 152B`).

---

## Tóm tắt các file đã thay đổi

| File | Thay đổi |
|------|----------|
| `Dockerfile` | Viết lại cho Node.js backend (bỏ nginx/React) |
| `terraform/main.tf` | Thay `docker_image + build{}` bằng `null_resource + local-exec` |
| `terraform/outputs.tf` | Bỏ tham chiếu đến `docker_image.node_app` không còn tồn tại |
| `.dockerignore` | Tạo mới để loại trừ node_modules, terraform/, .git, etc. |

---

## Lưu ý cho lần sau

1. Trên Windows, **không dùng `build {}` block** trong provider `kreuzwerker/docker` — dùng `null_resource + local-exec` thay thế.
2. Luôn tạo `.dockerignore` trước khi build để tránh context lớn.
3. Sau khi thay đổi `main.tf` (thêm provider mới), phải chạy `terraform init -upgrade` trước `terraform apply`.
4. Provider `kreuzwerker/docker` v3.x đổi `docker_image.xxx.latest` thành `docker_image.xxx.image_id`.
