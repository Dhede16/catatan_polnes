import 'package:flutter/material.dart';
import '../models/note.dart';
import 'note_editor_screen.dart';

class NoteDetailScreen extends StatefulWidget {
  final Note note;
  final ValueChanged<Note> onNoteUpdated;
  final VoidCallback onNoteDeleted;

  const NoteDetailScreen({
    super.key,
    required this.note,
    required this.onNoteUpdated,
    required this.onNoteDeleted,
  });

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late Note _currentNote;

  @override
  void initState() {
    super.initState();
    _currentNote = widget.note;
  }

  String _formatFullDate(DateTime date) {
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    final day = date.day.toString().padLeft(2, '0');
    final month = months[date.month - 1];
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day $month $year, $hour:$minute WITA';
  }

  Future<void> _handleEdit() async {
    final updated = await Navigator.push<Note>(
      context,
      MaterialPageRoute(builder: (_) => NoteEditorScreen(note: _currentNote)),
    );

    if (updated != null && mounted) {
      setState(() {
        _currentNote = updated;
      });
      widget.onNoteUpdated(updated);
    }
  }

  Future<void> _handleDelete() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Catatan'),
        content: Text(
          'Apakah Anda yakin ingin menghapus catatan "${_currentNote.title}"?',
        ),
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

    if (shouldDelete == true && mounted) {
      widget.onNoteDeleted();
      Navigator.pop(context);
    }
  }

  void _togglePin() {
    final updated = _currentNote.copyWith(isPinned: !_currentNote.isPinned);
    setState(() {
      _currentNote = updated;
    });
    widget.onNoteUpdated(updated);
  }

  @override
  Widget build(BuildContext context) {
    final cardBgColor = Color(_currentNote.colorValue);

    return Scaffold(
      backgroundColor: cardBgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: _currentNote.isPinned ? 'Lepas Pin' : 'Pin Catatan',
            icon: Icon(
              _currentNote.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
              color: _currentNote.isPinned ? Colors.deepPurple : Colors.black87,
            ),
            onPressed: _togglePin,
          ),
          IconButton(
            tooltip: 'Edit Catatan',
            icon: const Icon(Icons.edit_outlined, color: Colors.black87),
            onPressed: _handleEdit,
          ),
          IconButton(
            tooltip: 'Hapus Catatan',
            icon: const Icon(Icons.delete_outline, color: Colors.black87),
            onPressed: _handleDelete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category & status badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _currentNote.category,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                if (_currentNote.isPinned) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withAlpha(30),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.push_pin,
                          size: 14,
                          color: Colors.deepPurple,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Disematkan',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 14),

            // Title
            SelectableText(
              _currentNote.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 8),

            // Dates metadata
            Text(
              'Diperbarui: ${_formatFullDate(_currentNote.updatedAt)}',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const Divider(height: 28, thickness: 1),

            // Content
            SelectableText(
              _currentNote.content.isEmpty
                  ? '(Catatan tidak memiliki isi teks)'
                  : _currentNote.content,
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: _currentNote.content.isEmpty
                    ? Colors.black38
                    : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
