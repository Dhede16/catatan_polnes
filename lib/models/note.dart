import 'todo_item.dart';

class Note {
  final String id;
  final String title;
  final String content;
  final String category;
  final int colorValue;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPinned;
  final List<TodoItem> todoItems;

  const Note({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.colorValue,
    required this.createdAt,
    required this.updatedAt,
    this.isPinned = false,
    this.todoItems = const [],
  });

  /// Number of completed todo items.
  int get completedTodoCount => todoItems.where((t) => t.isDone).length;

  /// Total number of todo items.
  int get totalTodoCount => todoItems.length;

  /// Whether this note has any todo items.
  bool get hasTodos => todoItems.isNotEmpty;

  Note copyWith({
    String? id,
    String? title,
    String? content,
    String? category,
    int? colorValue,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPinned,
    List<TodoItem>? todoItems,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPinned: isPinned ?? this.isPinned,
      todoItems: todoItems ?? this.todoItems,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'colorValue': colorValue,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isPinned': isPinned,
      'todoItems': todoItems.map((t) => t.toJson()).toList(),
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    final rawTodos = json['todoItems'] as List<dynamic>?;
    return Note(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      category: json['category'] as String,
      colorValue: json['colorValue'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isPinned: json['isPinned'] as bool? ?? false,
      todoItems:
          rawTodos
              ?.map((t) => TodoItem.fromJson(t as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  static const List<String> categories = [
    'Semua',
    'Praktikum',
    'Kuliah',
    'Tugas',
    'Pribadi',
    'Lainnya',
  ];

  static const List<int> noteColors = [
    0xFFFFF9C4, // Soft Yellow (Notebook classic)
    0xFFE1F5FE, // Soft Blue
    0xFFE8F5E9, // Soft Green
    0xFFFCE4EC, // Soft Pink
    0xFFF3E5F5, // Soft Purple
    0xFFFFF3E0, // Soft Orange
  ];

  static List<Note> getInitialSampleNotes() {
    final now = DateTime.now();
    return [
      Note(
        id: '1',
        title: 'Pengantar Pemrograman Bergerak',
        content:
            'Materi Pertemuan 1:\n- Pengenalan Flutter & Dart SDK\n- Struktur folder proyek Flutter\n- State management dasar (Stateful & Stateless Widget)\n- Persiapan praktikum di lab komputer POLNES.',
        category: 'Praktikum',
        colorValue: 0xFFFFF9C4,
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
        isPinned: true,
      ),
      Note(
        id: '2',
        title: 'Tugas Desain UI Aplikasi Mobile',
        content:
            'Deadline: Minggu depan jam 23:59 WITA.\n1. Buat wireframe aplikasi notebook POLNES.\n2. Terapkan prinsip Material 3.\n3. Uji responsivitas pada perangkat Android.',
        category: 'Tugas',
        colorValue: 0xFFE1F5FE,
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
        isPinned: false,
      ),
      Note(
        id: '3',
        title: 'Jadwal Kuliah Semester Ini',
        content:
            'Senin: Pemrograman Perangkat Bergerak (08.00 - 11.30)\nSelasa: Basis Data Lanjut (10.00 - 12.00)\nKamis: Rekayasa Perangkat Lunak (13.00 - 16.00)',
        category: 'Kuliah',
        colorValue: 0xFFE8F5E9,
        createdAt: now.subtract(const Duration(hours: 5)),
        updatedAt: now.subtract(const Duration(hours: 5)),
        isPinned: false,
      ),
    ];
  }
}

enum NoteSortOption { terbaru, terlama, judulAZ, dipin }

extension NoteSortOptionExtension on NoteSortOption {
  String get label {
    switch (this) {
      case NoteSortOption.terbaru:
        return 'Terbaru';
      case NoteSortOption.terlama:
        return 'Terlama';
      case NoteSortOption.judulAZ:
        return 'Judul A-Z';
      case NoteSortOption.dipin:
        return 'Catatan yang Dipin';
    }
  }

  List<Note> sort(List<Note> notes) {
    final list = List<Note>.from(notes);
    switch (this) {
      case NoteSortOption.terbaru:
        list.sort((a, b) {
          final comp = b.updatedAt.compareTo(a.updatedAt);
          if (comp != 0) return comp;
          return b.id.compareTo(a.id);
        });
        break;
      case NoteSortOption.terlama:
        list.sort((a, b) {
          final comp = a.updatedAt.compareTo(b.updatedAt);
          if (comp != 0) return comp;
          return a.id.compareTo(b.id);
        });
        break;
      case NoteSortOption.judulAZ:
        list.sort((a, b) {
          final comp = a.title.toLowerCase().compareTo(b.title.toLowerCase());
          if (comp != 0) return comp;
          return b.updatedAt.compareTo(a.updatedAt);
        });
        break;
      case NoteSortOption.dipin:
        list.sort((a, b) {
          if (a.isPinned && !b.isPinned) return -1;
          if (!a.isPinned && b.isPinned) return 1;
          return b.updatedAt.compareTo(a.updatedAt);
        });
        break;
    }
    return list;
  }
}
