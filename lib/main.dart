import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app_widget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO: substitua pelos valores reais do seu projeto Supabase.
  // Em produção, utilize variáveis de ambiente (ex.: flutter_dotenv ou envied)
  // e nunca versione credenciais reais no repositório.
  await Supabase.initialize(
    url: 'SUA_SUPABASE_URL',
    anonKey: 'SUA_SUPABASE_ANON_KEY',
  );

  runApp(const AppWidget());
}
