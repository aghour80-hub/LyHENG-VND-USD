import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'data/local/preferences_service.dart';
import 'data/services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  await PreferencesService.init();

  // Initialize Supabase safely (handles dev.json or fallback demo mode)
  await SupabaseService.initialize();

  runApp(
    const ProviderScope(
      child: LyHengApp(),
    ),
  );
}
