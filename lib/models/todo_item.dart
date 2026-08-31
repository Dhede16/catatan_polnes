/// Represents a single checkable task item within a note.
class TodoItem {
  final String id;
  final String text;
  final bool isDone;

  const TodoItem({required this.id, required this.text, this.isDone = false});

  TodoItem copyWith({String? id, String? text, bool? isDone}) {
    return TodoItem(
      id: id ?? this.id,
      text: text ?? this.text,
      isDone: isDone ?? this.isDone,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'text': text, 'isDone': isDone};
  }

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      id: json['id'] as String,
      text: json['text'] as String,
      isDone: json['isDone'] as bool? ?? false,
    );
  }
}
