# Hướng Dẫn Triển Khai Web Miễn Phí (Deploy Free Web) — LyHENG VND-USD

Ứng dụng **LyHENG VND-USD** đã được tích hợp đầy đủ mã nguồn cho Web và có sẵn script tự động build trên **Render.com**. Bạn có thể đưa ứng dụng lên mạng hoàn toàn **MIỄN PHÍ 100%** với tên miền dạng `https://lyheng-vnd-usd.onrender.com` (hoặc tên miền riêng) giống hệt trang mẫu `https://pos-drinking.onrender.com`.

---

## 🚀 Cách 1: Triển khai tự động lên Render.com (Tên miền `*.onrender.com` - Miễn phí)

Dự án đã được tạo sẵn file cấu hình `render.yaml` và script `scripts/render-build.sh`.

### Các bước thực hiện:
1. **Đưa mã nguồn lên GitHub**:
   Mở terminal tại thư mục dự án và chạy:
   ```bash
   git add .
   git commit -m "feat: setup flutter web and render deploy config"
   git branch -M main
   # Thay đường dẫn bên dưới bằng URL repository GitHub của bạn:
   git remote add origin https://github.com/TÊN_GITHUB_CỦA_BẠN/lyheng-vnd-usd.git
   git push -u origin main
   ```

2. **Đăng nhập vào Render.com**:
   - Truy cập: [https://render.com](https://render.com)
   - Chọn **Sign In** (Đăng nhập bằng tài khoản GitHub miễn phí).

3. **Tạo Static Site**:
   - Tại Dashboard của Render, bấm nút **New +** ở góc trên bên phải -> Chọn **Static Site**.
   - Chọn kho GitHub `lyheng-vnd-usd` của bạn.
   - Điền thông tin:
     - **Name**: `lyheng-vnd-usd` (Đường link sẽ là `https://lyheng-vnd-usd.onrender.com`).
     - **Branch**: `main`
     - **Build Command**: `chmod +x ./scripts/render-build.sh && ./scripts/render-build.sh`
     - **Publish Directory**: `build/web`
   - Bấm **Create Static Site**.

Render sẽ tự động chạy script tải Flutter, build bản web và tạo đường link web trực tuyến có HTTPS miễn phí vĩnh viễn!

---

## ⚡ Cách 2: Triển khai lên Vercel (Khuyên dùng nếu muốn tốc độ siêu nhanh)

Vercel là nền tảng CDN toàn cầu cực nhanh, không bao giờ bị sleep/chậm:
1. Bạn đã có sẵn thư mục `build/web` đã được build sẵn trong dự án.
2. Cài Vercel CLI hoặc kéo thả thư mục `build/web` lên [https://vercel.com](https://vercel.com):
   ```bash
   npx vercel deploy build/web --prod
   ```
3. Bạn sẽ nhận ngay đường link dạng: `https://lyheng-vnd-usd.vercel.app`.

---

## 🌐 Cách 3: Triển khai lên GitHub Pages (Miễn phí vĩnh viễn)

1. Build phiên bản web với base-href:
   ```bash
   flutter build web --release --base-href "/lyheng-vnd-usd/"
   ```
2. Đẩy thư mục `build/web` lên branch `gh-pages` của GitHub repository.
3. Kích hoạt trong **Settings** -> **Pages** trên GitHub.

---

## 💻 Cách 4: Chạy thử nghiệm ngay trên máy tính của bạn

Nếu bạn muốn mở giao diện web lên xem ngay lập tức trên máy tính:
```bash
flutter run -d chrome
```
Hoặc dùng máy chủ web nhẹ cục bộ để mở thư mục `build/web`:
```bash
npx serve build/web
```
