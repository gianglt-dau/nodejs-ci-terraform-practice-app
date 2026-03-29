# Node.js Practice App

App Node.js đơn giản để thực hành:

- Git / GitHub
- CI với GitHub Actions
- Docker
- Terraform + Docker provider

## Chạy local

```bash
npm install
npm start
```

Mở trình duyệt tại:

```bash
http://localhost:3000
```

## Chạy test

```bash
npm test
```

## Docker

```bash
docker build -t myapp:latest .
docker run -p 3000:3000 myapp:latest
```

## API

- `GET /` -> trả về chuỗi chào mừng
- `GET /health` -> trả về JSON trạng thái

## Gợi ý cho CI

Ví dụ workflow tối thiểu:

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 18
      - run: npm install
      - run: npm test
```
