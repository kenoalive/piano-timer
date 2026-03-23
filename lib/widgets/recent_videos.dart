import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/utils.dart';
import 'video_thumbnail.dart';

class RecentVideos extends StatelessWidget {
  final List<PracticeRecord> records;
  final Function(PracticeRecord record)? onVideoTap;
  final VoidCallback? onMoreTap;

  const RecentVideos({
    super.key,
    required this.records,
    this.onVideoTap,
    this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: AppTheme.iconContainerDecoration(
                  context,
                  Theme.of(context).colorScheme.primary,
                ),
                child: Icon(
                  Icons.video_library,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '最近视频',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: records.length + 1, // +1 for "more" button
            itemBuilder: (context, index) {
              if (index == records.length) {
                // More button
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: SizedBox(
                    width: 80,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 72,
                          child: GestureDetector(
                            onTap: onMoreTap,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.more_horiz,
                                    color: Theme.of(context).colorScheme.primary,
                                    size: 24,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '更多',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final record = records[index];
              final firstVideo = record.videos.isNotEmpty ? record.videos.first : null;

              if (firstVideo == null) {
                return const SizedBox.shrink();
              }

              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: SizedBox(
                  width: 80,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 72,
                        child: VideoThumbnail(
                          thumbnailPath: firstVideo.thumbnailPath,
                          localPath: firstVideo.localPath,
                          duration: firstVideo.duration,
                          height: 72,
                          onTap: () => onVideoTap?.call(record),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _getRecordLabel(record),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _getRecordLabel(PracticeRecord record) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final recordDate = DateTime(record.startTime.year, record.startTime.month, record.startTime.day);
    final diff = today.difference(recordDate).inDays;

    if (diff == 0) {
      return '今天';
    } else if (diff == 1) {
      return '昨天';
    } else {
      return '${record.startTime.month}/${record.startTime.day}';
    }
  }
}
