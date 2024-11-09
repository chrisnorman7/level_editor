import 'package:json_annotation/json_annotation.dart';

part 'platform_link.g.dart';

/// A class to link two platforms together.
@JsonSerializable()
class PlatformLink {
  /// Create an instance.
  PlatformLink({
    required this.platformId,
    this.move = false,
    this.resize = false,
  });

  /// Create an instance from a JSON object.
  factory PlatformLink.fromJson(final Map<String, dynamic> json) =>
      _$PlatformLinkFromJson(json);

  /// The ID of the platform to shadow.
  String platformId;

  /// Whether the origin platform will move with the target platform.
  bool move;

  /// Whether the origin platform will be resized with the target platform.
  bool resize;

  /// Convert an instance to JSON.
  Map<String, dynamic> toJson() => _$PlatformLinkToJson(this);
}
