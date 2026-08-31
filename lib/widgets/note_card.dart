import 'package:flutter/material.dart';
import '../models/note.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onTogglePin;
  final VoidCallback onDelete;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onTogglePin,
    required this.onDelete,
  });

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final day = date.day.toString().padLeft(2, '0');
    final month = months[date.month - 1];
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day $month $year, $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final cardBgColor = Color(note.colorValue);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.black.withAlpha(20), width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      color: cardBgColor,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            // Notebook top decorative strip
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 6,
              child: Container(color: Colors.black.withAlpha(25)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category tag & Pin icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(20),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            note.category,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            iconSize: 18,
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                            constraints: const BoxConstraints(
                              minWidth: 28,
                              minHeight: 28,
                            ),
                            tooltip: note.isPinned
                                ? 'Lepas Pin'
                                : 'Pin Catatan',
                            icon: Icon(
                              note.isPinned
                                  ? Icons.push_pin
                                  : Icons.push_pin_outlined,
                              color: note.isPinned
                                  ? Colors.deepPurple
                                  : Colors.black54,
                            ),
                            onPressed: onTogglePin,
                          ),
                          IconButton(
                            iconSize: 18,
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                            constraints: const BoxConstraints(
                              minWidth: 28,
                              minHeight: 28,
                            ),
                            tooltip: 'Hapus Catatan',
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.black54,
                            ),
                            onPressed: onDelete,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Title
                  Text(
                    note.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Content preview
                  Expanded(
                    child: Text(
                      note.content,
                      maxLines: note.hasTodos ? 2 : 4,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ),
                  // Todo progress indicator
                  if (note.hasTodos) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.checklist_rounded,
                          size: 13,
                          color: Colors.black54,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${note.completedTodoCount}/${note.totalTodoCount}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color:
                                note.completedTodoCount == note.totalTodoCount
                                ? Colors.green.shade700
                                : Colors.black54,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value:
                                  note.completedTodoCount / note.totalTodoCount,
                              minHeight: 4,
                              backgroundColor: Colors.black.withAlpha(20),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                note.completedTodoCount == note.totalTodoCount
                                    ? Colors.green
                                    : Colors.deepPurple,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 6),
                  // Timestamp
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 13,
                        color: Colors.black54,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _formatDate(note.updatedAt),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
