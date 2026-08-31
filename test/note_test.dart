import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:catatan_polnes/models/note.dart';
import 'package:catatan_polnes/services/note_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Note Model JSON Serialization', () {
    test('toJson and fromJson produce identical Note object', () {
      final now = DateTime(2026, 8, 28, 20, 0, 0);
      final note = Note(
        id: 'test-1',
        title: 'Judul Uji Coba',
        content: 'Isi konten catatan uji coba.',
        category: 'Praktikum',
        colorValue: 0xFFFFF9C4,
        createdAt: now,
        updatedAt: now,
        isPinned: true,
      );

      final json = note.toJson();
      expect(json['id'], 'test-1');
      expect(json['title'], 'Judul Uji Coba');
      expect(json['content'], 'Isi konten catatan uji coba.');
      expect(json['category'], 'Praktikum');
      expect(json['colorValue'], 0xFFFFF9C4);
      expect(json['createdAt'], now.toIso8601String());
      expect(json['updatedAt'], now.toIso8601String());
      expect(json['isPinned'], true);

      final reconstructedNote = Note.fromJson(json);
      expect(reconstructedNote.id, note.id);
      expect(reconstructedNote.title, note.title);
      expect(reconstructedNote.content, note.content);
      expect(reconstructedNote.category, note.category);
      expect(reconstructedNote.colorValue, note.colorValue);
      expect(reconstructedNote.createdAt, note.createdAt);
      expect(reconstructedNote.updatedAt, note.updatedAt);
      expect(reconstructedNote.isPinned, note.isPinned);
    });

    test('fromJson handles default isPinned when null or omitted', () {
      final json = {
        'id': 'test-2',
        'title': 'Tanpa Pin',
        'content': 'Konten tanpa pin',
        'category': 'Kuliah',
        'colorValue': 0xFFE1F5FE,
        'createdAt': DateTime(2026, 1, 1).toIso8601String(),
        'updatedAt': DateTime(2026, 1, 1).toIso8601String(),
      };

      final note = Note.fromJson(json);
      expect(note.isPinned, false);
    });
  });

  group('NoteStorage Persistence', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('loadNotes returns sample initial notes on first launch', () async {
      final storage = NoteStorage();
      final notes = await storage.loadNotes();

      expect(notes.isNotEmpty, true);
      expect(notes.length, 3);
      expect(notes.first.title, 'Pengantar Pemrograman Bergerak');
    });

    test('saveNotes persists notes and loadNotes reads them back', () async {
      final storage = NoteStorage();
      final sampleNote = Note(
        id: 'saved-1',
        title: 'Catatan Tersimpan',
        content: 'Konten tersimpan di storage',
        category: 'Tugas',
        colorValue: 0xFFE8F5E9,
        createdAt: DateTime(2026, 8, 28),
        updatedAt: DateTime(2026, 8, 28),
        isPinned: false,
      );

      await storage.saveNotes([sampleNote]);

      // Create new storage instance to simulate fresh app restart
      final newStorageInstance = NoteStorage();
      final loadedNotes = await newStorageInstance.loadNotes();

      expect(loadedNotes.length, 1);
      expect(loadedNotes.first.id, 'saved-1');
      expect(loadedNotes.first.title, 'Catatan Tersimpan');
    });

    test('clearNotes removes all stored notes', () async {
      final storage = NoteStorage();
      await storage.saveNotes([
        Note(
          id: 'temp',
          title: 'Temporary',
          content: 'Will be cleared',
          category: 'Pribadi',
          colorValue: 0xFFFCE4EC,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ]);

      await storage.clearNotes();

      // After clearing, loading notes will re-initialize default sample notes
      final loadedNotes = await storage.loadNotes();
      expect(loadedNotes.length, 3);
    });
  });
}
