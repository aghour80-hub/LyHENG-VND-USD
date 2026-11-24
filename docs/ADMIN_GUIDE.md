# Administrator Guide — LyHENG VND-USD

## 1. Initial Admin Account Setup
Follow these steps to grant your administrator account access:

1. **Create the User in Supabase Dashboard**:
   - Go to your Supabase Project -> **Authentication** -> **Users**.
   - Click **Add User** -> **Create User**.
   - Enter your Admin email (e.g. `admin@lyheng.com`) and a strong password.
   - Confirm the email address.

2. **Retrieve the User UUID**:
   - Copy the `User UID` (e.g., `a1b2c3d4-e5f6-7890-abcd-ef1234567890`).

3. **Insert Admin Record in SQL Editor**:
   - Go to Supabase -> **SQL Editor**.
   - Run the following query:
   ```sql
   INSERT INTO public.admin_users (user_id, role)
   VALUES ('YOUR_USER_UUID_HERE', 'superadmin');
   ```

4. **Verify Authorization**:
   ```sql
   SELECT public.is_authorized_admin('YOUR_USER_UUID_HERE');
   -- Returns true
   ```

## 2. Managing Exchange Rates from Mobile
1. Open the **LyHENG VND-USD** mobile app.
2. Tap the **Settings** icon on the top right.
3. Tap **Đăng nhập Quản trị / Admin Login**.
4. Enter your admin email and password.
5. On the **Bảng điều khiển Quản trị (Admin Dashboard)**:
   - **Edit BUY RATE**: Tap to change the shop's buy rate (VND customer gets per 1 USD).
   - **Edit SELL RATE**: Tap to change the shop's sell rate (VND customer pays per 1 USD).
   - **Preview New Rates**: Review calculations and compare new rates against active rates.
   - **Publish**: Confirm publication. All connected public users receive the update in real time.
6. **Restoring Previous Rates**:
   - Tap **Lịch sử thay đổi tỷ giá (Rate Change History)**.
   - Select any previous rate record and tap **Khôi phục tỷ giá này (Restore This Rate)**.
   - Confirm to rollback the active exchange rate.
