import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:catatan_polnes/services/theme_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThemeStorage', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('loadThemeMode returns ThemeMode.system by default', () async {
      final storage = ThemeStorage();
      final mode = await storage.loadThemeMode();
      expect(mode, ThemeMode.system);
    });

    test(
      'saveThemeMode persists dark mode and loadThemeMode reads it',
      () async {
        final storage = ThemeStorage();
        await storage.saveThemeMode(ThemeMode.dark);

        final newStorageInstance = ThemeStorage();
        final loadedMode = await newStorageInstance.loadThemeMode();
        expect(loadedMode, ThemeMode.dark);
      },
    );

    test(
      'saveThemeMode persists light mode and loadThemeMode reads it',
      () async {
        final storage = ThemeStorage();
        await storage.saveThemeMode(ThemeMode.light);

        final newStorageInstance = ThemeStorage();
        final loadedMode = await newStorageInstance.loadThemeMode();
        expect(loadedMode, ThemeMode.light);
      },
    );

    test('clearThemeMode resets the stored theme mode', () async {
      final storage = ThemeStorage();
      await storage.saveThemeMode(ThemeMode.dark);
      await storage.clearThemeMode();

      final loadedMode = await storage.loadThemeMode();
      expect(loadedMode, ThemeMode.system);
    });
  });
}
