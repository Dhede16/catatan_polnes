import 'package:flutter_test/flutter_test.dart';
import 'package:catatan_polnes/models/note.dart';

void main() {
  group('NoteSortOption Unit Tests', () {
    final now = DateTime(2026, 8, 31, 10, 0, 0);

    final noteA = Note(
      id: '1',
      title: 'Belajar Flutter',
      content: 'Isi A',
      category: 'Kuliah',
      colorValue: 0xFFFFF9C4,
      createdAt: now.subtract(const Duration(days: 3)),
      updatedAt: now.subtract(const Duration(days: 3)),
      isPinned: false,
    );

    final noteB = Note(
      id: '2',
      title: 'Aplikasi Mobile POLNES',
      content: 'Isi B',
      category: 'Praktikum',
      colorValue: 0xFFE1F5FE,
      createdAt: now.subtract(const Duration(days: 1)),
      updatedAt: now.subtract(const Duration(days: 1)),
      isPinned: false,
    );

    final noteC = Note(
      id: '3',
      title: 'Catatan Penting',
      content: 'Isi C',
      category: 'Tugas',
      colorValue: 0xFFE8F5E9,
      createdAt: now.subtract(const Duration(days: 2)),
      updatedAt: now.subtract(const Duration(days: 2)),
      isPinned: true,
    );

    final notes = [noteA, noteB, noteC];

    test('NoteSortOption labels are correct', () {
      expect(NoteSortOption.terbaru.label, 'Terbaru');
      expect(NoteSortOption.terlama.label, 'Terlama');
      expect(NoteSortOption.judulAZ.label, 'Judul A-Z');
      expect(NoteSortOption.dipin.label, 'Catatan yang Dipin');
    });

    test('Sort by Terbaru sorts by updatedAt descending', () {
      final sorted = NoteSortOption.terbaru.sort(notes);
      expect(sorted.map((n) => n.id).toList(), ['2', '3', '1']);
    });

    test('Sort by Terlama sorts by updatedAt ascending', () {
      final sorted = NoteSortOption.terlama.sort(notes);
      expect(sorted.map((n) => n.id).toList(), ['1', '3', '2']);
    });

    test('Sort by Judul A-Z sorts by title alphabetically', () {
      final sorted = NoteSortOption.judulAZ.sort(notes);
      // 'Aplikasi Mobile POLNES' -> 'Belajar Flutter' -> 'Catatan Penting'
      expect(sorted.map((n) => n.id).toList(), ['2', '1', '3']);
    });

    test('Sort by Dipin puts pinned notes first', () {
      final sorted = NoteSortOption.dipin.sort(notes);
      // noteC (isPinned = true) should come first, then noteB (1 day ago), then noteA (3 days ago)
      expect(sorted.map((n) => n.id).toList(), ['3', '2', '1']);
    });
  });
}
