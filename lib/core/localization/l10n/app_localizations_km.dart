// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Khmer Central Khmer (`km`).
class AppLocalizationsKm extends AppLocalizations {
  AppLocalizationsKm([String locale = 'km']) : super(locale);

  @override
  String get appName => 'LyHENG VND-USD';

  @override
  String get homeTitle => 'អត្រាប្តូរប្រាក់ & គណនា';

  @override
  String get buyRate => 'តម្លៃទិញ (BUY)';

  @override
  String get sellRate => 'តម្លៃលក់ (SELL)';

  @override
  String get usdToVnd => 'USD ទៅ VND (លក់ USD)';

  @override
  String get vndToUsd => 'VND ទៅ USD (ទិញ USD)';

  @override
  String get usdToVndDesc => 'អតិថិជនលក់ USD ឱ្យហាង';

  @override
  String get vndToUsdDesc => 'អតិថិជនទិញ USD ពីហាង';

  @override
  String get formulaUsdToVnd => 'VND = USD × តម្លៃទិញ';

  @override
  String get formulaVndToUsd => 'USD = VND ÷ តម្លៃលក់';

  @override
  String get enterAmount => 'បញ្ចូលចំនួនទឹកប្រាក់';

  @override
  String get result => 'លទ្ធផល';

  @override
  String get swapDirection => 'ប្តូរទិសដៅ';

  @override
  String get clear => 'សម្អាត';

  @override
  String get copy => 'ចម្លង';

  @override
  String get share => 'ចែករំលែក';

  @override
  String get copied => 'បានចម្លងរួចរាល់';

  @override
  String get lastUpdated => 'បានធ្វើបច្ចុប្បន្នភាពនៅ';

  @override
  String get rateVersion => 'ជំនាន់';

  @override
  String get statusOnline => 'អនឡាញ';

  @override
  String get statusOffline => 'ក្រៅបណ្តាញ (Offline)';

  @override
  String get statusConnecting => 'កំពុងភ្ជាប់...';

  @override
  String get offlineWarning =>
      'កំពុងប្រើទិន្នន័យចងចាំបណ្តោះអាសន្ន។ អត្រាអាចមិនទាន់ទាន់សម័យ។';

  @override
  String get demoWarning =>
      'អត្រាសាកល្បង (DEMO) - អ្នកគ្រប់គ្រងមិនទាន់បានបោះផ្សាយអត្រាផ្លូវការនៅឡើយ។';

  @override
  String get settings => 'ការកំណត់';

  @override
  String get language => 'ភាសា';

  @override
  String get theme => 'រូបរាង';

  @override
  String get themeLight => 'ពន្លឺ';

  @override
  String get themeDark => 'ងងឹត';

  @override
  String get themeSystem => 'តាមប្រព័ន្ធ';

  @override
  String get about => 'អំពីកម្មវិធី';

  @override
  String get rateDetails => 'ព័ត៌មានលម្អិតអំពីអត្រា';

  @override
  String get adminLogin => 'ចូលប្រព័ន្ធអ្នកគ្រប់គ្រង';

  @override
  String get adminDashboard => 'ផ្ទាំងគ្រប់គ្រង Admin';

  @override
  String get email => 'អ៊ីមែល Admin';

  @override
  String get password => 'ពាក្យសម្ងាត់';

  @override
  String get signIn => 'ចូលប្រើ';

  @override
  String get signOut => 'ចាកចេញ';

  @override
  String get editBuyRate => 'កែសម្រួលតម្លៃទិញ';

  @override
  String get editSellRate => 'កែសម្រួលតម្លៃលក់';

  @override
  String get currentRates => 'អត្រាបច្ចុប្បន្ន';

  @override
  String get newRates => 'អត្រាថ្មី';

  @override
  String get previewNewRates => 'មើលអត្រាថ្មីជាមុន';

  @override
  String get publishRates => 'បោះផ្សាយអត្រាថ្មី';

  @override
  String get publishConfirmTitle => 'បញ្ជាក់ការបោះផ្សាយ';

  @override
  String get publishConfirmDesc =>
      'តើអ្នកប្រាកដជាចង់បោះផ្សាយអត្រាថ្មីនេះទៅកាន់អ្នកប្រើប្រាស់ទាំងអស់មែនទេ?';

  @override
  String get confirm => 'បញ្ជាក់';

  @override
  String get cancel => 'បោះបង់';

  @override
  String get publishedSuccess => 'បានបោះផ្សាយអត្រាដោយជោគជ័យ!';

  @override
  String get rateHistory => 'ប្រវត្តិផ្លាស់ប្តូរអត្រា';

  @override
  String get restoreRate => 'ស្តារអត្រានេះឡើងវិញ';

  @override
  String get restoreConfirmTitle => 'បញ្ជាក់ការស្តារឡើងវិញ';

  @override
  String restoreConfirmDesc(String version) {
    return 'ស្តារអត្រាជំនាន់ $version ជាអត្រាសកម្មបច្ចុប្បន្ន?';
  }

  @override
  String get restoredSuccess => 'បានស្តារអត្រាឡើងវិញដោយជោគជ័យ!';

  @override
  String get adminProfile => 'គណនី Admin';

  @override
  String get accessDenied =>
      'ការចូលប្រើត្រូវបានបដិសេធ។ គណនីគ្មានសិទ្ធិជាអ្នកគ្រប់គ្រងទេ។';

  @override
  String get invalidAmount => 'សូមបញ្ចូលចំនួនទឹកប្រាក់ត្រឹមត្រូវ';

  @override
  String get invalidRate => 'អត្រាត្រូវតែធំជាង 0';

  @override
  String get aboutDescription =>
      'LyHENG VND-USD ជាកម្មវិធីគណនាប្តូរប្រាក់រវាងដុល្លារ (USD) និងដុង (VND) ប្រកបដោយវិជ្ជាជីវៈ និងភាពជាក់លាក់ភ្លាមៗ។';

  @override
  String get disclaimerTitle => 'ការមិនទទួលខុសត្រូវ';

  @override
  String get disclaimer =>
      'កម្មវិធីនេះសម្រាប់តែគណនាអត្រាប្តូរប្រាក់យោងប៉ុណ្ណោះ។ មិនមានសេវាផ្ទេរប្រាក់ ឬប្រតិបត្តិការហិរញ្ញវត្ថុជាក់ស្តែងឡើយ។';

  @override
  String get allRightsReserved => 'រក្សាសិទ្ធិគ្រប់យ៉ាងដោយ LyHENG.';
}
