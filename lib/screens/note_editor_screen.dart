import 'package:flutter/material.dart';
import '../models/note.dart';
import '../models/todo_item.dart';

class NoteEditorScreen extends StatefulWidget {
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

  bool get _isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(
      text: widget.note?.content ?? '',
    );
    _selectedCategory = widget.note?.category ?? 'Praktikum';
    _selectedColorValue = widget.note?.colorValue ?? Note.noteColors.first;
    _isPinned = widget.note?.isPinned ?? false;
    _todoItems = List<TodoItem>.from(widget.note?.todoItems ?? []);
    for (final item in _todoItems) {
      _todoTextControllers[item.id] = TextEditingController(text: item.text);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    for (final controller in _todoTextControllers.values) {
      controller.dispose();
    }
    super.dispose();
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

    return Scaffold(
      backgroundColor: Color(_selectedColorValue),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
              controller: _titleController,
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
              ),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: _contentController,
              maxLines: null,
              minLines: 8,
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Colors.black87,
              ),
              decoration: const InputDecoration(
                hintText: 'Tuliskan catatanmu di sini...',
                hintStyle: TextStyle(color: Colors.black38, fontSize: 15),
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 12),

            // Checklist Section
            _buildChecklistSection(),
          ],
        ),
      ),
    );
  }

  void _addTodoItem() {
    final newItem = TodoItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      text: '',
    );
    setState(() {
      _todoItems.add(newItem);
      _todoTextControllers[newItem.id] = TextEditingController();
    });
  }

  void _removeTodoItem(String id) {
    setState(() {
      _todoItems.removeWhere((item) => item.id == id);
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
