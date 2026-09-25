# ANTIGRAVITY AGENT WORKFLOW: SETUP GITHUB RUNNER & CI/CD PIPELINE

Tài liệu này đóng vai trò là chỉ dẫn tác vụ (Task Instructions) dành cho Antigravity IDE Agent để tự động kiểm tra, khởi tạo file và thiết lập môi trường CI/CD Self-hosted Runner trên hệ điều hành Windows.

---

## 1. THÔNG SỐ CẤU HÌNH DỰ ÁN (PROJECT SPECIFICATIONS)
* **GitHub Repository:** `https://github.com/td130999-cell/GroupADemoCICD`
* **GHCR Package Name:** `ghcr.io/td130999-cell/groupademocicd:latest` *(Bắt buộc viết thường hoàn toàn)*
* **Runner Target Directory:** `D:\actions-runner`
* **Runner Version:** `2.337.0`
* **Runner Label:** `demo-node`
* **App Port:** `8080:80`
* **Container Name:** `my-demo-app`

---

## 2. QUY TRÌNH THỰC THI TỰ ĐỘNG CỦA AGENT

### Bước 1: Chuẩn hóa file Workflow GitHub Actions
Agent kiểm tra và ghi đè nội dung file `.github/workflows/docker-ci.yml` bằng cấu hình chuẩn sau:

```yaml
name: CI/CD Build and Sync to All Members

on:
  push:
    branches:
      - main

permissions:
  contents: read
  packages: write

jobs:
  build-and-push:
    name: Build & Push Docker Image
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Log in to GitHub Container Registry
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ghcr.io/${{ github.repository_owner }}/groupademocicd
          tags: |
            type=raw,value=latest

      - name: Build and push Docker image
        uses: docker/build-push-action@v6
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}

  deploy-to-local:
    name: Auto Deploy on My PC
    needs: build-and-push
    runs-on: [self-hosted, demo-node]

    steps:
      - name: Pull and run latest Docker container
        shell: powershell
        run: |
          Write-Host "===================================================="
          Write-Host "=> [1/4] Phat hien code moi! Dang tai Docker image ve may..."
          docker pull ghcr.io/${{ github.repository_owner }}/groupademocicd:latest

          Write-Host "=> [2/4] Don dep container cu neu ton tai..."
          try { docker rm -f my-demo-app } catch {}

          Write-Host "=> [3/4] Khoi dong container my-demo-app moi..."
          docker run -d --name my-demo-app -p 8080:80 --restart always ghcr.io/${{ github.repository_owner }}/groupademocicd:latest

          Write-Host "=> [4/4] HOAN TAT! Ung dung da cap nhat tai http://localhost:8080"
          Write-Host "===================================================="