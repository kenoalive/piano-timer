import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MetronomeScreen extends StatefulWidget {
  static void show(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MetronomeScreen()),
    );
  }

  const MetronomeScreen({super.key});

  @override
  State<MetronomeScreen> createState() => _MetronomeScreenState();
}

class _MetronomeScreenState extends State<MetronomeScreen> {
  int _bpm = 120;
  bool _isPlaying = false;
  Timer? _timer;
  int _beatCount = 0;
  final Stopwatch _stopwatch = Stopwatch();
  bool _soundEnabled = true;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startMetronome() {
    setState(() {
      _isPlaying = true;
      _beatCount = 0;
    });
    _stopwatch.reset();
    _stopwatch.start();
    _scheduleNextBeat();
  }

  void _stopMetronome() {
    _timer?.cancel();
    _stopwatch.stop();
    _stopwatch.reset();
    setState(() {
      _isPlaying = false;
      _beatCount = 0;
    });
  }

  void _scheduleNextBeat() {
    if (!_isPlaying) return;

    final intervalMs = (60000 / _bpm).round();
    final elapsed = _stopwatch.elapsedMilliseconds;
    final nextDelay = intervalMs - (elapsed % intervalMs);

    _timer = Timer(Duration(milliseconds: nextDelay), () {
      if (_isPlaying) {
        _onBeat();
        _stopwatch.reset();
        _stopwatch.start();
        _scheduleNextBeat();
      }
    });
  }

  void _playSound(bool isAccent) async {
    if (!_soundEnabled) return;
    try {
      // 播放系统提示音作为节拍声
      await SystemSound.play(isAccent ? SystemSoundType.click : SystemSoundType.click);
    } catch (e) {
      // 播放失败时只使用震动
    }
  }

  void _onBeat() {
    final isFirstBeat = _beatCount == 0;
    // 播放声音（第一拍重音，其他轻音）
    _playSound(isFirstBeat);
    // 震动反馈
    HapticFeedback.heavyImpact();
    setState(() {
      _beatCount = (_beatCount + 1) % 4;
    });
  }

  void _setBpm(int bpm) {
    setState(() {
      _bpm = bpm.clamp(40, 240);
    });
    if (_isPlaying) {
      _timer?.cancel();
      _stopwatch.reset();
      _stopwatch.start();
      _scheduleNextBeat();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('节拍器'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _stopMetronome();
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildBeatIndicator(),
                const SizedBox(height: 24),
                _buildBpmDisplay(),
                const SizedBox(height: 16),
                _buildBpmShortcuts(),
                const SizedBox(height: 16),
                _buildBpmSlider(),
                const SizedBox(height: 16),
                _buildBpmControls(),
                const SizedBox(height: 24),
                _buildPlayButton(),
                const SizedBox(height: 16),
                _buildSoundToggle(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBpmShortcuts() {
    final shortcuts = [70, 80, 90, 100];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: shortcuts.map((bpm) {
        final isSelected = _bpm == bpm;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: GestureDetector(
            onTap: () => _setBpm(bpm),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$bpm',
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBeatIndicator() {
    return Container(
      height: 120,
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(4, (index) {
          final isActive = _isPlaying && _beatCount == index;
          final isFirstBeat = index == 0;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 50),
            width: isActive ? 40 : 28,
            height: isActive ? 100 : 80,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isActive
                  ? (isFirstBeat
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.secondary)
                  : (isFirstBeat
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.surfaceContainerHighest),
              borderRadius: BorderRadius.circular(16),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: (isFirstBeat
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.secondary)
                            .withOpacity(0.6),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ]
                  : null,
            ),
          ).animate(target: isActive ? 1 : 0).scale(
                begin: const Offset(1, 1),
                end: const Offset(1.3, 1.2),
                duration: 80.ms,
              );
        }),
      ),
    );
  }

  Widget _buildBpmDisplay() {
    return Column(
      children: [
        Text(
          '$_bpm',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        Text(
          'BPM',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Widget _buildBpmSlider() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: 8,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
          activeTrackColor: Theme.of(context).colorScheme.primary,
          inactiveTrackColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          thumbColor: Theme.of(context).colorScheme.primary,
          overlayColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        ),
        child: Slider(
          value: _bpm.toDouble(),
          min: 40,
          max: 240,
          onChanged: (value) => _setBpm(value.round()),
        ),
      ),
    );
  }

  Widget _buildBpmControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTextButton('-1', () => _setBpm(_bpm - 1)),
        const SizedBox(width: 8),
        _buildTextButton('-5', () => _setBpm(_bpm - 5)),
        const SizedBox(width: 24),
        _buildTextButton('+5', () => _setBpm(_bpm + 5)),
        const SizedBox(width: 8),
        _buildTextButton('+1', () => _setBpm(_bpm + 1)),
      ],
    );
  }

  Widget _buildTextButton(String text, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 56,
        height: 44,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildPlayButton() {
    return GestureDetector(
      onTap: _isPlaying ? _stopMetronome : _startMetronome,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: _isPlaying ? 80 : 100,
        height: _isPlaying ? 80 : 100,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _isPlaying
                ? [Colors.red.shade400, Colors.red.shade600]
                : [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.tertiary,
                  ],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (_isPlaying
                      ? Colors.red
                      : Theme.of(context).colorScheme.primary)
                  .withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(
          _isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
          color: Colors.white,
          size: _isPlaying ? 40 : 48,
        ),
      ),
    ).animate(target: _isPlaying ? 1 : 0).scale(
          begin: const Offset(1, 1),
          end: const Offset(1.05, 1.05),
          duration: 500.ms,
        );
  }

  Widget _buildSoundToggle() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _soundEnabled = !_soundEnabled;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: _soundEnabled
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _soundEnabled ? Icons.volume_up : Icons.volume_off,
              size: 20,
              color: _soundEnabled
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              _soundEnabled ? '声音已开启' : '声音已关闭',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _soundEnabled
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
