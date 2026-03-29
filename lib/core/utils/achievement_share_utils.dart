import '../constants/app_constants.dart';
import '../models/database_models.dart';

const Set<String> shareableMilestoneAchievementKeys = <String>{
  AchievementKeys.milestone24Hours,
  AchievementKeys.milestone7Days,
  AchievementKeys.milestone30Days,
  AchievementKeys.milestone90Days,
  AchievementKeys.milestone1Year,
};

class MilestoneShareContent {
  const MilestoneShareContent({
    required this.milestoneTitle,
    required this.buttonLabel,
    required this.shareSubject,
    required this.shareText,
  });

  final String milestoneTitle;
  final String buttonLabel;
  final String shareSubject;
  final String shareText;
}

class _ShareableMilestoneDefinition {
  const _ShareableMilestoneDefinition({
    required this.rank,
    required this.milestoneTitle,
    required this.sharePhrase,
  });

  final int rank;
  final String milestoneTitle;
  final String sharePhrase;
}

const Map<String, _ShareableMilestoneDefinition> _shareableMilestonesByKey =
    <String, _ShareableMilestoneDefinition>{
  AchievementKeys.milestone24Hours: _ShareableMilestoneDefinition(
    rank: 1,
    milestoneTitle: '24 Hours',
    sharePhrase: '24 hours',
  ),
  AchievementKeys.milestone7Days: _ShareableMilestoneDefinition(
    rank: 7,
    milestoneTitle: '1 Week',
    sharePhrase: '7 days',
  ),
  AchievementKeys.milestone30Days: _ShareableMilestoneDefinition(
    rank: 30,
    milestoneTitle: '1 Month',
    sharePhrase: '30 days',
  ),
  AchievementKeys.milestone90Days: _ShareableMilestoneDefinition(
    rank: 90,
    milestoneTitle: '90 Days',
    sharePhrase: '90 days',
  ),
  AchievementKeys.milestone1Year: _ShareableMilestoneDefinition(
    rank: 365,
    milestoneTitle: '1 Year',
    sharePhrase: '1 year',
  ),
};

List<Achievement> sortShareableMilestoneAchievements(
  Iterable<Achievement> achievements,
) {
  final shareable = achievements
      .where((achievement) =>
          isShareableMilestoneAchievement(achievement) && !achievement.isViewed)
      .toList()
    ..sort((left, right) {
      final rightRank = _shareableMilestonesByKey[right.achievementKey]!.rank;
      final leftRank = _shareableMilestonesByKey[left.achievementKey]!.rank;
      final rankComparison = rightRank.compareTo(leftRank);
      if (rankComparison != 0) {
        return rankComparison;
      }
      return right.earnedAt.compareTo(left.earnedAt);
    });

  return shareable;
}

bool isShareableMilestoneAchievement(Achievement achievement) {
  return shareableMilestoneAchievementKeys.contains(achievement.achievementKey);
}

MilestoneShareContent? milestoneShareContentForAchievement(
  Achievement achievement,
) {
  final definition = _shareableMilestonesByKey[achievement.achievementKey];
  if (definition == null) {
    return null;
  }

  return MilestoneShareContent(
    milestoneTitle: definition.milestoneTitle,
    buttonLabel: 'Share ${definition.milestoneTitle}',
    shareSubject: '${definition.milestoneTitle} in recovery',
    shareText:
        'I just hit ${definition.sharePhrase} in recovery.\n\nOne day at a time. Tracking it with Steps to Recovery.',
  );
}
