import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';

class CompleteDialog extends StatefulWidget {
  final int duration;
  final String initialNotes;
  final Function(String notes, List<Video> videos) onComplete;
  final VoidCallback onSkip;

  const CompleteDialog({
    super.key,
    required this.duration,
    required this.initialNotes,
    required this.onComplete,
    required this.onSkip,
  });

  @override
  State<CompleteDialog> createState() => _CompleteDialogState();
}

class _CompleteDialogState extends State<CompleteDialog> {
  late TextEditingController _notesController;
  final FocusNode _notesFocusNode = FocusNode();
  final List<Video> _selectedVideos = [];
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.initialNotes);
    // 点击外部取消焦点
    _notesFocusNode.addListener(() {
      if (!_notesFocusNode.hasFocus) {
        // 失去焦点时刷新状态
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    _notesFocusNode.dispose();
    super.dispose();
  }

  Future<void> _pickFromGallery() async {
    try {
      // 优先尝试 pickMultipleMedia，如果不支持则降级为 pickVideo
      List<XFile> videos;
      try {
        videos = await _picker.pickMultipleMedia();
        if (videos.isEmpty) return;
      } catch (_) {
        // 降级方案：选择单个视频
        final video = await _picker.pickVideo(source: ImageSource.gallery);
        videos = video != null ? [video] : [];
        if (videos.isEmpty) return;
      }

      final cloudService = context.read<CloudService>();
      final existingCount = _selectedVideos.length;
      final remaining = 9 - existingCount;

      if (remaining <= 0) {
        if (mounted) {
          AppTheme.showErrorDialog(context, '最多只能添加9个视频');
        }
        return;
      }

      setState(() => _isLoading = true);

      for (int i = 0; i < videos.length && _selectedVideos.length < 9; i++) {
        final path = videos[i].path;
        // 过滤只接受视频文件
        final ext = path.split('.').last.toLowerCase();
        final videoExts = ['mp4', 'mov', 'avi', 'mkv', '3gp', 'webm', 'm4v'];

        if (!videoExts.contains(ext)) {
          continue;
        }

        try {
          final file = File(path);
          final video = await cloudService.saveVideoToLocal(file);
          setState(() {
            _selectedVideos.add(video);
          });
        } catch (e) {
          // 单个视频失败不影响其他视频
          continue;
        }
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        AppTheme.showErrorDialog(context, '选择视频失败: $e');
      }
    }
  }

  Future<void> _recordVideo() async {
    try {
      final video = await _picker.pickVideo(source: ImageSource.camera);
      if (video == null) return;

      if (_selectedVideos.length >= 9) {
        if (mounted) {
          AppTheme.showErrorDialog(context, '最多只能添加9个视频');
        }
        return;
      }

      setState(() => _isLoading = true);

      final cloudService = context.read<CloudService>();
      final savedVideo = await cloudService.saveVideoToLocal(File(video.path));

      setState(() {
        _selectedVideos.add(savedVideo);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        AppTheme.showErrorDialog(context, '录制视频失败: $e');
      }
    }
  }

  void _removeVideo(int index) {
    setState(() {
      _selectedVideos.removeAt(index);
    });
  }

  void _showVideoSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('从相册选择'),
              onTap: () {
                Navigator.pop(context);
                _pickFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('拍摄视频'),
              onTap: () {
                Navigator.pop(context);
                _recordVideo();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDuration(),
                  const SizedBox(height: 24),
                  _buildNotesInput(),
                  const SizedBox(height: 24),
                  _buildVideoSection(),
                ],
              ),
            ),
          ),
          _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.celebration,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '练琴完成',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildDuration() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '本次练习',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
          ),
          const SizedBox(height: 6),
          Text(
            formatDurationChinese(widget.duration),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: AppTheme.iconContainerDecoration(
                context,
                Theme.of(context).colorScheme.primary,
              ),
              child: Icon(
                Icons.edit_note,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '练习笔记',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
            ),
          ),
          child: TextField(
            focusNode: _notesFocusNode,
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: '今天练习了...',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: AppTheme.iconContainerDecoration(
                context,
                Theme.of(context).colorScheme.secondary,
              ),
              child: Icon(
                Icons.videocam,
                size: 18,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '视频 (${_selectedVideos.length}/9)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: _selectedVideos.length + (_selectedVideos.length < 9 ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _selectedVideos.length) {
                return VideoThumbnailPlaceholder(
                  onTap: () => _showVideoSourceDialog(),
                );
              }

              final video = _selectedVideos[index];
              return VideoThumbnail(
                thumbnailPath: video.thumbnailPath,
                localPath: video.localPath,
                duration: video.duration,
                onDelete: () => _removeVideo(index),
              );
            },
          ),
      ],
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: widget.onSkip,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('跳过'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () {
                  widget.onComplete(_notesController.text, _selectedVideos);
                },
                icon: const Icon(Icons.check),
                label: const Text('保存记录'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
