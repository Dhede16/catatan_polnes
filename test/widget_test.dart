import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:catatan_polnes/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Menampilkan judul Catatan POLNES dan catatan contoh awal', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verifikasi judul pada AppBar
    expect(find.text('Catatan POLNES'), findsWidgets);
    expect(find.text('Buku Catatan Digital POLNES'), findsOneWidget);

    // Verifikasi keberadaan catatan contoh awal
    expect(find.text('Pengantar Pemrograman Bergerak'), findsOneWidget);
    expect(find.text('Tugas Desain UI Aplikasi Mobile'), findsOneWidget);
    expect(find.text('Jadwal Kuliah Semester Ini'), findsOneWidget);

    // Verifikasi tombol tambah catatan
    expect(find.byType(FloatingActionButton), findsOneWidget);

    // Verifikasi keberadaan tombol tema
    expect(find.byKey(const Key('theme_toggle_button')), findsOneWidget);
  });

  testWidgets('Filter catatan berdasarkan pencarian teks', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Masukkan kata kunci pencarian pada search bar
    await tester.enterText(find.byType(TextField).first, 'Praktikum');
    await tester.pumpAndSettle();

    // Catatan yang memuat 'Praktikum' harus tetap muncul
    expect(find.text('Pengantar Pemrograman Bergerak'), findsOneWidget);

    // Catatan yang tidak relevan akan disaring keluar
    expect(find.text('Jadwal Kuliah Semester Ini'), findsNothing);
  });

  testWidgets('Membuka editor catatan dan menambahkan catatan baru', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Tap tombol tambah catatan
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Pastikan masuk ke halaman Catatan Baru
    expect(find.text('Catatan Baru'), findsOneWidget);

    // Masukkan judul dan isi
    final textFields = find.byType(TextField);
    await tester.enterText(textFields.at(0), 'Catatan Ujian Akhir POLNES');
    await tester.enterText(
      textFields.at(1),
      'Persiapan UAS Pemrograman Mobile di lab.',
    );

    // Simpan catatan dengan tap icon check pada AppBar
    await tester.tap(find.byKey(const Key('save_note_button')));
    await tester.pumpAndSettle();

    // Catatan baru harus muncul di daftar utama
    expect(find.text('Catatan Ujian Akhir POLNES'), findsOneWidget);
  });

  testWidgets('Menghapus catatan melalui dialog konfirmasi', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Catatan awal ada di layar
    expect(find.text('Jadwal Kuliah Semester Ini'), findsOneWidget);

    // Tap tombol delete pada kartu pertama (Jadwal Kuliah Semester Ini)
    await tester.tap(find.byTooltip('Hapus Catatan').first);
    await tester.pumpAndSettle();

    // Dialog konfirmasi muncul
    expect(find.text('Hapus Catatan'), findsOneWidget);

    // Konfirmasi hapus
    await tester.tap(find.text('Hapus'));
    await tester.pumpAndSettle();

    // Catatan tersebut harus terhapus
    expect(find.text('Jadwal Kuliah Semester Ini'), findsNothing);
  });

  testWidgets('Catatan baru tetap tersimpan setelah aplikasi dimuat ulang', (
    WidgetTester tester,
  ) async {
    // Sesi Pertama: Buat catatan baru
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    final textFields = find.byType(TextField);
    await tester.enterText(textFields.at(0), 'Catatan Praktikum Persistensi');
    await tester.enterText(
      textFields.at(1),
      'Data ini harus tetap ada saat app dibuka lagi.',
    );

    await tester.tap(find.byKey(const Key('save_note_button')));
    await tester.pumpAndSettle();

    expect(find.text('Catatan Praktikum Persistensi'), findsOneWidget);

    // Sesi Kedua: Buka kembali aplikasi dari awal (simulasi restart app)
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verifikasi catatan baru tetap ada
    expect(find.text('Catatan Praktikum Persistensi'), findsOneWidget);
  });

  testWidgets(
    'Tombol toggle tema mengubah mode tema terang ke gelap dan sebaliknya',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp(initialThemeMode: ThemeMode.light));
      await tester.pumpAndSettle();

      // Pastikan tema awal adalah terang
      final MaterialApp appBefore = tester.widget(find.byType(MaterialApp));
      expect(appBefore.themeMode, ThemeMode.light);

      // Tap tombol beralih tema
      await tester.tap(find.byKey(const Key('theme_toggle_button')));
      await tester.pumpAndSettle();

      // Verifikasi tema berubah menjadi gelap
      final MaterialApp appAfterDark = tester.widget(find.byType(MaterialApp));
      expect(appAfterDark.themeMode, ThemeMode.dark);

      // Tap lagi untuk kembali ke tema terang
      await tester.tap(find.byKey(const Key('theme_toggle_button')));
      await tester.pumpAndSettle();

      // Verifikasi tema kembali menjadi terang
      final MaterialApp appAfterLight = tester.widget(find.byType(MaterialApp));
      expect(appAfterLight.themeMode, ThemeMode.light);
    },
  );

  testWidgets(
    'Pilihan tema pengguna tetap tersimpan setelah aplikasi dimuat ulang',
    (WidgetTester tester) async {
      // Sesi Pertama: Buka aplikasi, ganti ke mode gelap
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('theme_toggle_button')));
      await tester.pumpAndSettle();

      final MaterialApp appDark = tester.widget(find.byType(MaterialApp));
      expect(appDark.themeMode, ThemeMode.dark);

      // Sesi Kedua: Buka kembali aplikasi dari awal (simulasi restart app)
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Verifikasi tema yang dimuat adalah tema gelap
      final MaterialApp reloadedApp = tester.widget(find.byType(MaterialApp));
      expect(reloadedApp.themeMode, ThemeMode.dark);
    },
  );

  testWidgets(
    'Mengurutkan catatan melalui PopupMenuButton (Terbaru, Terlama, Judul A-Z, Dipin)',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Verifikasi tombol menu sortir ada di AppBar
      final sortButton = find.byKey(const Key('sort_menu_button'));
      expect(sortButton, findsOneWidget);

      // 1. Uji Sortir Judul A-Z
      await tester.tap(sortButton);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('sort_option_terbaru')), findsOneWidget);
      expect(find.byKey(const Key('sort_option_terlama')), findsOneWidget);
      expect(find.byKey(const Key('sort_option_judul')), findsOneWidget);
      expect(find.byKey(const Key('sort_option_dipin')), findsOneWidget);

      await tester.tap(find.byKey(const Key('sort_option_judul')));
      await tester.pumpAndSettle();

      // Urutan Judul A-Z:
      // 1. Jadwal Kuliah Semester Ini
      // 2. Pengantar Pemrograman Bergerak
      // 3. Tugas Desain UI Aplikasi Mobile
      final cardTitlesJudul = find
          .byType(Text)
          .evaluate()
          .where(
            (e) => [
              'Jadwal Kuliah Semester Ini',
              'Pengantar Pemrograman Bergerak',
              'Tugas Desain UI Aplikasi Mobile',
            ].contains((e.widget as Text).data),
          )
          .map((e) => (e.widget as Text).data)
          .toList();
      expect(cardTitlesJudul, [
        'Jadwal Kuliah Semester Ini',
        'Pengantar Pemrograman Bergerak',
        'Tugas Desain UI Aplikasi Mobile',
      ]);

      // 2. Uji Sortir Terlama
      await tester.tap(sortButton);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('sort_option_terlama')));
      await tester.pumpAndSettle();

      // Urutan Terlama (2 hari lalu -> 1 hari lalu -> 5 jam lalu):
      // 1. Pengantar Pemrograman Bergerak (2 days ago)
      // 2. Tugas Desain UI Aplikasi Mobile (1 day ago)
      // 3. Jadwal Kuliah Semester Ini (5 hours ago)
      final cardTitlesTerlama = find
          .byType(Text)
          .evaluate()
          .where(
            (e) => [
              'Jadwal Kuliah Semester Ini',
              'Pengantar Pemrograman Bergerak',
              'Tugas Desain UI Aplikasi Mobile',
            ].contains((e.widget as Text).data),
          )
          .map((e) => (e.widget as Text).data)
          .toList();
      expect(cardTitlesTerlama, [
        'Pengantar Pemrograman Bergerak',
        'Tugas Desain UI Aplikasi Mobile',
        'Jadwal Kuliah Semester Ini',
      ]);

      // 3. Uji Sortir Catatan yang Dipin
      await tester.tap(sortButton);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('sort_option_dipin')));
      await tester.pumpAndSettle();

      // Urutan Dipin (isPinned=true first, then newest):
      // 1. Pengantar Pemrograman Bergerak (pinned)
      // 2. Jadwal Kuliah Semester Ini (5 hours ago)
      // 3. Tugas Desain UI Aplikasi Mobile (1 day ago)
      final cardTitlesDipin = find
          .byType(Text)
          .evaluate()
          .where(
            (e) => [
              'Jadwal Kuliah Semester Ini',
              'Pengantar Pemrograman Bergerak',
              'Tugas Desain UI Aplikasi Mobile',
            ].contains((e.widget as Text).data),
          )
          .map((e) => (e.widget as Text).data)
          .toList();
      expect(cardTitlesDipin, [
        'Pengantar Pemrograman Bergerak',
        'Jadwal Kuliah Semester Ini',
        'Tugas Desain UI Aplikasi Mobile',
      ]);

      // 4. Uji Sortir Kembali ke Terbaru
      await tester.tap(sortButton);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('sort_option_terbaru')));
      await tester.pumpAndSettle();

      // Urutan Terbaru (5 jam lalu -> 1 hari lalu -> 2 hari lalu):
      // 1. Jadwal Kuliah Semester Ini
      // 2. Tugas Desain UI Aplikasi Mobile
      // 3. Pengantar Pemrograman Bergerak
      final cardTitlesTerbaru = find
          .byType(Text)
          .evaluate()
          .where(
            (e) => [
              'Jadwal Kuliah Semester Ini',
              'Pengantar Pemrograman Bergerak',
              'Tugas Desain UI Aplikasi Mobile',
            ].contains((e.widget as Text).data),
          )
          .map((e) => (e.widget as Text).data)
          .toList();
      expect(cardTitlesTerbaru, [
        'Jadwal Kuliah Semester Ini',
        'Tugas Desain UI Aplikasi Mobile',
        'Pengantar Pemrograman Bergerak',
      ]);
    },
  );
}
