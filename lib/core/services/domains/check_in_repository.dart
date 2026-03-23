import '../database_service.dart';
import '../../models/database_models.dart';

/// Domain facade for check-in persistence.
///
/// Delegates to [DatabaseService]. Import this instead of calling
/// DatabaseService directly for check-in operations — keeps domain
/// boundaries explicit and makes future extraction straightforward.
class CheckInRepository {
  static final CheckInRepository _instance = CheckInRepository._();
  factory CheckInRepository() => _instance;
  CheckInRepository._();

  final _db = DatabaseService();

  Future<List<DailyCheckIn>> getCheckIns({
    String? userId,
    CheckInType? type,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
  }) =>
      _db.getCheckIns(
        userId: userId,
        type: type,
        startDate: startDate,
        endDate: endDate,
        limit: limit,
      );

  Future<DailyCheckIn?> getTodayCheckIn(
    CheckInType type, {
    String? userId,
  }) =>
      _db.getTodayCheckIn(type, userId: userId);

  Future<DailyCheckIn> saveCheckIn(DailyCheckIn checkIn) =>
      _db.saveCheckIn(checkIn);

  Future<void> deleteCheckIn(String id) => _db.deleteCheckIn(id);
}
