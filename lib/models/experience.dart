import 'package:json_annotation/json_annotation.dart';

part 'experience.g.dart';

/// Pengalaman portofolio yang disinkronkan dengan `ExperienceSerializer` DRF.
///
/// Field yang dibuat atau dihitung server (`id`, `category_display`,
/// `started_at`, `is_ongoing`, `star_count`) tidak dikirim saat POST.
@JsonSerializable(fieldRename: FieldRename.snake)
class Experience {
  const Experience({
    this.id,
    required this.title,
    required this.description,
    this.category = Experience.defaultCategory,
    this.categoryDisplay = '',
    this.thumbnail = '',
    this.startedAt,
    this.endedAt,
    this.isOngoing = true,
    this.starCount = 0,
  });

  factory Experience.fromJson(Map<String, dynamic> json) =>
      _$ExperienceFromJson(json);

  /// Nilai bawaan `category` di model Django.
  static const String defaultCategory = 'full-time';

  /// UUID yang dibuat Django.
  @JsonKey(includeToJson: false)
  final String? id;

  final String title;
  final String description;

  /// Kunci pilihan, misalnya `internship` atau `full-time`.
  final String category;

  /// Label pilihan dari server, misalnya `Full-Time`.
  @JsonKey(includeToJson: false, defaultValue: '')
  final String categoryDisplay;

  /// Boleh null di Django, jadi dibaca sebagai string kosong.
  @JsonKey(defaultValue: '')
  final String thumbnail;

  /// Diisi otomatis oleh Django (`auto_now_add`).
  @JsonKey(includeToJson: false)
  final DateTime? startedAt;

  /// Kosong berarti pengalaman masih berlangsung.
  @JsonKey(toJson: _dateTimeToJson)
  final DateTime? endedAt;

  @JsonKey(includeToJson: false, defaultValue: true)
  final bool isOngoing;

  @JsonKey(includeToJson: false, defaultValue: 0)
  final int starCount;

  Map<String, dynamic> toJson() => _$ExperienceToJson(this);
}

/// Mengirim waktu dalam UTC supaya tidak bergeser karena zona waktu.
String? _dateTimeToJson(DateTime? value) => value?.toUtc().toIso8601String();
