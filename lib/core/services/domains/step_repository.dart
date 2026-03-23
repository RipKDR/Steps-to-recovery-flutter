import '../database_service.dart';
import '../../models/database_models.dart';

/// Domain facade for step-work persistence.
///
/// Delegates to [DatabaseService]. Import this instead of calling
/// DatabaseService directly for step-work operations.
class StepRepository {
  static final StepRepository _instance = StepRepository._();
  factory StepRepository() => _instance;
  StepRepository._();

  final _db = DatabaseService();

  Future<List<StepWorkAnswer>> getStepAnswers({
    required int stepNumber,
    String? userId,
  }) =>
      _db.getStepAnswers(stepNumber: stepNumber, userId: userId);

  Future<StepWorkAnswer?> getStepAnswer({
    required int stepNumber,
    required int questionNumber,
    String? userId,
  }) =>
      _db.getStepAnswer(
        stepNumber: stepNumber,
        questionNumber: questionNumber,
        userId: userId,
      );

  Future<StepWorkAnswer> saveStepAnswer(StepWorkAnswer answer) =>
      _db.saveStepAnswer(answer);

  Future<List<StepProgress>> getStepProgress({String? userId}) =>
      _db.getStepProgress(userId: userId);

  Future<StepProgress> saveStepProgress(StepProgress progress) =>
      _db.saveStepProgress(progress);
}
