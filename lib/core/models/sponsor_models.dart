// lib/core/models/sponsor_models.dart
import 'dart:convert';
import 'package:equatable/equatable.dart';

/// Sponsor personality vibe options
enum SponsorVibe { warm, direct, spiritual, toughLove }

/// Relationship stages with the sponsor
enum SponsorStage { new_, building, trusted, close, deep }

/// Categories for sponsor memory entries
enum MemoryCategory {
  lifeContext,
  recoveryPattern,
  whatWorks,
  keyRelationship,
  hardMoment,
}

/// Sponsor identity - chosen by user during onboarding
class SponsorIdentity extends Equatable {
  final String name;
  final SponsorVibe vibe;
  final DateTime createdAt;

  const SponsorIdentity({
    required this.name,
    required this.vibe,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'vibe': vibe.name,
    'createdAt': createdAt.toIso8601String(),
  };

  factory SponsorIdentity.fromJson(Map<String, dynamic> json) =>
      SponsorIdentity(
        name: json['name'] as String,
        vibe: SponsorVibe.values.byName(json['vibe'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  String toJsonString() => jsonEncode(toJson());
  
  factory SponsorIdentity.fromJsonString(String s) =>
      SponsorIdentity.fromJson(jsonDecode(s) as Map<String, dynamic>);

  @override
  List<Object?> get props => [name, vibe, createdAt];
}

/// Stage data with engagement tracking
class SponsorStageData extends Equatable {
  final SponsorStage stage;
  final int engagementScore;
  final DateTime lastInteraction;

  const SponsorStageData({
    required this.stage,
    required this.engagementScore,
    required this.lastInteraction,
  });

  /// Computes the current stage from score and sobriety days.
  /// Takes the higher of the two. Never goes below [stage].
  SponsorStage computeStage({required int sobrietyDays}) {
    SponsorStage scoreBased;
    if (engagementScore >= 151) {
      scoreBased = SponsorStage.deep;
    } else if (engagementScore >= 81) {
      scoreBased = SponsorStage.close;
    } else if (engagementScore >= 41) {
      scoreBased = SponsorStage.trusted;
    } else if (engagementScore >= 16) {
      scoreBased = SponsorStage.building;
    } else {
      scoreBased = SponsorStage.new_;
    }

    SponsorStage daysBased;
    if (sobrietyDays >= 365) {
      daysBased = SponsorStage.deep;
    } else if (sobrietyDays >= 91) {
      daysBased = SponsorStage.close;
    } else if (sobrietyDays >= 31) {
      daysBased = SponsorStage.trusted;
    } else if (sobrietyDays >= 8) {
      daysBased = SponsorStage.building;
    } else {
      daysBased = SponsorStage.new_;
    }

    // Take the highest of the three
    final computed = [scoreBased, daysBased, stage]
        .reduce((a, b) => a.index > b.index ? a : b);
    return computed;
  }

  SponsorStageData copyWith({
    SponsorStage? stage,
    int? engagementScore,
    DateTime? lastInteraction,
  }) => SponsorStageData(
    stage: stage ?? this.stage,
    engagementScore: engagementScore ?? this.engagementScore,
    lastInteraction: lastInteraction ?? this.lastInteraction,
  );

  Map<String, dynamic> toJson() => {
    'stage': stage.name,
    'engagementScore': engagementScore,
    'lastInteraction': lastInteraction.toIso8601String(),
  };

  factory SponsorStageData.fromJson(Map<String, dynamic> json) =>
      SponsorStageData(
        stage: SponsorStage.values.byName(json['stage'] as String),
        engagementScore: json['engagementScore'] as int,
        lastInteraction: DateTime.parse(json['lastInteraction'] as String),
      );

  String toJsonString() => jsonEncode(toJson());
  
  factory SponsorStageData.fromJsonString(String s) =>
      SponsorStageData.fromJson(jsonDecode(s) as Map<String, dynamic>);

  @override
  List<Object?> get props => [stage, engagementScore, lastInteraction];
}

/// Individual memory entry
class SponsorMemory extends Equatable {
  final String id;
  final MemoryCategory category;
  final String summary; // max 500 chars
  final DateTime createdAt;
  final DateTime? distilledAt;

  SponsorMemory({
    required this.id,
    required this.category,
    required String summary,
    required this.createdAt,
    this.distilledAt,
  }) : summary = summary.length > 500 ? summary.substring(0, 500) : summary;

  Map<String, dynamic> toJson() => {
    'id': id,
    'category': category.name,
    'summary': summary,
    'createdAt': createdAt.toIso8601String(),
    'distilledAt': distilledAt?.toIso8601String(),
  };

  factory SponsorMemory.fromJson(Map<String, dynamic> json) => SponsorMemory(
    id: json['id'] as String,
    category: MemoryCategory.values.byName(json['category'] as String),
    summary: json['summary'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    distilledAt: json['distilledAt'] != null
        ? DateTime.parse(json['distilledAt'] as String)
        : null,
  );

  @override
  List<Object?> get props => [id, category, summary, createdAt, distilledAt];
}

/// Container for all 3 memory tiers — serialised to/from sponsor_memory.json
class SponsorMemoryFile extends Equatable {
  final List<SponsorMemory> session;
  final List<SponsorMemory> digest;
  final List<SponsorMemory> longterm;

  const SponsorMemoryFile({
    required this.session,
    required this.digest,
    required this.longterm,
  });

  factory SponsorMemoryFile.empty() =>
      const SponsorMemoryFile(session: [], digest: [], longterm: []);

  Map<String, dynamic> toJson() => {
    'session': session.map((m) => m.toJson()).toList(),
    'digest': digest.map((m) => m.toJson()).toList(),
    'longterm': longterm.map((m) => m.toJson()).toList(),
  };

  factory SponsorMemoryFile.fromJson(Map<String, dynamic> json) =>
      SponsorMemoryFile(
        session: (json['session'] as List)
            .map((e) => SponsorMemory.fromJson(e as Map<String, dynamic>))
            .toList(),
        digest: (json['digest'] as List)
            .map((e) => SponsorMemory.fromJson(e as Map<String, dynamic>))
            .toList(),
        longterm: (json['longterm'] as List)
            .map((e) => SponsorMemory.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  SponsorMemoryFile copyWith({
    List<SponsorMemory>? session,
    List<SponsorMemory>? digest,
    List<SponsorMemory>? longterm,
  }) => SponsorMemoryFile(
    session: session ?? this.session,
    digest: digest ?? this.digest,
    longterm: longterm ?? this.longterm,
  );

  @override
  List<Object?> get props => [session, digest, longterm];
}


