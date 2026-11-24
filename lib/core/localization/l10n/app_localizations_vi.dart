// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appName => 'LyHENG VND-USD';

  @override
  String get homeTitle => 'Tỷ Giá & Tính Toán';

  @override
  String get buyRate => 'GIÁ MUA (BUY)';

  @override
  String get sellRate => 'GIÁ BÁN (SELL)';

  @override
  String get usdToVnd => 'USD sang VND (Bán USD)';

  @override
  String get vndToUsd => 'VND sang USD (Mua USD)';

  @override
  String get usdToVndDesc => 'Khách bán USD cho tiệm';

  @override
  String get vndToUsdDesc => 'Khách mua USD từ tiệm';

  @override
  String get formulaUsdToVnd => 'VND = USD × Giá Mua';

  @override
  String get formulaVndToUsd => 'USD = VND ÷ Giá Bán';

  @override
  String get enterAmount => 'Nhập số tiền';

  @override
  String get result => 'Kết quả';

  @override
  String get swapDirection => 'Đổi chiều tính';

  @override
  String get clear => 'Xóa';

  @override
  String get copy => 'Sao chép';

  @override
  String get share => 'Chia sẻ';

  @override
  String get copied => 'Đã sao chép kết quả';

  @override
  String get lastUpdated => 'Cập nhật lúc';

  @override
  String get rateVersion => 'Phiên bản';

  @override
  String get statusOnline => 'Trực tuyến';

  @override
  String get statusOffline => 'Ngoại tuyến';

  @override
  String get statusConnecting => 'Đang kết nối...';

  @override
  String get offlineWarning =>
      'Bạn đang dùng dữ liệu lưu tạm. Tỷ giá có thể chưa mới nhất.';

  @override
  String get demoWarning =>
      'TỶ GIÁ THỬ NGHIỆM (DEMO) - Quản trị viên chưa xuất bản tỷ giá mới.';

  @override
  String get settings => 'Cài đặt';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get theme => 'Giao diện';

  @override
  String get themeLight => 'Sáng';

  @override
  String get themeDark => 'Tối';

  @override
  String get themeSystem => 'Theo hệ thống';

  @override
  String get about => 'Giới thiệu ứng dụng';

  @override
  String get rateDetails => 'Chi tiết tỷ giá';

  @override
  String get adminLogin => 'Đăng nhập Quản trị';

  @override
  String get adminDashboard => 'Bảng điều khiển Quản trị';

  @override
  String get email => 'Email quản trị';

  @override
  String get password => 'Mật khẩu';

  @override
  String get signIn => 'Đăng nhập';

  @override
  String get signOut => 'Đăng xuất';

  @override
  String get editBuyRate => 'Chỉnh sửa Giá Mua';

  @override
  String get editSellRate => 'Chỉnh sửa Giá Bán';

  @override
  String get currentRates => 'Tỷ giá hiện tại';

  @override
  String get newRates => 'Tỷ giá mới';

  @override
  String get previewNewRates => 'Xem trước tỷ giá mới';

  @override
  String get publishRates => 'Xuất bản tỷ giá';

  @override
  String get publishConfirmTitle => 'Xác nhận xuất bản';

  @override
  String get publishConfirmDesc =>
      'Bạn có chắc chắn muốn xuất bản tỷ giá mới này cho tất cả người dùng không?';

  @override
  String get confirm => 'Xác nhận';

  @override
  String get cancel => 'Hủy';

  @override
  String get publishedSuccess => 'Đã xuất bản tỷ giá thành công!';

  @override
  String get rateHistory => 'Lịch sử thay đổi tỷ giá';

  @override
  String get restoreRate => 'Khôi phục tỷ giá này';

  @override
  String get restoreConfirmTitle => 'Xác nhận khôi phục';

  @override
  String restoreConfirmDesc(String version) {
    return 'Khôi phục phiên bản $version làm tỷ giá hiện hành?';
  }

  @override
  String get restoredSuccess => 'Đã khôi phục tỷ giá thành công!';

  @override
  String get adminProfile => 'Hồ sơ Quản trị';

  @override
  String get accessDenied =>
      'Từ chối truy cập. Tài khoản không có quyền Quản trị.';

  @override
  String get invalidAmount => 'Vui lòng nhập số tiền hợp lệ';

  @override
  String get invalidRate => 'Tỷ giá phải lớn hơn 0';

  @override
  String get aboutDescription =>
      'LyHENG VND-USD là công cụ tính toán quy đổi tỷ giá tiền tệ USD và VND chuyên nghiệp, minh bạch và tức thì.';

  @override
  String get disclaimerTitle => 'Tuyên bố trách nhiệm';

  @override
  String get disclaimer =>
      'Ứng dụng này chỉ là công cụ tính toán tỷ giá tham khảo. Ứng dụng không cung cấp dịch vụ chuyển tiền hay giao dịch tài chính trực tiếp.';

  @override
  String get allRightsReserved => 'Bản quyền thuộc về LyHENG.';
}
