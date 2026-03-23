import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../utils/utils.dart';
import 'video_player_screen.dart';

class VideoListScreen extends StatefulWidget {
  const VideoListScreen({super.key});

  @override
  VideoListScreenState createState() => VideoListScreenState();
}

class VideoListScreenState extends State<VideoListScreen> with WidgetsBindingObserver {
  String _filter = 'all';
  List<PracticeRecord> _records = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;
  final int _pageSize = 20;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadRecords();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 当页面重新获得焦点时刷新数据
    if (state == AppLifecycleState.resumed) {
      _loadRecords();
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMore) {
        _loadMoreRecords();
      }
    }
  }

  Future<void> _loadRecords() async {
    setState(() {
      _isLoading = true;
      _currentPage = 1;
      _hasMore = true;
    });

    final db = context.read<DatabaseService>();
    final records = await db.getRecordsPaginated(
      page: 1,
      pageSize: _pageSize,
      hasContent: true,
    );

    // 应用过滤
    final filtered = _filterRecords(records);

    setState(() {
      _records = filtered;
      _hasMore = filtered.length >= _pageSize;
      _isLoading = false;
    });
  }

  /// 公开的刷新方法，供外部调用
  Future<void> refreshData() async {
    await _loadRecords();
  }

  Future<void> _loadMoreRecords() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() => _isLoadingMore = true);

    final db = context.read<DatabaseService>();
    final nextPage = _currentPage + 1;
    final records = await db.getRecordsPaginated(
      page: nextPage,
      pageSize: _pageSize,
      hasContent: true,
    );

    // 应用过滤
    final filtered = _filterRecords(records);

    setState(() {
      if (filtered.isNotEmpty) {
        _records.addAll(filtered);
        _currentPage = nextPage;
        _hasMore = filtered.length >= _pageSize;
      } else {
        _hasMore = false;
      }
      _isLoadingMore = false;
    });
  }

  List<PracticeRecord> _filterRecords(List<PracticeRecord> records) {
    if (_filter == 'all') return records;
    if (_filter == 'month') {
      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month, 1);
      return records.where((r) => r.startTime.isAfter(monthStart)).toList();
    }
    if (_filter == 'week') {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final startOfWeek = DateTime(weekStart.year, weekStart.month, weekStart.day);
      return records.where((r) => r.startTime.isAfter(startOfWeek)).toList();
    }
    return records;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('练习记录'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildFilterTabs(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _records.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadRecords,
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: _records.length + (_hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _records.length) {
                              return _buildLoadMoreIndicator();
                            }
                            final record = _records[index];
                            return _buildVideoItem(record);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: _isLoadingMore
          ? const CircularProgressIndicator()
          : TextButton(
              onPressed: _loadMoreRecords,
              child: const Text('点击加载更多'),
            ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildFilterChip('全部', 'all'),
          const SizedBox(width: 12),
          _buildFilterChip('本周', 'week'),
          const SizedBox(width: 12),
          _buildFilterChip('本月', 'month'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filter == value;
    return GestureDetector(
      onTap: () {
        setState(() => _filter = value);
        _loadRecords();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_library_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            '暂无练习记录',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '开始练琴并添加视频吧',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoItem(PracticeRecord record) {
    final hasVideo = record.videos.isNotEmpty;
    final video = hasVideo ? record.videos.first : null;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      decoration: AppTheme.cardDecoration(context),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final result = await VideoPlayerScreen.show(context, record);
            if (result == true) {
              _loadRecords();
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(context).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.schedule,
                                  size: 12,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  formatDurationChinese(record.duration),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color:
                                            Theme.of(context).colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            formatRelativeTime(record.startTime),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                          ),
                        ],
                      ),
                      if (record.notes != null && record.notes!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          record.notes!,
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (hasVideo) ...[
                  const SizedBox(width: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 60,
                      height: 60,
                      child: _buildThumbnail(video!),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(Video video) {
    if (video.thumbnailPath != null && File(video.thumbnailPath!).existsSync()) {
      return Image.file(
        File(video.thumbnailPath!),
        fit: BoxFit.cover,
      );
    }
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.videocam,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
