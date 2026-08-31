import 'package:flutter/material.dart';
import 'models/note.dart';
import 'screens/note_detail_screen.dart';
import 'screens/note_editor_screen.dart';
import 'services/note_storage.dart';
import 'services/theme_storage.dart';
import 'widgets/category_chip.dart';
import 'widgets/note_card.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  final ThemeStorage? themeStorage;
  final ThemeMode? initialThemeMode;

  const MyApp({super.key, this.themeStorage, this.initialThemeMode});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final ThemeStorage _themeStorage;
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeStorage = widget.themeStorage ?? ThemeStorage();
    _themeMode = widget.initialThemeMode ?? ThemeMode.light;
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    if (widget.initialThemeMode == null) {
      final savedTheme = await _themeStorage.loadThemeMode();
      if (mounted) {
        setState(() {
          _themeMode = savedTheme;
        });
      }
    }
  }

  void _toggleTheme() {
    final newMode = _themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    setState(() {
      _themeMode = newMode;
    });
    _themeStorage.saveThemeMode(newMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catatan POLNES',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          backgroundColor: Color(0xFF1E1E1E),
          foregroundColor: Colors.white,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          color: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: MyHomePage(title: 'Catatan POLNES', onToggleTheme: _toggleTheme),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  final VoidCallback? onToggleTheme;

  const MyHomePage({super.key, required this.title, this.onToggleTheme});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final NoteStorage _noteStorage = NoteStorage();
  List<Note> _notes = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedCategory = 'Semua';
  NoteSortOption _selectedSort = NoteSortOption.terbaru;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final notes = await _noteStorage.loadNotes();
    if (mounted) {
      setState(() {
        _notes = notes;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Note> get _filteredNotes {
    final filtered = _notes.where((note) {
      final matchesSearch =
          note.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          note.content.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory =
          _selectedCategory == 'Semua' ||
          note.category.toLowerCase() == _selectedCategory.toLowerCase();
      return matchesSearch && matchesCategory;
    }).toList();
    return _selectedSort.sort(filtered);
  }

  void _addNote(Note note) {
    setState(() {
      _notes.insert(0, note);
    });
    _noteStorage.saveNotes(_notes);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Catatan berhasil ditambahkan.')),
    );
  }

  void _updateNote(Note note) {
    setState(() {
      final index = _notes.indexWhere((n) => n.id == note.id);
      if (index != -1) {
        _notes[index] = note;
      }
    });
    _noteStorage.saveNotes(_notes);
  }

  void _deleteNote(String id) {
    setState(() {
      _notes.removeWhere((n) => n.id == id);
    });
    _noteStorage.saveNotes(_notes);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Catatan telah dihapus.')));
  }

  void _togglePin(Note note) {
    _updateNote(note.copyWith(isPinned: !note.isPinned));
  }

  Future<void> _openCreateNote() async {
    final newNote = await Navigator.push<Note>(
      context,
      MaterialPageRoute(builder: (_) => const NoteEditorScreen()),
    );

    if (newNote != null) {
      _addNote(newNote);
    }
  }

  void _openNoteDetail(Note note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NoteDetailScreen(
          note: note,
          onNoteUpdated: _updateNote,
          onNoteDeleted: () => _deleteNote(note.id),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(Note note) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Catatan'),
        content: Text('Yakin ingin menghapus catatan "${note.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      _deleteNote(note.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final displayedNotes = _filteredNotes;

    final headerBgColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final searchFillColor = isDarkMode
        ? const Color(0xFF2A2A2A)
        : const Color(0xFFF1F3F5);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.menu_book_rounded,
                color: theme.colorScheme.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Buku Catatan Digital POLNES',
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          PopupMenuButton<NoteSortOption>(
            key: const Key('sort_menu_button'),
            icon: const Icon(Icons.sort_rounded),
            tooltip: 'Urutkan Catatan',
            initialValue: _selectedSort,
            onSelected: (NoteSortOption option) {
              setState(() {
                _selectedSort = option;
              });
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                key: const Key('sort_option_terbaru'),
                value: NoteSortOption.terbaru,
                child: Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 20,
                      color: _selectedSort == NoteSortOption.terbaru
                          ? theme.colorScheme.primary
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Terbaru',
                        style: TextStyle(
                          fontWeight: _selectedSort == NoteSortOption.terbaru
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: _selectedSort == NoteSortOption.terbaru
                              ? theme.colorScheme.primary
                              : null,
                        ),
                      ),
                    ),
                    if (_selectedSort == NoteSortOption.terbaru)
                      Icon(
                        Icons.check_rounded,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                  ],
                ),
              ),
              PopupMenuItem(
                key: const Key('sort_option_terlama'),
                value: NoteSortOption.terlama,
                child: Row(
                  children: [
                    Icon(
                      Icons.history_rounded,
                      size: 20,
                      color: _selectedSort == NoteSortOption.terlama
                          ? theme.colorScheme.primary
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Terlama',
                        style: TextStyle(
                          fontWeight: _selectedSort == NoteSortOption.terlama
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: _selectedSort == NoteSortOption.terlama
                              ? theme.colorScheme.primary
                              : null,
                        ),
                      ),
                    ),
                    if (_selectedSort == NoteSortOption.terlama)
                      Icon(
                        Icons.check_rounded,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                  ],
                ),
              ),
              PopupMenuItem(
                key: const Key('sort_option_judul'),
                value: NoteSortOption.judulAZ,
                child: Row(
                  children: [
                    Icon(
                      Icons.sort_by_alpha_rounded,
                      size: 20,
                      color: _selectedSort == NoteSortOption.judulAZ
                          ? theme.colorScheme.primary
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Judul A-Z',
                        style: TextStyle(
                          fontWeight: _selectedSort == NoteSortOption.judulAZ
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: _selectedSort == NoteSortOption.judulAZ
                              ? theme.colorScheme.primary
                              : null,
                        ),
                      ),
                    ),
                    if (_selectedSort == NoteSortOption.judulAZ)
                      Icon(
                        Icons.check_rounded,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                  ],
                ),
              ),
              PopupMenuItem(
                key: const Key('sort_option_dipin'),
                value: NoteSortOption.dipin,
                child: Row(
                  children: [
                    Icon(
                      Icons.push_pin_rounded,
                      size: 20,
                      color: _selectedSort == NoteSortOption.dipin
                          ? theme.colorScheme.primary
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Catatan yang Dipin',
                        style: TextStyle(
                          fontWeight: _selectedSort == NoteSortOption.dipin
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: _selectedSort == NoteSortOption.dipin
                              ? theme.colorScheme.primary
                              : null,
                        ),
                      ),
                    ),
                    if (_selectedSort == NoteSortOption.dipin)
                      Icon(
                        Icons.check_rounded,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            key: const Key('theme_toggle_button'),
            tooltip: isDarkMode
                ? 'Beralih ke Tema Terang'
                : 'Beralih ke Tema Gelap',
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode_outlined,
            ),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar & Note Count header
          Container(
            color: headerBgColor,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari catatan di POLNES...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: searchFillColor,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                ),
                const SizedBox(height: 12),
                // Category Filter Chips
                SizedBox(
                  height: 36,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: Note.categories.length,
                    itemBuilder: (context, index) {
                      final category = Note.categories[index];
                      return CategoryChip(
                        label: category,
                        isSelected: _selectedCategory == category,
                        onSelected: () {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Notes List / Grid
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : displayedNotes.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.note_alt_outlined,
                            size: 64,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isNotEmpty ||
                                    _selectedCategory != 'Semua'
                                ? 'Tidak ada catatan yang cocok'
                                : 'Belum ada catatan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _searchQuery.isNotEmpty ||
                                    _selectedCategory != 'Semua'
                                ? 'Coba ubah kata kunci pencarian atau kategori filter.'
                                : 'Tekan tombol + di bawah untuk membuat catatan baru.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
                      return GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: 0.85,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: displayedNotes.length,
                        itemBuilder: (context, index) {
                          final note = displayedNotes[index];
                          return NoteCard(
                            note: note,
                            onTap: () => _openNoteDetail(note),
                            onTogglePin: () => _togglePin(note),
                            onDelete: () => _confirmDelete(note),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateNote,
        tooltip: 'Tambah Catatan Baru',
        icon: const Icon(Icons.add),
        label: const Text(
          'Catatan Baru',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
