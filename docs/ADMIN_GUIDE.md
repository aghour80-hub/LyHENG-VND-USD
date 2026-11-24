# Hướng Dẫn Quản Trị Viên (Administrator Guide) — LyHENG VND-USD

## 1. Thông Tin Tài Khoản Quản Trị Mặc Định

Hệ thống đã được thiết lập sẵn tài khoản quản trị theo yêu cầu:
* **Tên đăng nhập / Email:** `lyheng` (hoặc `lyheng@lyheng.com`)
* **Mật khẩu (Password):** `Lyheng168`

---

## 2. Cách Đăng Nhập Trên Ứng Dụng (Mobile & Web)

1. Mở ứng dụng **LyHENG VND-USD** (trên điện thoại hoặc trình duyệt web).
2. Nhấn vào biểu tượng **Cài đặt (Bánh răng)** ở góc trên bên phải.
3. Chọn mục **Đăng nhập Quản trị (Admin Login)**.
4. Nhập thông tin:
   - **Tên đăng nhập / Email:** `lyheng` (hoặc `lyheng@lyheng.com`)
   - **Mật khẩu:** `Lyheng168`
5. Bấm nút **Đăng nhập**. Hệ thống sẽ chuyển hướng bạn ngay vào **Bảng điều khiển Quản trị (Admin Dashboard)**.

> [!NOTE]
> Hệ thống hỗ trợ chế độ đăng nhập ngay cả khi chưa kết nối Supabase (chế độ demo/offline), giúp bạn có thể kiểm tra toàn bộ giao diện quản trị, chỉnh sửa tỷ giá và xem trước kết quả trực tiếp!

---

## 3. Kích Hoạt Tài Khoản Quản Trị Trên Supabase Thật

Khi bạn tạo cơ sở dữ liệu trên [Supabase.com](https://supabase.com), chỉ cần copy đoạn mã SQL sau và chạy trong mục **SQL Editor** trên Supabase:

```sql
-- Tạo tài khoản lyheng / Lyheng168 và cấp quyền Superadmin trong Supabase
DO $$
DECLARE
    v_admin_uuid UUID := 'a1b2c3d4-e5f6-7890-abcd-ef1234567890';
BEGIN
    IF NOT EXISTS (SELECT 1 FROM auth.users WHERE email = 'lyheng@lyheng.com') THEN
        INSERT INTO auth.users (
            id,
            instance_id,
            email,
            encrypted_password,
            email_confirmed_at,
            raw_app_meta_data,
            raw_user_meta_data,
            created_at,
            updated_at,
            role,
            aud
        ) VALUES (
            v_admin_uuid,
            '00000000-0000-0000-0000-000000000000',
            'lyheng@lyheng.com',
            crypt('Lyheng168', gen_salt('bf')),
            timezone('utc'::text, now()),
            '{"provider":"email","providers":["email"]}',
            '{"username":"lyheng"}',
            timezone('utc'::text, now()),
            timezone('utc'::text, now()),
            'authenticated',
            'authenticated'
        );

        INSERT INTO auth.identities (
            id,
            user_id,
            identity_data,
            provider,
            last_sign_in_at,
            created_at,
            updated_at
        ) VALUES (
            v_admin_uuid,
            v_admin_uuid,
            format('{"sub":"%s","email":"%s"}', v_admin_uuid::text, 'lyheng@lyheng.com')::jsonb,
            'email',
            timezone('utc'::text, now()),
            timezone('utc'::text, now()),
            timezone('utc'::text, now())
        );
    ELSE
        SELECT id INTO v_admin_uuid FROM auth.users WHERE email = 'lyheng@lyheng.com';
    END IF;

    -- Cấp quyền Admin trong bảng public.admin_users
    INSERT INTO public.admin_users (user_id, role)
    VALUES (v_admin_uuid, 'admin')
    ON CONFLICT (user_id) DO NOTHING;
END $$;
```

---

## 4. Các Chức Năng Của Quản Trị Viên

Trong **Admin Dashboard**:
* **Chỉnh sửa Giá Mua (BUY RATE)**: Thay đổi giá tiệm thu mua USD từ khách hàng (VND khách nhận được cho 1 USD).
* **Chỉnh sửa Giá Bán (SELL RATE)**: Thay đổi giá tiệm bán USD cho khách hàng (VND khách trả để mua 1 USD).
* **Xem trước (Preview)**: Kiểm tra công thức và số tiền mẫu trước khi phát hành.
* **Xuất bản (Publish)**: Đồng bộ tỷ giá mới tức thì (Realtime) đến tất cả điện thoại khách hàng.
* **Lịch sử & Khôi phục (History & Restore)**: Xem lịch sử tất cả các lần đổi tỷ giá và có thể bấm 1 nút để khôi phục lại tỷ giá cũ bất cứ lúc nào.
