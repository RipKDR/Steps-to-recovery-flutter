import '../database_service.dart';
import '../../models/database_models.dart';

/// Domain facade for journal-entry persistence.
///
/// Delegates to [DatabaseService]. Import this instead of calling
/// DatabaseService directly for journal operations.
class JournalRepository {
  static final JournalRepository _instance = JournalRepository._();
  factory JournalRepository() => _instance;
  JournalRepository._();

  final _db = DatabaseService();

  Future<List<JournalEntry>> getJournalEntries({
    String? userId,
    bool? isFavorite,
    List<String>? tags,
    int limit = 100,
  }) =>
      _db.getJournalEntries(
        userId: userId,
        isFavorite: isFavorite,
        tags: tags,
        limit: limit,
      );

  Future<JournalEntry?> getJournalEntryById(String id) =>
      _db.getJournalEntryById(id);

  Future<JournalEntry> saveJournalEntry(JournalEntry entry) =>
      _db.saveJournalEntry(entry);

  Future<void> deleteJournalEntry(String id) => _db.deleteJournalEntry(id);
}
