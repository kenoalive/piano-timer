import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import '../blocs/blocs.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';
import 'video_player_screen.dart';
import 'complete_dialog.dart';
import 'metronome_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _notesController = TextEditingController();
  List<PracticeRecord> _recentRecords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecentRecords();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadRecentRecords() async {
    final db = context.read<DatabaseService>();
    final records = await db.getAllRecords();
    setState(() {
      _recentRecords = records.take(10).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, appState) {
        return BlocConsumer<TimerBloc, TimerState>(
          listener: (context, state) {
            if (state.error != null) {
              AppTheme.showErrorDialog(context, state.error!);
            }
          },
          builder: (context, timerState) {
            return Scaffold(
              body: SafeArea(
                child: RefreshIndicator(
                  onRefresh: _loadRecentRecords,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(appState),
                          const SizedBox(height: 24),
                          _buildTodayTotal(timerState),
                          const SizedBox(height: 32),
                          _buildTimer(timerState),
                          const SizedBox(height: 24),
                          _buildButtons(timerState),
                          if (!timerState.isIdle) ...[
                            const SizedBox(height: 24),
                            _buildNotesInput(timerState),
                          ],
                          const SizedBox(height: 24),
                          _buildGoalProgress(timerState, appState),
                          const SizedBox(height: 24),
                          _buildRecentNotes(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeader(AppState appState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${getGreeting()}，琴友',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.1),
            const SizedBox(height: 4),
            Text(
              '今天也要加油练习哦',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ).animate().fadeIn(delay: 100.ms, duration: 300.ms),
          ],
        ),
        // 节拍器按钮
        GestureDetector(
          onTap: () => MetronomeScreen.show(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.speed,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  '节拍器',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: 200.ms, duration: 300.ms).scale(begin: const Offset(0.9, 0.9)),
      ],
    );
  }

  Widget _buildTodayTotal(TimerState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF9575CD),
            Color(0xFFBA68C8),
            Color(0xFFF8BBD9),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9575CD).withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.music_note,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '今日累计',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            formatDurationChinese(state.todayTotalDuration),
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1);
  }

  Widget _buildTimer(TimerState state) {
    return Center(
      child: Column(
        children: [
          TimerDisplay(
            seconds: state.duration,
            isLarge: state.isRunning || state.isPaused,
          ).animate(
            target: state.isRunning ? 1 : 0,
          ).shimmer(
            duration: 1500.ms,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          ),
          if (state.isRunning)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ).animate(onPlay: (c) => c.repeat()).shimmer(
                          duration: 1000.ms,
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                        ),
                    const SizedBox(width: 6),
                    Text(
                      '练习中',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildButtons(TimerState state) {
    if (state.isIdle) {
      return Center(
        child: ElevatedButton.icon(
          onPressed: () {
            context.read<TimerBloc>().add(const TimerStarted());
          },
          icon: const Icon(Icons.play_arrow_rounded, size: 24),
          label: const Text('开始练琴', style: TextStyle(fontSize: 18)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.4),
          ),
        ).animate().scale(delay: 200.ms, duration: 300.ms),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (state.isRunning)
          ElevatedButton.icon(
            onPressed: () {
              context.read<TimerBloc>().add(const TimerPaused());
            },
            icon: const Icon(Icons.pause_rounded),
            label: const Text('暂停'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ).animate().fadeIn().slideX(begin: -0.2)
        else
          ElevatedButton.icon(
            onPressed: () {
              context.read<TimerBloc>().add(const TimerResumed());
            },
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('继续'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: () => _showCompleteDialog(state),
          icon: const Icon(Icons.check_rounded),
          label: const Text('完成'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ).animate().fadeIn().slideX(begin: 0.2),
      ],
    );
  }

  void _showCompleteDialog(TimerState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CompleteDialog(
        duration: state.duration,
        initialNotes: state.notes,
        onComplete: (notes, videos) {
          context.read<TimerBloc>().add(TimerCompleted(
                notes: notes,
                videos: videos,
              ));
          // 刷新各页面数据
          context.read<TimerBloc>().add(const TimerDataRefreshRequested());
          context.read<StatsBloc>().add(const StatsRefreshed());
          Navigator.pop(context);
          _loadRecentRecords();
        },
        onSkip: () {
          context.read<TimerBloc>().add(const TimerCompleted());
          // 刷新各页面数据
          context.read<TimerBloc>().add(const TimerDataRefreshRequested());
          context.read<StatsBloc>().add(const StatsRefreshed());
          Navigator.pop(context);
          _loadRecentRecords();
        },
      ),
    );
  }

  Widget _buildNotesInput(TimerState state) {
    return Container(
      decoration: AppTheme.cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.lavenderLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.edit_note,
                    size: 20,
                    color: AppColors.lavender,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '练习笔记',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            decoration: BoxDecoration(
              color: AppColors.lavenderContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.lavenderLight.withOpacity(0.5),
              ),
            ),
            child: TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: '记录一下今天的练习内容...',
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
                ),
              ),
              onChanged: (value) {
                context.read<TimerBloc>().add(TimerNotesUpdated(value));
              },
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1);
  }

  Widget _buildGoalProgress(TimerState state, AppState appState) {
    final goalSeconds = appState.dailyGoalMinutes * 60;
    final progress = goalSeconds > 0 ? state.todayTotalDuration / goalSeconds : 0.0;
    final isComplete = progress >= 1.0;

    return Container(
      decoration: AppTheme.cardDecoration(context),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isComplete ? AppColors.successContainer : AppColors.lavenderLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.flag,
                      size: 20,
                      color: isComplete ? AppColors.success : AppColors.lavender,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '今日目标',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isComplete ? AppColors.successContainer : AppColors.lavenderContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(progress * 100).toInt()}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isComplete ? AppColors.success : AppColors.lavender,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 10,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Stack(
                children: [
                  FractionallySizedBox(
                    widthFactor: progress.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: isComplete
                            ? AppColors.tealGradient
                            : AppColors.primaryGradient,
                      ),
                    ),
                  ).animate().scaleX(
                        begin: 0,
                        alignment: Alignment.centerLeft,
                        duration: 500.ms,
                        curve: Curves.easeOutCubic,
                      ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '目标: ${appState.dailyGoalMinutes}分钟',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              Text(
                '已练习 ${formatDurationChinese(state.todayTotalDuration)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isComplete ? AppColors.teal : AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentNotes() {
    if (_isLoading) {
      return _buildLoadingShimmer();
    }

    if (_recentRecords.isEmpty) {
      return const SizedBox.shrink();
    }

    // 显示最近的练习记录（包括有视频或有笔记的）
    final displayRecords = _recentRecords
        .where((r) => r.videos.isNotEmpty || (r.notes != null && r.notes!.isNotEmpty))
        .take(5)
        .toList();

    if (displayRecords.isEmpty) {
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.note_alt,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '最近笔记',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...displayRecords.asMap().entries.map((entry) {
          final index = entry.key;
          final record = entry.value;
          return _buildNoteCard(record).animate().fadeIn(
                delay: Duration(milliseconds: 100 * index.toInt()),
                duration: 300.ms,
              );
        }),
      ],
    );
  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      highlightColor: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 100,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(PracticeRecord record) {
    final hasVideo = record.videos.isNotEmpty;
    final video = hasVideo ? record.videos.first : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppTheme.cardDecoration(context),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final result = await VideoPlayerScreen.show(context, record);
            if (result == true) {
              _loadRecentRecords();
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
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
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
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            formatRelativeTime(record.startTime),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        record.notes ?? '',
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (hasVideo) ...[
                  const SizedBox(width: 12),
                  // 视频缩略图 - 正方形
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
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
