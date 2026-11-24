// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'LyHENG VND-USD';

  @override
  String get homeTitle => 'Rates & Calculator';

  @override
  String get buyRate => 'BUY RATE';

  @override
  String get sellRate => 'SELL RATE';

  @override
  String get usdToVnd => 'USD to VND (Sell USD)';

  @override
  String get vndToUsd => 'VND to USD (Buy USD)';

  @override
  String get usdToVndDesc => 'Customer sells USD to shop';

  @override
  String get vndToUsdDesc => 'Customer buys USD from shop';

  @override
  String get formulaUsdToVnd => 'VND = USD × BUY RATE';

  @override
  String get formulaVndToUsd => 'USD = VND ÷ SELL RATE';

  @override
  String get enterAmount => 'Enter amount';

  @override
  String get result => 'Result';

  @override
  String get swapDirection => 'Swap Direction';

  @override
  String get clear => 'Clear';

  @override
  String get copy => 'Copy';

  @override
  String get share => 'Share';

  @override
  String get copied => 'Copied to clipboard';

  @override
  String get lastUpdated => 'Last updated';

  @override
  String get rateVersion => 'Version';

  @override
  String get statusOnline => 'Online';

  @override
  String get statusOffline => 'Offline';

  @override
  String get statusConnecting => 'Connecting...';

  @override
  String get offlineWarning =>
      'Using locally cached rate. The rate may be outdated.';

  @override
  String get demoWarning =>
      'DEMO RATE - The administrator has not published live rates yet.';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System Default';

  @override
  String get about => 'About Application';

  @override
  String get rateDetails => 'Rate Details';

  @override
  String get adminLogin => 'Admin Login';

  @override
  String get adminDashboard => 'Admin Dashboard';

  @override
  String get email => 'Admin Email';

  @override
  String get password => 'Password';

  @override
  String get signIn => 'Sign In';

  @override
  String get signOut => 'Sign Out';

  @override
  String get editBuyRate => 'Edit BUY RATE';

  @override
  String get editSellRate => 'Edit SELL RATE';

  @override
  String get currentRates => 'Current Rates';

  @override
  String get newRates => 'New Rates';

  @override
  String get previewNewRates => 'Preview New Rates';

  @override
  String get publishRates => 'Publish Rates';

  @override
  String get publishConfirmTitle => 'Confirm Publish';

  @override
  String get publishConfirmDesc =>
      'Are you sure you want to publish these new rates to all users?';

  @override
  String get confirm => 'Confirm';

  @override
  String get cancel => 'Cancel';

  @override
  String get publishedSuccess => 'Rates published successfully!';

  @override
  String get rateHistory => 'Rate Change History';

  @override
  String get restoreRate => 'Restore This Rate';

  @override
  String get restoreConfirmTitle => 'Confirm Restore';

  @override
  String restoreConfirmDesc(String version) {
    return 'Restore rate version $version as the active rate?';
  }

  @override
  String get restoredSuccess => 'Rate restored successfully!';

  @override
  String get adminProfile => 'Admin Profile';

  @override
  String get accessDenied =>
      'Access denied. Account is not an authorized administrator.';

  @override
  String get invalidAmount => 'Please enter a valid amount';

  @override
  String get invalidRate => 'Rate must be greater than 0';

  @override
  String get aboutDescription =>
      'LyHENG VND-USD is a professional, transparent, and instant USD-VND currency exchange calculator.';

  @override
  String get disclaimerTitle => 'Disclaimer';

  @override
  String get disclaimer =>
      'This app is an exchange rate calculator only. It does not perform money transfers or financial transactions.';

  @override
  String get allRightsReserved => 'All rights reserved by LyHENG.';
}
