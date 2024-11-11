import 'package:flutter_audio_games/flutter_audio_games.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sound_reference.g.dart';

/// A reference to a sound.
@JsonSerializable()
class SoundReference {
  /// Create an instance.
  SoundReference({
    required this.path,
    this.volume = 0.7,
  });

  /// Create an instance from a JSON object.
  factory SoundReference.fromJson(final Map<String, dynamic> json) =>
      _$SoundReferenceFromJson(json);

  /// The path to the sound.
  String path;

  /// The volume of the sound.
  double volume;

  /// Return a sound reference from this instance.
  Sound asSound({
    required final bool destroy,
    required final SoundType soundType,
    final LoadMode loadMode = LoadMode.memory,
    final bool looping = false,
    final Duration loopingStart = Duration.zero,
    final bool paused = false,
    final SoundPosition position = unpanned,
  }) =>
      path.asSound(
        destroy: destroy,
        soundType: soundType,
        loadMode: loadMode,
        looping: looping,
        volume: volume,
        loopingStart: loopingStart,
        paused: paused,
        position: position,
      );

  /// Convert an instance to JSON.
  Map<String, dynamic> toJson() => _$SoundReferenceToJson(this);
}
