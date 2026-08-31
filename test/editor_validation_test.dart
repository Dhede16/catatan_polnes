import 'package:catatan_polnes/screens/note_editor_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Editor Validation & Experience Tests', () {
    testWidgets(
      'Constants maxTitleLength dan maxContentLength terdefinisi dengan benar',
      (WidgetTester tester) async {
        expect(NoteEditorScreen.maxTitleLength, 50);
        expect(NoteEditorScreen.maxContentLength, 2000);
      },
    );

    testWidgets(
      'Editor menampilkan batas & penghitung karakter untuk judul dan isi serta autofocus',
      (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: NoteEditorScreen()));

        // Verifikasi tombol Batal ada
        expect(find.byKey(const Key('cancel_note_button')), findsOneWidget);

        // Verifikasi penghitung karakter awal
        expect(find.text('0/50'), findsOneWidget);
        expect(find.text('0/2000'), findsOneWidget);

        // Verifikasi TextField judul memegang autofocus
        final TextField titleField = tester.widget<TextField>(
          find.byKey(const Key('note_title_field')),
        );
        expect(titleField.autofocus, isTrue);
        expect(titleField.maxLength, 50);

        final TextField contentField = tester.widget<TextField>(
          find.byKey(const Key('note_content_field')),
        );
        expect(contentField.maxLength, 2000);
      },
    );

    testWidgets('Mengisi judul dan isi memperbarui jumlah karakter', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: NoteEditorScreen()));

      await tester.enterText(
        find.byKey(const Key('note_title_field')),
        'Judul Tes',
      );
      await tester.pump();

      expect(find.text('9/50'), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('note_content_field')),
        'Isi catatan tes',
      );
      await tester.pump();

      expect(find.text('15/2000'), findsOneWidget);
    });

    testWidgets(
      'Menekan tombol Batal tanpa perubahan langsung keluar tanpa dialog',
      (WidgetTester tester) async {
        bool popped = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Navigator(
              onPopPage: (route, result) {
                popped = true;
                return route.didPop(result);
              },
              pages: const [
                MaterialPage(child: Text('Home Screen')),
                MaterialPage(child: NoteEditorScreen()),
              ],
            ),
          ),
        );

        expect(find.byType(NoteEditorScreen), findsOneWidget);

        // Tekan tombol Batal
        await tester.tap(find.byKey(const Key('cancel_note_button')));
        await tester.pumpAndSettle();

        expect(popped, isTrue);
        expect(find.byType(NoteEditorScreen), findsNothing);
      },
    );

    testWidgets(
      'Menekan tombol Batal dengan perubahan memicu dialog konfirmasi',
      (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: NoteEditorScreen()));

        // Masukkan teks ke judul
        await tester.enterText(
          find.byKey(const Key('note_title_field')),
          'Perubahan baru',
        );
        await tester.pump();

        // Tekan tombol Batal
        await tester.tap(find.byKey(const Key('cancel_note_button')));
        await tester.pumpAndSettle();

        // Dialog konfirmasi harus muncul
        expect(find.text('Perubahan Belum Disimpan'), findsOneWidget);
        expect(
          find.text(
            'Apakah Anda yakin ingin keluar tanpa menyimpan perubahan?',
          ),
          findsOneWidget,
        );

        // Menekan 'Batal' di dialog membatalkan pop (tetap di editor)
        await tester.tap(find.text('Batal').last);
        await tester.pumpAndSettle();

        expect(find.byType(NoteEditorScreen), findsOneWidget);
        expect(find.text('Perubahan Belum Disimpan'), findsNothing);
      },
    );

    testWidgets('Memilih Keluar pada dialog konfirmasi menutup editor', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: NoteEditorScreen()));

      // Masukkan teks ke isi
      await tester.enterText(
        find.byKey(const Key('note_content_field')),
        'Konten yang diubah',
      );
      await tester.pump();

      // Tekan tombol Batal
      await tester.tap(find.byKey(const Key('cancel_note_button')));
      await tester.pumpAndSettle();

      expect(find.text('Perubahan Belum Disimpan'), findsOneWidget);

      // Tekan 'Keluar' pada dialog konfirmasi
      await tester.tap(find.text('Keluar'));
      await tester.pumpAndSettle();

      expect(find.byType(NoteEditorScreen), findsNothing);
    });
  });
}
