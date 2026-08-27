class Note {
  final String id;
  final String title;
  final String content;
  final String category;
  final int colorValue;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPinned;

  const Note({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.colorValue,
    required this.createdAt,
    required this.updatedAt,
    this.isPinned = false,
  });

  Note copyWith({
    String? id,
    String? title,
    String? content,
    String? category,
    int? colorValue,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPinned,
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
