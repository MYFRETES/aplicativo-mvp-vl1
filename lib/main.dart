// Ponto de entrada do app MyFretes
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/app_widget.dart';

// ⚠️  IMPORTANTE: substitua os valores abaixo pelas suas credenciais do Supabase.
// Acesse https://app.supabase.com → Settings → API para obter a URL e a anon key.
// Nunca exponha a service_role key no app mobile.
const _supabaseUrl = 'SUA_SUPABASE_URL';
const _supabaseAnonKey = 'SUA_SUPABASE_ANON_KEY';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: _supabaseUrl,
    anonKey: _supabaseAnonKey,
  );

  runApp(const AppWidget());
}
