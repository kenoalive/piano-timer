import 'package:equatable/equatable.dart';
import 'video.dart';

class PracticeRecord extends Equatable {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final int duration; // 秒
  final String? notes;
  final List<Video> videos;
  final bool isSynced;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PracticeRecord({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.duration,
    this.notes,
    this.videos = const [],
    this.isSynced = false,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isRunning => endTime == null;

  PracticeRecord copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    int? duration,
    String? notes,
    List<Video>? videos,
    bool? isSynced,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PracticeRecord(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      notes: notes ?? this.notes,
      videos: videos ?? this.videos,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'duration': duration,
      'notes': notes,
      'isSynced': isSynced ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory PracticeRecord.fromMap(Map<String, dynamic> map, {List<Video>? videos}) {
    return PracticeRecord(
      id: map['id'] as String,
      startTime: DateTime.parse(map['startTime'] as String),
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime'] as String) : null,
      duration: map['duration'] as int,
      notes: map['notes'] as String?,
      videos: videos ?? const [],
      isSynced: (map['isSynced'] as int) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  @override
  List<Object?> get props => [
        id,
        startTime,
        endTime,
        duration,
        notes,
        videos,
        isSynced,
        createdAt,
        updatedAt,
      ];
}
