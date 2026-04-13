import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Riverpod provider for the Supabase client.
/// Use this when you need direct access to the Supabase client outside of
/// auth (e.g., storage, realtime, database queries from Flutter).
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});
