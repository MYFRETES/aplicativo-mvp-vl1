// Cliente Supabase singleton
import 'package:supabase_flutter/supabase_flutter.dart';

/// Acesso global ao cliente Supabase.
/// Configure SUPABASE_URL e SUPABASE_ANON_KEY no arquivo main.dart
/// ou em variáveis de ambiente antes de inicializar o app.
SupabaseClient get supabase => Supabase.instance.client;
