import 'package:flutter_test/flutter_test.dart';
import 'package:catatan_polnes/models/todo_item.dart';
import 'package:catatan_polnes/models/note.dart';

void main() {
  group('TodoItem Model', () {
    test('toJson and fromJson produce identical TodoItem', () {
      const item = TodoItem(id: 'todo-1', text: 'Buat wireframe', isDone: true);

      final json = item.toJson();
      expect(json['id'], 'todo-1');
      expect(json['text'], 'Buat wireframe');
      expect(json['isDone'], true);

      final restored = TodoItem.fromJson(json);
      expect(restored.id, item.id);
      expect(restored.text, item.text);
      expect(restored.isDone, item.isDone);
    });

    test('fromJson defaults isDone to false when null', () {
      final json = {'id': 'todo-2', 'text': 'Item tanpa status'};

      final item = TodoItem.fromJson(json);
      expect(item.isDone, false);
    });

    test('copyWith creates modified copy', () {
      const item = TodoItem(id: 'todo-3', text: 'Original', isDone: false);

      final toggled = item.copyWith(isDone: true);
      expect(toggled.isDone, true);
      expect(toggled.text, 'Original');
      expect(toggled.id, 'todo-3');

      final renamed = item.copyWith(text: 'Updated');
      expect(renamed.text, 'Updated');
      expect(renamed.isDone, false);
    });
  });

  group('Note with TodoItems', () {
    test('toJson and fromJson preserve todoItems', () {
      final now = DateTime(2026, 8, 31, 10, 0, 0);
      final note = Note(
        id: 'note-todo-1',
        title: 'Tugas Checklist',
        content: 'Deskripsi tugas',
        category: 'Tugas',
        colorValue: 0xFFE1F5FE,
        createdAt: now,
        updatedAt: now,
        todoItems: const [
          TodoItem(id: 't1', text: 'Item 1', isDone: true),
          TodoItem(id: 't2', text: 'Item 2', isDone: false),
          TodoItem(id: 't3', text: 'Item 3', isDone: true),
        ],
      );

      final json = note.toJson();
      final restored = Note.fromJson(json);

      expect(restored.todoItems.length, 3);
      expect(restored.todoItems[0].id, 't1');
      expect(restored.todoItems[0].text, 'Item 1');
      expect(restored.todoItems[0].isDone, true);
      expect(restored.todoItems[1].isDone, false);
      expect(restored.todoItems[2].isDone, true);
    });

    test('helper getters compute correctly', () {
      final now = DateTime(2026, 8, 31);
      final note = Note(
        id: 'note-todo-2',
        title: 'Test Getters',
        content: '',
        category: 'Praktikum',
        colorValue: 0xFFFFF9C4,
        createdAt: now,
        updatedAt: now,
        todoItems: const [
          TodoItem(id: 'a', text: 'A', isDone: true),
          TodoItem(id: 'b', text: 'B', isDone: false),
          TodoItem(id: 'c', text: 'C', isDone: true),
          TodoItem(id: 'd', text: 'D', isDone: false),
          TodoItem(id: 'e', text: 'E', isDone: true),
        ],
      );

      expect(note.hasTodos, true);
      expect(note.totalTodoCount, 5);
      expect(note.completedTodoCount, 3);
    });

    test('note without todoItems has correct defaults', () {
      final now = DateTime(2026, 8, 31);
      final note = Note(
        id: 'note-no-todo',
        title: 'Catatan Biasa',
        content: 'Tanpa checklist',
        category: 'Kuliah',
        colorValue: 0xFFE8F5E9,
        createdAt: now,
        updatedAt: now,
      );

      expect(note.hasTodos, false);
      expect(note.totalTodoCount, 0);
      expect(note.completedTodoCount, 0);
      expect(note.todoItems, isEmpty);
    });

    test('fromJson backward compatible without todoItems key', () {
      final json = {
        'id': 'old-note',
        'title': 'Catatan Lama',
        'content': 'Konten lama',
        'category': 'Pribadi',
        'colorValue': 0xFFFCE4EC,
        'createdAt': DateTime(2026, 1, 1).toIso8601String(),
        'updatedAt': DateTime(2026, 1, 1).toIso8601String(),
        'isPinned': false,
      };

      final note = Note.fromJson(json);
      expect(note.todoItems, isEmpty);
      expect(note.hasTodos, false);
    });

    test('copyWith updates todoItems', () {
      final now = DateTime(2026, 8, 31);
      final note = Note(
        id: 'copy-test',
        title: 'Original',
        content: '',
        category: 'Tugas',
        colorValue: 0xFFFFF9C4,
        createdAt: now,
        updatedAt: now,
        todoItems: const [TodoItem(id: 'x', text: 'X', isDone: false)],
      );

      final updated = note.copyWith(
        todoItems: const [
          TodoItem(id: 'x', text: 'X', isDone: true),
          TodoItem(id: 'y', text: 'Y', isDone: false),
        ],
      );

      expect(updated.todoItems.length, 2);
      expect(updated.todoItems[0].isDone, true);
      expect(updated.todoItems[1].text, 'Y');
      // Original unchanged
      expect(note.todoItems.length, 1);
      expect(note.todoItems[0].isDone, false);
    });
  });
}
