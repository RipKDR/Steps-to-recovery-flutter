class EmergencyContact {
  EmergencyContact({required this.name, required this.phone});

  final String name;
  final String phone;

  Map<String, dynamic> toJson() => {'name': name, 'phone': phone};

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      name: (json['name'] ?? '') as String,
      phone: (json['phone'] ?? '') as String,
    );
  }
}

class RecoveryData {
  RecoveryData({
    required this.streakDays,
    required this.morningDone,
    required this.eveningDone,
    required this.journal,
    required this.contacts,
    required this.reminderMorning,
    required this.reminderEvening,
  });

  final int streakDays;
  final bool morningDone;
  final bool eveningDone;
  final String journal;
  final List<EmergencyContact> contacts;
  final bool reminderMorning;
  final bool reminderEvening;

  RecoveryData copyWith({
    int? streakDays,
    bool? morningDone,
    bool? eveningDone,
    String? journal,
    List<EmergencyContact>? contacts,
    bool? reminderMorning,
    bool? reminderEvening,
  }) {
    return RecoveryData(
      streakDays: streakDays ?? this.streakDays,
      morningDone: morningDone ?? this.morningDone,
      eveningDone: eveningDone ?? this.eveningDone,
      journal: journal ?? this.journal,
      contacts: contacts ?? this.contacts,
      reminderMorning: reminderMorning ?? this.reminderMorning,
      reminderEvening: reminderEvening ?? this.reminderEvening,
    );
  }

  Map<String, dynamic> toJson() => {
        'streakDays': streakDays,
        'morningDone': morningDone,
        'eveningDone': eveningDone,
        'journal': journal,
        'contacts': contacts.map((e) => e.toJson()).toList(),
        'reminderMorning': reminderMorning,
        'reminderEvening': reminderEvening,
      };

  factory RecoveryData.fromJson(Map<String, dynamic> json) {
    final contactsRaw = (json['contacts'] as List<dynamic>? ?? []);
    return RecoveryData(
      streakDays: (json['streakDays'] as num?)?.toInt() ?? 12,
      morningDone: json['morningDone'] as bool? ?? false,
      eveningDone: json['eveningDone'] as bool? ?? false,
      journal: json['journal'] as String? ?? '',
      contacts: contactsRaw
          .whereType<Map>()
          .map((e) => EmergencyContact.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      reminderMorning: json['reminderMorning'] as bool? ?? true,
      reminderEvening: json['reminderEvening'] as bool? ?? true,
    );
  }

  static RecoveryData initial() => RecoveryData(
        streakDays: 12,
        morningDone: false,
        eveningDone: false,
        journal: '',
        contacts: [],
        reminderMorning: true,
        reminderEvening: true,
      );
}
