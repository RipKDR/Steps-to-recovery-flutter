import '../../../core/models/database_models.dart';
import '../../../core/utils/achievement_share_utils.dart';

class HomeHubSnapshot {
  const HomeHubSnapshot({
    required this.user,
    required this.morningCheckIn,
    required this.eveningCheckIn,
    required this.sponsor,
    required this.unreadAchievements,
    required this.unreadShareableMilestones,
    required this.featuredShareContent,
  });

  const HomeHubSnapshot.empty()
    : user = null,
      morningCheckIn = null,
      eveningCheckIn = null,
      sponsor = null,
      unreadAchievements = 0,
      unreadShareableMilestones = const <Achievement>[],
      featuredShareContent = null;

  final UserProfile? user;
  final DailyCheckIn? morningCheckIn;
  final DailyCheckIn? eveningCheckIn;
  final Contact? sponsor;
  final int unreadAchievements;
  final List<Achievement> unreadShareableMilestones;
  final MilestoneShareContent? featuredShareContent;

  Achievement? get featuredShareAchievement {
    if (unreadShareableMilestones.isEmpty) {
      return null;
    }
    return unreadShareableMilestones.first;
  }
}

enum DailyCardStatus { nextUp, laterToday, doneToday }

class HomeActionRecommendation {
  const HomeActionRecommendation({
    required this.heroTitle,
    required this.heroSubtitle,
    required this.sectionCopy,
    required this.morningStatus,
    required this.eveningStatus,
  });

  final String heroTitle;
  final String heroSubtitle;
  final String sectionCopy;
  final DailyCardStatus morningStatus;
  final DailyCardStatus eveningStatus;

  factory HomeActionRecommendation.fromSnapshot(HomeHubSnapshot snapshot) {
    final hasMorning = snapshot.morningCheckIn != null;
    final hasEvening = snapshot.eveningCheckIn != null;

    if (hasMorning && hasEvening) {
      return const HomeActionRecommendation(
        heroTitle: 'Daily path complete',
        heroSubtitle:
            'You have already logged both check-ins. Open either one to add more detail.',
        sectionCopy:
            'Both daily check-ins are saved. Use the dedicated screens if you want to add reflection or edit what you captured.',
        morningStatus: DailyCardStatus.doneToday,
        eveningStatus: DailyCardStatus.doneToday,
      );
    }

    if (hasMorning) {
      return const HomeActionRecommendation(
        heroTitle: 'Evening pulse is next',
        heroSubtitle:
            'Your morning intention is set. Log tonight’s mood and cravings when you are ready.',
        sectionCopy:
            'Morning is already done. Keep the evening card easy to reach so the day can close quickly.',
        morningStatus: DailyCardStatus.doneToday,
        eveningStatus: DailyCardStatus.nextUp,
      );
    }

    if (hasEvening) {
      return const HomeActionRecommendation(
        heroTitle: 'Morning intention is still open',
        heroSubtitle:
            'You already logged your evening pulse. Set one intention so today still has a clear anchor.',
        sectionCopy:
            'Evening is already saved. Morning stays first because it shapes the rest of the day.',
        morningStatus: DailyCardStatus.nextUp,
        eveningStatus: DailyCardStatus.doneToday,
      );
    }

    return const HomeActionRecommendation(
      heroTitle: 'Start with one steady next step',
      heroSubtitle:
          'Set a short morning intention now, then you can log tonight’s pulse in the same place later.',
      sectionCopy:
          'The fastest path is simple: morning first, evening later, and deeper reflection only if you need it.',
      morningStatus: DailyCardStatus.nextUp,
      eveningStatus: DailyCardStatus.laterToday,
    );
  }
}
