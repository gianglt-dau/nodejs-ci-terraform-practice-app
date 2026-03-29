# Hướng dẫn triển khai Node.js app với Docker & Terraform

## Yêu cầu
- Đã cài đặt Docker Desktop (và Docker đang chạy)
- Đã cài đặt Terraform >= 1.0.0

## Các bước thực hiện

### 1. Mở terminal và chuyển vào thư mục terraform

```
cd terraform
```

### 2. Khởi tạo Terraform

```
terraform init
```

### 3. Kiểm tra cấu hình (tùy chọn)

```
terraform plan
```

### 4. Triển khai Docker container

```
terraform apply
```
- Nhập `yes` khi được hỏi xác nhận.

### 5. Kiểm tra ứng dụng
- Mở trình duyệt và truy cập: [http://localhost:3000](http://localhost:3000)
- Nếu muốn đổi cổng, sửa biến `external_port` trong `variables.tf` hoặc truyền qua dòng lệnh:
  ```
  terraform apply -var="external_port=8080"
  ```

### 6. Xóa container và image khi không dùng nữa

```
terraform destroy
```
- Nhập `yes` để xác nhận xóa toàn bộ resource Docker đã tạo.

---

## Lưu ý
- Có thể chỉnh sửa các biến trong `variables.tf` để thay đổi tên image, container, cổng...
- Nếu thay đổi code Node.js, cần chạy lại `terraform apply` để build lại image và cập nhật container.
