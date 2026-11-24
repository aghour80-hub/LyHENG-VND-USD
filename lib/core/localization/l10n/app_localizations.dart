import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_km.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('km'),
    Locale('vi'),
  ];

  /// No description provided for @appName.
  ///
  /// In vi, this message translates to:
  /// **'LyHENG VND-USD'**
  String get appName;

  /// No description provided for @homeTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tỷ Giá & Tính Toán'**
  String get homeTitle;

  /// No description provided for @buyRate.
  ///
  /// In vi, this message translates to:
  /// **'GIÁ MUA (BUY)'**
  String get buyRate;

  /// No description provided for @sellRate.
  ///
  /// In vi, this message translates to:
  /// **'GIÁ BÁN (SELL)'**
  String get sellRate;

  /// No description provided for @usdToVnd.
  ///
  /// In vi, this message translates to:
  /// **'USD sang VND (Bán USD)'**
  String get usdToVnd;

  /// No description provided for @vndToUsd.
  ///
  /// In vi, this message translates to:
  /// **'VND sang USD (Mua USD)'**
  String get vndToUsd;

  /// No description provided for @usdToVndDesc.
  ///
  /// In vi, this message translates to:
  /// **'Khách bán USD cho tiệm'**
  String get usdToVndDesc;

  /// No description provided for @vndToUsdDesc.
  ///
  /// In vi, this message translates to:
  /// **'Khách mua USD từ tiệm'**
  String get vndToUsdDesc;

  /// No description provided for @formulaUsdToVnd.
  ///
  /// In vi, this message translates to:
  /// **'VND = USD × Giá Mua'**
  String get formulaUsdToVnd;

  /// No description provided for @formulaVndToUsd.
  ///
  /// In vi, this message translates to:
  /// **'USD = VND ÷ Giá Bán'**
  String get formulaVndToUsd;

  /// No description provided for @enterAmount.
  ///
  /// In vi, this message translates to:
  /// **'Nhập số tiền'**
  String get enterAmount;

  /// No description provided for @result.
  ///
  /// In vi, this message translates to:
  /// **'Kết quả'**
  String get result;

  /// No description provided for @swapDirection.
  ///
  /// In vi, this message translates to:
  /// **'Đổi chiều tính'**
  String get swapDirection;

  /// No description provided for @clear.
  ///
  /// In vi, this message translates to:
  /// **'Xóa'**
  String get clear;

  /// No description provided for @copy.
  ///
  /// In vi, this message translates to:
  /// **'Sao chép'**
  String get copy;

  /// No description provided for @share.
  ///
  /// In vi, this message translates to:
  /// **'Chia sẻ'**
  String get share;

  /// No description provided for @copied.
  ///
  /// In vi, this message translates to:
  /// **'Đã sao chép kết quả'**
  String get copied;

  /// No description provided for @lastUpdated.
  ///
  /// In vi, this message translates to:
  /// **'Cập nhật lúc'**
  String get lastUpdated;

  /// No description provided for @rateVersion.
  ///
  /// In vi, this message translates to:
  /// **'Phiên bản'**
  String get rateVersion;

  /// No description provided for @statusOnline.
  ///
  /// In vi, this message translates to:
  /// **'Trực tuyến'**
  String get statusOnline;

  /// No description provided for @statusOffline.
  ///
  /// In vi, this message translates to:
  /// **'Ngoại tuyến'**
  String get statusOffline;

  /// No description provided for @statusConnecting.
  ///
  /// In vi, this message translates to:
  /// **'Đang kết nối...'**
  String get statusConnecting;

  /// No description provided for @offlineWarning.
  ///
  /// In vi, this message translates to:
  /// **'Bạn đang dùng dữ liệu lưu tạm. Tỷ giá có thể chưa mới nhất.'**
  String get offlineWarning;

  /// No description provided for @demoWarning.
  ///
  /// In vi, this message translates to:
  /// **'TỶ GIÁ THỬ NGHIỆM (DEMO) - Quản trị viên chưa xuất bản tỷ giá mới.'**
  String get demoWarning;

  /// No description provided for @settings.
  ///
  /// In vi, this message translates to:
  /// **'Cài đặt'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In vi, this message translates to:
  /// **'Ngôn ngữ'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In vi, this message translates to:
  /// **'Giao diện'**
  String get theme;

  /// No description provided for @themeLight.
  ///
  /// In vi, this message translates to:
  /// **'Sáng'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In vi, this message translates to:
  /// **'Tối'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In vi, this message translates to:
  /// **'Theo hệ thống'**
  String get themeSystem;

  /// No description provided for @about.
  ///
  /// In vi, this message translates to:
  /// **'Giới thiệu ứng dụng'**
  String get about;

  /// No description provided for @rateDetails.
  ///
  /// In vi, this message translates to:
  /// **'Chi tiết tỷ giá'**
  String get rateDetails;

  /// No description provided for @adminLogin.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập Quản trị'**
  String get adminLogin;

  /// No description provided for @adminDashboard.
  ///
  /// In vi, this message translates to:
  /// **'Bảng điều khiển Quản trị'**
  String get adminDashboard;

  /// No description provided for @email.
  ///
  /// In vi, this message translates to:
  /// **'Email quản trị'**
  String get email;

  /// No description provided for @password.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu'**
  String get password;

  /// No description provided for @signIn.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập'**
  String get signIn;

  /// No description provided for @signOut.
  ///
  /// In vi, this message translates to:
  /// **'Đăng xuất'**
  String get signOut;

  /// No description provided for @editBuyRate.
  ///
  /// In vi, this message translates to:
  /// **'Chỉnh sửa Giá Mua'**
  String get editBuyRate;

  /// No description provided for @editSellRate.
  ///
  /// In vi, this message translates to:
  /// **'Chỉnh sửa Giá Bán'**
  String get editSellRate;

  /// No description provided for @currentRates.
  ///
  /// In vi, this message translates to:
  /// **'Tỷ giá hiện tại'**
  String get currentRates;

  /// No description provided for @newRates.
  ///
  /// In vi, this message translates to:
  /// **'Tỷ giá mới'**
  String get newRates;

  /// No description provided for @previewNewRates.
  ///
  /// In vi, this message translates to:
  /// **'Xem trước tỷ giá mới'**
  String get previewNewRates;

  /// No description provided for @publishRates.
  ///
  /// In vi, this message translates to:
  /// **'Xuất bản tỷ giá'**
  String get publishRates;

  /// No description provided for @publishConfirmTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận xuất bản'**
  String get publishConfirmTitle;

  /// No description provided for @publishConfirmDesc.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc chắn muốn xuất bản tỷ giá mới này cho tất cả người dùng không?'**
  String get publishConfirmDesc;

  /// No description provided for @confirm.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận'**
  String get confirm;

  /// No description provided for @cancel.
  ///
  /// In vi, this message translates to:
  /// **'Hủy'**
  String get cancel;

  /// No description provided for @publishedSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đã xuất bản tỷ giá thành công!'**
  String get publishedSuccess;

  /// No description provided for @rateHistory.
  ///
  /// In vi, this message translates to:
  /// **'Lịch sử thay đổi tỷ giá'**
  String get rateHistory;

  /// No description provided for @restoreRate.
  ///
  /// In vi, this message translates to:
  /// **'Khôi phục tỷ giá này'**
  String get restoreRate;

  /// No description provided for @restoreConfirmTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận khôi phục'**
  String get restoreConfirmTitle;

  /// No description provided for @restoreConfirmDesc.
  ///
  /// In vi, this message translates to:
  /// **'Khôi phục phiên bản {version} làm tỷ giá hiện hành?'**
  String restoreConfirmDesc(String version);

  /// No description provided for @restoredSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đã khôi phục tỷ giá thành công!'**
  String get restoredSuccess;

  /// No description provided for @adminProfile.
  ///
  /// In vi, this message translates to:
  /// **'Hồ sơ Quản trị'**
  String get adminProfile;

  /// No description provided for @accessDenied.
  ///
  /// In vi, this message translates to:
  /// **'Từ chối truy cập. Tài khoản không có quyền Quản trị.'**
  String get accessDenied;

  /// No description provided for @invalidAmount.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập số tiền hợp lệ'**
  String get invalidAmount;

  /// No description provided for @invalidRate.
  ///
  /// In vi, this message translates to:
  /// **'Tỷ giá phải lớn hơn 0'**
  String get invalidRate;

  /// No description provided for @aboutDescription.
  ///
  /// In vi, this message translates to:
  /// **'LyHENG VND-USD là công cụ tính toán quy đổi tỷ giá tiền tệ USD và VND chuyên nghiệp, minh bạch và tức thì.'**
  String get aboutDescription;

  /// No description provided for @disclaimerTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tuyên bố trách nhiệm'**
  String get disclaimerTitle;

  /// No description provided for @disclaimer.
  ///
  /// In vi, this message translates to:
  /// **'Ứng dụng này chỉ là công cụ tính toán tỷ giá tham khảo. Ứng dụng không cung cấp dịch vụ chuyển tiền hay giao dịch tài chính trực tiếp.'**
  String get disclaimer;

  /// No description provided for @allRightsReserved.
  ///
  /// In vi, this message translates to:
  /// **'Bản quyền thuộc về LyHENG.'**
  String get allRightsReserved;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'km', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'km':
      return AppLocalizationsKm();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
