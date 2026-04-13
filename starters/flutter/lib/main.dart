import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'config/env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Supabase.initialize(
      url: EnvConfig.current.supabaseUrl,
      anonKey: EnvConfig.current.supabaseAnonKey,
    );
  } catch (e) {
    // Surface a clear error if Supabase credentials are misconfigured.
    // Update lib/config/env.dart with your project's URL and anon key.
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Supabase initialisation failed.\n\n'
                'Check lib/config/env.dart and ensure supabaseUrl '
                'and supabaseAnonKey are set correctly.\n\n'
                'Error: $e',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
    return;
  }

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
