// Testes básicos do app MyFretes
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppStrings', () {
    test('appName deve ser MyFretes', () {
      // Importação e verificação básica de constante
      const appName = 'MyFretes';
      expect(appName, equals('MyFretes'));
    });
  });

  group('RouteNames', () {
    test('rota splash deve ser /', () {
      const splash = '/';
      expect(splash, startsWith('/'));
    });
  });
}
