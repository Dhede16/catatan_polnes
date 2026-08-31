import 'package:flutter/material.dart';
import '../models/note.dart';
import '../models/todo_item.dart';

class NoteEditorScreen extends StatefulWidget {
  static const int maxTitleLength = 50;
  static const int maxContentLength = 2000;

  final Note? note;

  const NoteEditorScreen({super.key, this.note});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late String _selectedCategory;
  late int _selectedColorValue;
  late bool _isPinned;
  late List<TodoItem> _todoItems;
  final Map<String, TextEditingController> _todoTextControllers = {};

  late final String _initialTitle;
  late final String _initialContent;
  late final String _initialCategory;
  late final int _initialColorValue;
  late final bool _initialIsPinned;
  late final List<TodoItem> _initialTodoItems;

  bool get _isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();
    _initialTitle = widget.note?.title ?? '';
    _initialContent = widget.note?.content ?? '';
    _initialCategory = widget.note?.category ?? 'Praktikum';
    _initialColorValue = widget.note?.colorValue ?? Note.noteColors.first;
    _initialIsPinned = widget.note?.isPinned ?? false;
    _initialTodoItems = List<TodoItem>.from(widget.note?.todoItems ?? []);

    _titleController = TextEditingController(text: _initialTitle);
    _contentController = TextEditingController(text: _initialContent);
    _selectedCategory = _initialCategory;
    _selectedColorValue = _initialColorValue;
    _isPinned = _initialIsPinned;
    _todoItems = List<TodoItem>.from(_initialTodoItems);

    for (final item in _todoItems) {
      final controller = TextEditingController(text: item.text);
      controller.addListener(_onFieldChanged);
      _todoTextControllers[item.id] = controller;
    }

    _titleController.addListener(_onFieldChanged);
    _contentController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    setState(() {});
  }

  bool get _hasUnsavedChanges {
    if (_titleController.text != _initialTitle) return true;
    if (_contentController.text != _initialContent) return true;
    if (_selectedCategory != _initialCategory) return true;
    if (_selectedColorValue != _initialColorValue) return true;
    if (_isPinned != _initialIsPinned) return true;
    if (_todoItems.length != _initialTodoItems.length) return true;
    for (int i = 0; i < _todoItems.length; i++) {
      if (_todoItems[i].id != _initialTodoItems[i].id) return true;
      final currentText =
          _todoTextControllers[_todoItems[i].id]?.text ?? _todoItems[i].text;
      if (currentText != _initialTodoItems[i].text) return true;
      if (_todoItems[i].isDone != _initialTodoItems[i].isDone) return true;
    }
    return false;
  }

  @override
  void dispose() {
    _titleController.removeListener(_onFieldChanged);
    _contentController.removeListener(_onFieldChanged);
    _titleController.dispose();
    _contentController.dispose();
    for (final controller in _todoTextControllers.values) {
      controller.removeListener(_onFieldChanged);
      controller.dispose();
    }
    super.dispose();
  }

  Future<bool> _showUnsavedChangesDialog() async {
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Perubahan Belum Disimpan'),
        content: const Text(
          'Apakah Anda yakin ingin keluar tanpa menyimpan perubahan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    return shouldPop ?? false;
  }

  Future<void> _onCancel() async {
    if (_hasUnsavedChanges) {
      final shouldPop = await _showUnsavedChangesDialog();
      if (shouldPop && mounted) {
        Navigator.pop(context);
      }
    } else {
      Navigator.pop(context);
    }
  }

  void _saveNote() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty && _todoItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Judul, isi, atau checklist tidak boleh kosong.'),
        ),
      );
      return;
    }

    final finalTitle = title.isEmpty ? 'Tanpa Judul' : title;
    final now = DateTime.now();

    // Sync todo text from controllers
    final syncedTodos = _todoItems
        .map((item) {
          final controller = _todoTextControllers[item.id];
          return item.copyWith(text: controller?.text.trim() ?? item.text);
        })
        .where((item) => item.text.isNotEmpty)
        .toList();

    final savedNote = Note(
      id: widget.note?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: finalTitle,
      content: content,
      category: _selectedCategory,
      colorValue: _selectedColorValue,
      createdAt: widget.note?.createdAt ?? now,
      updatedAt: now,
      isPinned: _isPinned,
      todoItems: syncedTodos,
    );

    Navigator.pop(context, savedNote);
  }

  @override
  Widget build(BuildContext context) {
    final availableCategories = Note.categories
        .where((c) => c != 'Semua')
        .toList();

    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _showUnsavedChangesDialog();
        if (shouldPop && mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: Color(_selectedColorValue),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            key: const Key('cancel_note_button'),
            tooltip: 'Batal',
            icon: const Icon(Icons.close, color: Colors.black87),
            onPressed: _onCancel,
          ),
          title: Text(
            _isEditing ? 'Edit Catatan' : 'Catatan Baru',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              tooltip: _isPinned ? 'Lepas Pin' : 'Pin Catatan',
              icon: Icon(
                _isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                color: _isPinned ? Colors.deepPurple : Colors.black87,
              ),
              onPressed: () {
                setState(() {
                  _isPinned = !_isPinned;
                });
              },
            ),
            IconButton(
              key: const Key('save_note_button'),
              tooltip: 'Simpan',
              icon: const Icon(Icons.check, color: Colors.black87),
              onPressed: _saveNote,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category & Color Selection row
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(160),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black.withAlpha(20)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.folder_outlined,
                      size: 20,
                      color: Colors.black54,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Kategori:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCategory,
                          isDense: true,
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.black54,
                          ),
                          items: availableCategories.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(
                                category,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedCategory = val;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Color Picker Palette
              SizedBox(
                height: 38,
                child: Row(
                  children: [
                    const Text(
                      'Warna Kertas: ',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: Note.noteColors.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final colorVal = Note.noteColors[index];
                          final isSelected = _selectedColorValue == colorVal;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedColorValue = colorVal;
                              });
                            },
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Color(colorVal),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.deepPurple
                                      : Colors.black26,
                                  width: isSelected ? 2.5 : 1,
                                ),
                                boxShadow: [
                                  if (isSelected)
                                    BoxShadow(
                                      color: Colors.deepPurple.withAlpha(60),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    ),
                                ],
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      size: 16,
                                      color: Colors.deepPurple,
                                    )
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 28, thickness: 1),

              // Title Field
              TextField(
                key: const Key('note_title_field'),
                controller: _titleController,
                autofocus: true,
                maxLength: NoteEditorScreen.maxTitleLength,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                decoration: const InputDecoration(
                  hintText: 'Judul Catatan...',
                  hintStyle: TextStyle(
                    color: Colors.black38,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  border: InputBorder.none,
                  counterStyle: TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              TextField(
                key: const Key('note_content_field'),
                controller: _contentController,
                maxLines: null,
                minLines: 8,
                maxLength: NoteEditorScreen.maxContentLength,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Colors.black87,
                ),
                decoration: const InputDecoration(
                  hintText: 'Tuliskan catatanmu di sini...',
                  hintStyle: TextStyle(color: Colors.black38, fontSize: 15),
                  border: InputBorder.none,
                  counterStyle: TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Checklist Section
              _buildChecklistSection(),
            ],
          ),
        ),
      ),
    );
  }

  void _addTodoItem() {
    final newItem = TodoItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      text: '',
    );
    final controller = TextEditingController();
    controller.addListener(_onFieldChanged);
    setState(() {
      _todoItems.add(newItem);
      _todoTextControllers[newItem.id] = controller;
    });
  }

  void _removeTodoItem(String id) {
    setState(() {
      _todoItems.removeWhere((item) => item.id == id);
      _todoTextControllers[id]?.removeListener(_onFieldChanged);
      _todoTextControllers[id]?.dispose();
      _todoTextControllers.remove(id);
    });
  }

  void _toggleTodoItem(String id) {
    setState(() {
      final index = _todoItems.indexWhere((item) => item.id == id);
      if (index != -1) {
        _todoItems[index] = _todoItems[index].copyWith(
          isDone: !_todoItems[index].isDone,
        );
      }
    });
  }

  Widget _buildChecklistSection() {
    final completedCount = _todoItems.where((item) => item.isDone).length;
    final totalCount = _todoItems.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 20, thickness: 1),
        // Header
        Row(
          children: [
            const Icon(
              Icons.checklist_rounded,
              size: 20,
              color: Colors.black54,
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Checklist Tugas',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: _addTodoItem,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Tambah', style: TextStyle(fontSize: 13)),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),

        // Progress
        if (totalCount > 0) ...[
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: totalCount > 0 ? completedCount / totalCount : 0,
              minHeight: 6,
              backgroundColor: Colors.black.withAlpha(20),
              valueColor: AlwaysStoppedAnimation<Color>(
                completedCount == totalCount ? Colors.green : Colors.deepPurple,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$completedCount/$totalCount tugas selesai',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],

        // Todo items list
        const SizedBox(height: 8),
        ..._todoItems.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 32,
                  height: 32,
                  child: Checkbox(
                    value: item.isDone,
                    onChanged: (_) => _toggleTodoItem(item.id),
                    activeColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: TextField(
                    controller: _todoTextControllers[item.id],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      decoration: item.isDone
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      decorationColor: Colors.black54,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Tulis item tugas...',
                      hintStyle: TextStyle(color: Colors.black38, fontSize: 14),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 6),
                    ),
                  ),
                ),
                IconButton(
                  iconSize: 18,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 28,
                    minHeight: 28,
                  ),
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.close, color: Colors.black38),
                  tooltip: 'Hapus item',
                  onPressed: () => _removeTodoItem(item.id),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
