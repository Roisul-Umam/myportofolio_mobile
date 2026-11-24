import 'package:json_annotation/json_annotation.dart';

part 'project.g.dart';

/// Portfolio project synchronized with the Django REST Framework API.
///
/// Field mengikuti `ProjectSerializer` di proyek Django:
/// `id`, `title`, `description`, `tags`, `link`, `project_image_url`,
/// dan `star_count` (read-only).
@JsonSerializable(fieldRename: FieldRename.snake)
class Project {
  const Project({
    this.id,
    required this.title,
    required this.description,
    required this.tags,
    this.link = '',
    this.projectImageUrl = '',
    this.starCount = 0,
  });

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);

  /// Dibuat oleh Django, jadi tidak dikirim saat POST.
  @JsonKey(includeToJson: false)
  final int? id;

  final String title;
  final String description;

  /// Daftar teknologi dipisah koma, misalnya `Django, Flutter`.
  final String tags;

  /// `link` dan `project_image_url` boleh null di Django.
  @JsonKey(defaultValue: '')
  final String link;

  @JsonKey(defaultValue: '')
  final String projectImageUrl;

  /// Dihitung server dari jumlah user yang memberi bintang.
  @JsonKey(includeToJson: false, defaultValue: 0)
  final int starCount;

  /// Tag yang sudah dipisah dan dirapikan, sama seperti `get_tags_list` di Django.
  List<String> get tagList => tags
      .split(',')
      .map((tag) => tag.trim())
      .where((tag) => tag.isNotEmpty)
      .toList();

  Map<String, dynamic> toJson() => _$ProjectToJson(this);
}
