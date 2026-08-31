import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';

class NoteStorage {
  static const String _storageKey = 'polnes_notes_data';

  final SharedPreferences? _prefs;

  NoteStorage([this._prefs]);

  Future<SharedPreferences> get _instance async {
    return _prefs ?? await SharedPreferences.getInstance();
  }

  Future<List<Note>> loadNotes() async {
    final prefs = await _instance;
    final String? notesJson = prefs.getString(_storageKey);

    if (notesJson == null) {
      final initialNotes = Note.getInitialSampleNotes();
      await saveNotes(initialNotes);
      return initialNotes;
    }

    try {
      final List<dynamic> decoded = jsonDecode(notesJson) as List<dynamic>;
      return decoded
          .map((item) => Note.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      final initialNotes = Note.getInitialSampleNotes();
      return initialNotes;
    }
  }

  Future<void> saveNotes(List<Note> notes) async {
    final prefs = await _instance;
    final String encoded = jsonEncode(
      notes.map((note) => note.toJson()).toList(),
    );
    await prefs.setString(_storageKey, encoded);
  }

  Future<void> clearNotes() async {
    final prefs = await _instance;
    await prefs.remove(_storageKey);
  }
}
