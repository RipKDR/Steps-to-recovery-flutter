import 'package:equatable/equatable.dart';
import 'enums.dart';

/// User profile model
class UserProfile extends Equatable {
  final String id;
  final String email;
  final DateTime sobrietyStartDate;
  final String? programType; // AA, NA, etc.
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.email,
    required this.sobrietyStartDate,
    this.programType,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Calculate days sober
  int get daysSober {
    final now = DateTime.now();
    return now.difference(sobrietyStartDate).inDays;
  }

  /// Get sobriety milestone text
  String get sobrietyMilestone {
    final days = daysSober;
    if (days < 1) return 'Just starting';
    if (days < 7) return '$days days';
    if (days < 30) return '${days ~/ 7} weeks';
    if (days < 365) return '${days ~/ 30} months';
    final years = days / 365;
    if (years < 2) return '1 year';
    return '${years.toStringAsFixed(1)} years';
  }

  UserProfile copyWith({
    String? id,
    String? email,
    DateTime? sobrietyStartDate,
    String? programType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      sobrietyStartDate: sobrietyStartDate ?? this.sobrietyStartDate,
      programType: programType ?? this.programType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        sobrietyStartDate,
        programType,
        createdAt,
        updatedAt,
      ];
}

/// Daily check-in model
class DailyCheckIn extends Equatable {
  final String id;
  final String userId;
  final CheckInType checkInType;
  final DateTime checkInDate;
  final String? intention; // Encrypted
  final String? reflection; // Encrypted
  final int? mood; // 1-5 scale
  final int? craving; // 0-10 scale
  final SyncStatus syncStatus;
  final DateTime createdAt;

  const DailyCheckIn({
    required this.id,
    required this.userId,
    required this.checkInType,
    required this.checkInDate,
    this.intention,
    this.reflection,
    this.mood,
    this.craving,
    this.syncStatus = SyncStatus.pending,
    required this.createdAt,
  });

  DailyCheckIn copyWith({
    String? id,
    String? userId,
    CheckInType? checkInType,
    DateTime? checkInDate,
    String? intention,
    String? reflection,
    int? mood,
    int? craving,
    SyncStatus? syncStatus,
    DateTime? createdAt,
  }) {
    return DailyCheckIn(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      checkInType: checkInType ?? this.checkInType,
      checkInDate: checkInDate ?? this.checkInDate,
      intention: intention ?? this.intention,
      reflection: reflection ?? this.reflection,
      mood: mood ?? this.mood,
      craving: craving ?? this.craving,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        checkInType,
        checkInDate,
        intention,
        reflection,
        mood,
        craving,
        syncStatus,
        createdAt,
      ];
}

/// Journal entry model
class JournalEntry extends Equatable {
  final String id;
  final String userId;
  final String title; // Encrypted
  final String content; // Encrypted
  final String? mood; // Encrypted
  final String? craving; // Encrypted
  final List<String> tags; // Encrypted
  final bool isFavorite;
  final SyncStatus syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  const JournalEntry({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    this.mood,
    this.craving,
    this.tags = const [],
    this.isFavorite = false,
    this.syncStatus = SyncStatus.pending,
    required this.createdAt,
    required this.updatedAt,
  });

  JournalEntry copyWith({
    String? id,
    String? userId,
    String? title,
    String? content,
    String? mood,
    String? craving,
    List<String>? tags,
    bool? isFavorite,
    SyncStatus? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      mood: mood ?? this.mood,
      craving: craving ?? this.craving,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        content,
        mood,
        craving,
        tags,
        isFavorite,
        syncStatus,
        createdAt,
        updatedAt,
      ];
}

/// Step work answer model
class StepWorkAnswer extends Equatable {
  final String id;
  final String userId;
  final int stepNumber;
  final int questionNumber;
  final String? answer; // Encrypted
  final bool isComplete;
  final DateTime? completedAt;
  final SyncStatus syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StepWorkAnswer({
    required this.id,
    required this.userId,
    required this.stepNumber,
    required this.questionNumber,
    this.answer,
    this.isComplete = false,
    this.completedAt,
    this.syncStatus = SyncStatus.pending,
    required this.createdAt,
    required this.updatedAt,
  });

  StepWorkAnswer copyWith({
    String? id,
    String? userId,
    int? stepNumber,
    int? questionNumber,
    String? answer,
    bool? isComplete,
    DateTime? completedAt,
    SyncStatus? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StepWorkAnswer(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      stepNumber: stepNumber ?? this.stepNumber,
      questionNumber: questionNumber ?? this.questionNumber,
      answer: answer ?? this.answer,
      isComplete: isComplete ?? this.isComplete,
      completedAt: completedAt ?? this.completedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        stepNumber,
        questionNumber,
        answer,
        isComplete,
        completedAt,
        syncStatus,
        createdAt,
        updatedAt,
      ];
}

/// Step progress model
class StepProgress extends Equatable {
  final String id;
  final String userId;
  final int stepNumber;
  final StepStatus status;
  final double completionPercentage;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StepProgress({
    required this.id,
    required this.userId,
    required this.stepNumber,
    this.status = StepStatus.notStarted,
    this.completionPercentage = 0.0,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  StepProgress copyWith({
    String? id,
    String? userId,
    int? stepNumber,
    StepStatus? status,
    double? completionPercentage,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StepProgress(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      stepNumber: stepNumber ?? this.stepNumber,
      status: status ?? this.status,
      completionPercentage: completionPercentage ?? this.completionPercentage,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        stepNumber,
        status,
        completionPercentage,
        completedAt,
        createdAt,
        updatedAt,
      ];
}

/// Achievement model
class Achievement extends Equatable {
  final String id;
  final String userId;
  final String achievementKey;
  final AchievementType type;
  final DateTime earnedAt;
  final bool isViewed;

  const Achievement({
    required this.id,
    required this.userId,
    required this.achievementKey,
    required this.type,
    required this.earnedAt,
    this.isViewed = false,
  });

  Achievement copyWith({
    String? id,
    String? userId,
    String? achievementKey,
    AchievementType? type,
    DateTime? earnedAt,
    bool? isViewed,
  }) {
    return Achievement(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      achievementKey: achievementKey ?? this.achievementKey,
      type: type ?? this.type,
      earnedAt: earnedAt ?? this.earnedAt,
      isViewed: isViewed ?? this.isViewed,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        achievementKey,
        type,
        earnedAt,
        isViewed,
      ];
}

/// Contact model (sponsor, support network)
class Contact extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String phoneNumber;
  final String? email;
  final String relationship; // sponsor, sponsee, emergency, etc.
  final bool isPrimary;
  final DateTime createdAt;

  const Contact({
    required this.id,
    required this.userId,
    required this.name,
    required this.phoneNumber,
    this.email,
    required this.relationship,
    this.isPrimary = false,
    required this.createdAt,
  });

  Contact copyWith({
    String? id,
    String? userId,
    String? name,
    String? phoneNumber,
    String? email,
    String? relationship,
    bool? isPrimary,
    DateTime? createdAt,
  }) {
    return Contact(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      relationship: relationship ?? this.relationship,
      isPrimary: isPrimary ?? this.isPrimary,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        phoneNumber,
        email,
        relationship,
        isPrimary,
        createdAt,
      ];
}

/// Meeting model
class Meeting extends Equatable {
  final String id;
  final String name;
  final String location;
  final String? address;
  final DateTime? dateTime;
  final String meetingType; // in-person, online, hybrid
  final List<String> formats; // discussion, speaker, step, etc.
  final String? notes;
  final bool isFavorite;
  final double? latitude;
  final double? longitude;

  const Meeting({
    required this.id,
    required this.name,
    required this.location,
    this.address,
    this.dateTime,
    required this.meetingType,
    this.formats = const [],
    this.notes,
    this.isFavorite = false,
    this.latitude,
    this.longitude,
  });

  Meeting copyWith({
    String? id,
    String? name,
    String? location,
    String? address,
    DateTime? dateTime,
    String? meetingType,
    List<String>? formats,
    String? notes,
    bool? isFavorite,
    double? latitude,
    double? longitude,
  }) {
    return Meeting(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      address: address ?? this.address,
      dateTime: dateTime ?? this.dateTime,
      meetingType: meetingType ?? this.meetingType,
      formats: formats ?? this.formats,
      notes: notes ?? this.notes,
      isFavorite: isFavorite ?? this.isFavorite,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        location,
        address,
        dateTime,
        meetingType,
        formats,
        notes,
        isFavorite,
        latitude,
        longitude,
      ];
}

/// AI Chat message model
class ChatMessage extends Equatable {
  final String id;
  final String conversationId;
  final String userId;
  final String content;
  final bool isUser;
  final DateTime createdAt;
  final String? encryptedContent;

  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.userId,
    required this.content,
    required this.isUser,
    required this.createdAt,
    this.encryptedContent,
  });

  ChatMessage copyWith({
    String? id,
    String? conversationId,
    String? userId,
    String? content,
    bool? isUser,
    DateTime? createdAt,
    String? encryptedContent,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      createdAt: createdAt ?? this.createdAt,
      encryptedContent: encryptedContent ?? this.encryptedContent,
    );
  }

  @override
  List<Object?> get props => [
        id,
        conversationId,
        userId,
        content,
        isUser,
        createdAt,
        encryptedContent,
      ];
}

/// AI Conversation model
class ChatConversation extends Equatable {
  final String id;
  final String userId;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ChatConversation({
    required this.id,
    required this.userId,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
  });

  ChatConversation copyWith({
    String? id,
    String? userId,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChatConversation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        createdAt,
        updatedAt,
      ];
}

/// Gratitude entry model
class GratitudeEntry extends Equatable {
  final String id;
  final String userId;
  final String content;
  final DateTime createdAt;

  const GratitudeEntry({
    required this.id,
    required this.userId,
    required this.content,
    required this.createdAt,
  });

  GratitudeEntry copyWith({
    String? id,
    String? userId,
    String? content,
    DateTime? createdAt,
  }) {
    return GratitudeEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        content,
        createdAt,
      ];
}

/// Safety plan model
class SafetyPlan extends Equatable {
  final String id;
  final String userId;
  final List<String> warningSigns;
  final List<String> copingStrategies;
  final List<String> supportContacts;
  final List<String> professionalContacts;
  final List<String> safeEnvironments;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SafetyPlan({
    required this.id,
    required this.userId,
    this.warningSigns = const [],
    this.copingStrategies = const [],
    this.supportContacts = const [],
    this.professionalContacts = const [],
    this.safeEnvironments = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  SafetyPlan copyWith({
    String? id,
    String? userId,
    List<String>? warningSigns,
    List<String>? copingStrategies,
    List<String>? supportContacts,
    List<String>? professionalContacts,
    List<String>? safeEnvironments,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SafetyPlan(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      warningSigns: warningSigns ?? this.warningSigns,
      copingStrategies: copingStrategies ?? this.copingStrategies,
      supportContacts: supportContacts ?? this.supportContacts,
      professionalContacts: professionalContacts ?? this.professionalContacts,
      safeEnvironments: safeEnvironments ?? this.safeEnvironments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        warningSigns,
        copingStrategies,
        supportContacts,
        professionalContacts,
        safeEnvironments,
        createdAt,
        updatedAt,
      ];
}

/// Challenge model
class Challenge extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String description;
  final int durationDays;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isCompleted;
  final bool isActive;
  final DateTime createdAt;

  const Challenge({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.durationDays,
    required this.startDate,
    this.endDate,
    this.isCompleted = false,
    this.isActive = true,
    required this.createdAt,
  });

  Challenge copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    int? durationDays,
    DateTime? startDate,
    DateTime? endDate,
    bool? isCompleted,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Challenge(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      durationDays: durationDays ?? this.durationDays,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isCompleted: isCompleted ?? this.isCompleted,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        description,
        durationDays,
        startDate,
        endDate,
        isCompleted,
        isActive,
        createdAt,
      ];
}

/// Reading reflection model
class ReadingReflection extends Equatable {
  final String id;
  final String userId;
  final String readingId;
  final DateTime readingDate;
  final String reflection;
  final DateTime createdAt;

  const ReadingReflection({
    required this.id,
    required this.userId,
    required this.readingId,
    required this.readingDate,
    required this.reflection,
    required this.createdAt,
  });

  ReadingReflection copyWith({
    String? id,
    String? userId,
    String? readingId,
    DateTime? readingDate,
    String? reflection,
    DateTime? createdAt,
  }) {
    return ReadingReflection(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      readingId: readingId ?? this.readingId,
      readingDate: readingDate ?? this.readingDate,
      reflection: reflection ?? this.reflection,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        readingId,
        readingDate,
        reflection,
        createdAt,
      ];
}
