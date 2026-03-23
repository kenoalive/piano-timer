import 'package:intl/intl.dart';

/// 格式化时长为 HH:MM:SS
String formatDuration(int seconds) {
  final hours = seconds ~/ 3600;
  final minutes = (seconds % 3600) ~/ 60;
  final secs = seconds % 60;

  if (hours > 0) {
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
  return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
}

/// 格式化时长为 X小时Y分钟
String formatDurationChinese(int seconds) {
  final hours = seconds ~/ 3600;
  final minutes = (seconds % 3600) ~/ 60;

  if (hours > 0 && minutes > 0) {
    return '$hours小时$minutes分钟';
  } else if (hours > 0) {
    return '$hours小时';
  } else if (minutes > 0) {
    return '$minutes分钟';
  }
  return '0分钟';
}

/// 格式化时长为 X分Y秒
String formatDurationShort(int seconds) {
  final minutes = seconds ~/ 60;
  final secs = seconds % 60;
  return '$minutes分${secs.toString().padLeft(2, '0')}秒';
}

/// 格式化日期
String formatDate(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final dateOnly = DateTime(date.year, date.month, date.day);

  if (dateOnly == today) {
    return '今天';
  } else if (dateOnly == yesterday) {
    return '昨天';
  } else if (date.year == now.year) {
    return DateFormat('M月d日').format(date);
  } else {
    return DateFormat('yyyy年M月d日').format(date);
  }
}

/// 格式化时间
String formatTime(DateTime time) {
  return DateFormat('HH:mm').format(time);
}

/// 格式化日期时间
String formatDateTime(DateTime dateTime) {
  return '${DateFormat('yyyy-MM-dd').format(dateTime)} ${formatTime(dateTime)}';
}

/// 格式化相对时间
String formatRelativeTime(DateTime dateTime) {
  final now = DateTime.now();
  final diff = now.difference(dateTime);

  if (diff.inMinutes < 1) {
    return '刚刚';
  } else if (diff.inMinutes < 60) {
    return '${diff.inMinutes}分钟前';
  } else if (diff.inHours < 24) {
    return '${diff.inHours}小时前';
  } else if (diff.inDays < 7) {
    return '${diff.inDays}天前';
  } else {
    return formatDate(dateTime);
  }
}

/// 格式化文件大小
String formatFileSize(int bytes) {
  if (bytes < 1024) {
    return '$bytes B';
  } else if (bytes < 1024 * 1024) {
    return '${(bytes / 1024).toStringAsFixed(1)} KB';
  } else if (bytes < 1024 * 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  } else {
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

/// 获取问候语
String getGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 6) {
    return '夜深了';
  } else if (hour < 9) {
    return '早上好';
  } else if (hour < 12) {
    return '上午好';
  } else if (hour < 14) {
    return '中午好';
  } else if (hour < 18) {
    return '下午好';
  } else if (hour < 22) {
    return '晚上好';
  } else {
    return '夜深了';
  }
}
