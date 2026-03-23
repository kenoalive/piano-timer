import 'package:equatable/equatable.dart';

class Video extends Equatable {
  final String id;
  final String localPath;
  final String? cloudPath;
  final String? thumbnailPath;
  final int duration; // 秒
  final int size; // 字节
  final bool isSynced;
  final DateTime createdAt;

  const Video({
    required this.id,
    required this.localPath,
    this.cloudPath,
    this.thumbnailPath,
    required this.duration,
    required this.size,
    this.isSynced = false,
    required this.createdAt,
  });

  Video copyWith({
    String? id,
    String? localPath,
    String? cloudPath,
    String? thumbnailPath,
    int? duration,
    int? size,
    bool? isSynced,
    DateTime? createdAt,
  }) {
    return Video(
      id: id ?? this.id,
      localPath: localPath ?? this.localPath,
      cloudPath: cloudPath ?? this.cloudPath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      duration: duration ?? this.duration,
      size: size ?? this.size,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'localPath': localPath,
      'cloudPath': cloudPath,
      'thumbnailPath': thumbnailPath,
      'duration': duration,
      'size': size,
      'isSynced': isSynced ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Video.fromMap(Map<String, dynamic> map) {
    return Video(
      id: map['id'] as String,
      localPath: map['localPath'] as String,
      cloudPath: map['cloudPath'] as String?,
      thumbnailPath: map['thumbnailPath'] as String?,
      duration: map['duration'] as int,
      size: map['size'] as int,
      isSynced: (map['isSynced'] as int) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  @override
  List<Object?> get props => [
        id,
        localPath,
        cloudPath,
        thumbnailPath,
        duration,
        size,
        isSynced,
        createdAt,
      ];
}
