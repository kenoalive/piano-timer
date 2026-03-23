import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../utils/utils.dart';

class VideoPlayerScreen extends StatefulWidget {
  final PracticeRecord record;
  final int initialVideoIndex;

  /// 结果回调 - 当数据更新时返回 true
  static Future<bool?> show(BuildContext context, PracticeRecord record, {int initialVideoIndex = 0}) {
    return Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(
          record: record,
          initialVideoIndex: initialVideoIndex,
        ),
      ),
    );
  }

  const VideoPlayerScreen({
    super.key,
    required this.record,
    this.initialVideoIndex = 0,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  int _currentVideoIndex = 0;
  late TextEditingController _notesController;
  late PracticeRecord _record;
  bool _isEditing = false;
  bool _isFullScreen = false;
  bool _isAddingVideo = false;
  bool _hasDataChanged = false; // 标记数据是否有变更
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _record = widget.record;
    _currentVideoIndex = widget.initialVideoIndex;
    _notesController = TextEditingController(text: _record.notes ?? '');
    _initPlayer();
  }

  Future<void> _refreshRecord() async {
    final db = context.read<DatabaseService>();
    final updated = await db.getRecord(_record.id);
    if (updated != null && mounted) {
      setState(() {
        _record = updated;
      });
      // 如果有视频，重新初始化播放器
      if (_record.videos.isNotEmpty) {
        _currentVideoIndex = _record.videos.length - 1;
        await _initPlayer();
      }
    }
  }

  Future<void> _initPlayer() async {
    if (_record.videos.isEmpty) return;

    final video = _record.videos[_currentVideoIndex];
    final file = File(video.localPath);

    if (!file.existsSync()) {
      if (mounted) {
        AppTheme.showErrorDialog(context, '视频文件不存在');
      }
      return;
    }

    _videoController = VideoPlayerController.file(file);

    await _videoController!.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoController!,
      autoPlay: true,
      looping: false,
      allowFullScreen: true,
      allowMuting: true,
      showControls: true,
      placeholder: Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      ),
    );

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _switchVideo(int index) {
    if (index < 0 || index >= _record.videos.length) return;

    _chewieController?.dispose();
    _videoController?.dispose();

    setState(() {
      _currentVideoIndex = index;
    });

    _initPlayer();
  }

  Future<void> _saveNotes() async {
    final db = context.read<DatabaseService>();
    final updated = _record.copyWith(
      notes: _notesController.text,
      updatedAt: DateTime.now(),
    );
    await db.updateRecord(updated);

    setState(() {
      _record = updated;
      _isEditing = false;
      _hasDataChanged = true;
    });

    if (mounted) {
      AppTheme.showSuccessDialog(context, '笔记已保存');
    }
  }

  Future<void> _deleteRecord() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('将永久删除此练习记录和视频，此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('确认删除'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final db = context.read<DatabaseService>();
    final cloudService = context.read<CloudService>();

    for (final video in _record.videos) {
      await cloudService.deleteLocalVideo(video.localPath);
    }

    await db.deleteRecord(_record.id);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isFullScreen
          ? null
          : AppBar(
              title: const Text('练习详情'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context, _hasDataChanged),
              ),
              actions: [
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    if (value == 'delete') {
                      _deleteRecord();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('删除', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // 无视频的纯文本记录
    if (_record.videos.isEmpty) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPracticeDetails(),
            const SizedBox(height: 24),
            _buildNotesSection(),
            const SizedBox(height: 24),
            _buildActionButtons(),
          ],
        ),
      );
    }

    // 有视频的记录
    if (_chewieController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // 视频播放器
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Chewie(controller: _chewieController!),
        ),
        // 视频切换
        if (_record.videos.length > 1)
          _buildVideoSelector(),
        // 练习详情
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPracticeDetails(),
                const SizedBox(height: 24),
                _buildNotesSection(),
                const SizedBox(height: 24),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoSelector() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _record.videos.length,
        itemBuilder: (context, index) {
          final video = _record.videos[index];
          final isSelected = index == _currentVideoIndex;

          return GestureDetector(
            onTap: () => _switchVideo(index),
            child: Container(
              width: 60,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: _buildThumbnail(video),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildThumbnail(Video video) {
    if (video.thumbnailPath != null && File(video.thumbnailPath!).existsSync()) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.file(
            File(video.thumbnailPath!),
            fit: BoxFit.cover,
          ),
          Positioned(
            left: 2,
            bottom: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Text(
                formatDurationShort(video.duration),
                style: const TextStyle(color: Colors.white, fontSize: 8),
              ),
            ),
          ),
        ],
      );
    }
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Icon(Icons.videocam),
    );
  }

  Widget _buildPracticeDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📹 练习详情',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          _buildDetailRow('时长', formatDurationChinese(_record.duration)),
          const SizedBox(height: 8),
          _buildDetailRow('日期', formatDateTime(_record.startTime)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label：',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '📝 笔记',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (!_isEditing)
              TextButton.icon(
                onPressed: () => setState(() => _isEditing = true),
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('编辑'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        _isEditing
            ? TextField(
                controller: _notesController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: '输入笔记内容...',
                ),
              )
            : Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _record.notes?.isNotEmpty == true
                      ? _record.notes!
                      : '暂无笔记',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _record.notes?.isNotEmpty == true
                            ? null
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
      ],
    );
  }

  Future<void> _addVideo() async {
    final source = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('从相册选择'),
              onTap: () => Navigator.pop(context, 'gallery'),
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('拍摄视频'),
              onTap: () => Navigator.pop(context, 'camera'),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    setState(() => _isAddingVideo = true);

    try {
      final XFile? video = await _picker.pickVideo(
        source: source == 'gallery' ? ImageSource.gallery : ImageSource.camera,
      );

      if (video == null) {
        setState(() => _isAddingVideo = false);
        return;
      }

      final cloudService = context.read<CloudService>();
      final db = context.read<DatabaseService>();

      final newVideo = await cloudService.saveVideoToLocal(File(video.path));

      // 更新记录，添加视频
      final updatedVideos = [..._record.videos, newVideo];
      final updatedRecord = _record.copyWith(
        videos: updatedVideos,
        updatedAt: DateTime.now(),
      );

      await db.updateRecord(updatedRecord);

      if (mounted) {
        setState(() {
          _isAddingVideo = false;
          _hasDataChanged = true;
        });
        // 刷新当前页面的数据
        await _refreshRecord();
        // 显示成功对话框
        _showSuccessSnackBar();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAddingVideo = false);
        AppTheme.showErrorDialog(context, '添加视频失败: $e');
      }
    }
  }

  void _showSuccessSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                '视频添加成功',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        if (_isEditing) ...[
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                _notesController.text = _record.notes ?? '';
                setState(() => _isEditing = false);
              },
              child: const Text('取消'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _saveNotes,
              icon: const Icon(Icons.save),
              label: const Text('保存修改'),
            ),
          ),
        ] else ...[
          // 无视频记录 - 显示添加视频按钮
          if (_record.videos.isEmpty) ...[
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isAddingVideo ? null : _addVideo,
                icon: _isAddingVideo
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.videocam),
                label: Text(_isAddingVideo ? '添加中...' : '添加视频'),
              ),
            ),
          ] else ...[
            // 有视频记录 - 显示删除和分享
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _deleteRecord,
                icon: const Icon(Icons.delete, color: Colors.red),
                label: const Text('删除', style: TextStyle(color: Colors.red)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  AppTheme.showInfoDialog(context, '分享功能开发中');
                },
                icon: const Icon(Icons.share),
                label: const Text('分享'),
              ),
            ),
          ],
        ],
      ],
    );
  }
}
