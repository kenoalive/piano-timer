import 'package:flutter/material.dart';

class AppColors {
  // ==================== 主色系 - 温柔淡紫 ====================
  static const Color primary = Color(0xFF9575CD);
  static const Color primaryLight = Color(0xFFB39DDB);
  static const Color primaryDark = Color(0xFF7E57C2);
  static const Color primaryContainer = Color(0xFFEDE7F6);
  static const Color onPrimary = Colors.white;
  static const Color onPrimaryContainer = Color(0xFF311B92);

  // ==================== 辅助色系 - 柔和水粉 ====================
  static const Color secondary = Color(0xFFF8BBD9);
  static const Color secondaryLight = Color(0xFFFCE4EC);
  static const Color secondaryContainer = Color(0xFFFCE4EC);
  static const Color onSecondary = Color(0xFF4A148C);
  static const Color onSecondaryContainer = Color(0xFF4A148C);

  // ==================== 彩色辅助色 ====================
  // 清新蓝 - 用于统计、数据
  static const Color blue = Color(0xFF64B5F6);
  static const Color blueLight = Color(0xFFBBDEFB);
  static const Color blueContainer = Color(0xFFE3F2FD);

  // 活力橙 - 用于警告、 streaks
  static const Color orange = Color(0xFFFFB74D);
  static const Color orangeLight = Color(0xFFFFE0B2);
  static const Color orangeContainer = Color(0xFFFFF3E0);

  // 珊瑚红 - 用于错误
  static const Color coral = Color(0xFFEF5350);
  static const Color coralLight = Color(0xFFFFCDD2);
  static const Color coralContainer = Color(0xFFFFEBEE);

  // 薰衣草紫 - 用于视频、笔记
  static const Color lavender = Color(0xFFBA68C8);
  static const Color lavenderLight = Color(0xFFE1BEE7);
  static const Color lavenderContainer = Color(0xFFF3E5F5);

  // 青色 - 用于日历
  static const Color teal = Color(0xFF26A69A);
  static const Color tealLight = Color(0xFFB2DFDB);
  static const Color tealContainer = Color(0xFFE0F2F1);

  // 玫瑰粉 - 用于强调
  static const Color pink = Color(0xFFF06292);
  static const Color pinkLight = Color(0xFFF8BBD9);
  static const Color pinkContainer = Color(0xFFFCE4EC);

  // ==================== 功能色 ====================
  static const Color success = Color(0xFF66BB6A);
  static const Color successContainer = Color(0xFFC8E6C9);
  static const Color error = Color(0xFFEF5350);
  static const Color errorContainer = Color(0xFFFFCDD2);
  static const Color warning = Color(0xFFFFB74D);
  static const Color warningContainer = Color(0xFFFFE0B2);

  // ==================== 中性色 ====================
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F0F0);
  static const Color onBackground = Color(0xFF212121);
  static const Color onSurface = Color(0xFF212121);
  static const Color onSurfaceVariant = Color(0xFF757575);
  static const Color outline = Color(0xFFBDBDBD);
  static const Color outlineVariant = Color(0xFFE0E0E0);

  // ==================== 渐变色 ====================
  // 淡紫浪漫渐变
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF9575CD), Color(0xFFF8BBD9)],
  );

  // 清新蓝渐变
  static const LinearGradient blueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF64B5F6), Color(0xFF90CAF9)],
  );

  // 玫瑰粉渐变
  static const LinearGradient pinkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF06292), Color(0xFFF8BBD9)],
  );

  // 活力橙渐变
  static const LinearGradient orangeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFB74D), Color(0xFFFFCC80)],
  );

  // 薰衣草渐变
  static const LinearGradient lavenderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFBA68C8), Color(0xFFCE93D8)],
  );

  // 青色渐变
  static const LinearGradient tealGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF26A69A), Color(0xFF4DB6AC)],
  );

  // 晚霞渐变
  static const LinearGradient sunsetGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF7043), Color(0xFFFFB74D)],
  );

  // 晨曦渐变
  static const LinearGradient sunriseGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFB74D), Color(0xFFFFD54F)],
  );

  // ==================== 深色主题 ====================
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color surfaceVariantDark = Color(0xFF2C2C2C);
  static const Color onBackgroundDark = Color(0xFFE0E0E0);
  static const Color onSurfaceDark = Color(0xFFE0E0E0);
  static const Color onSurfaceVariantDark = Color(0xFF9E9E9E);
  static const Color primaryDarkMode = Color(0xFFB388FF);
  static const Color primaryContainerDark = Color(0xFF4A148C);
}

class AppTheme {
  // 统一的卡片样式参数
  static const double cardRadius = 16.0;
  static const double cardPadding = 16.0;
  static const double iconContainerRadius = 12.0;
  static const double iconContainerSize = 40.0;

  // 显示成功 SnackBar
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // 显示错误 SnackBar
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // 显示信息 SnackBar
  static void showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // 兼容旧方法名
  static void showSuccessDialog(BuildContext context, String message) {
    showSuccessSnackBar(context, message);
  }

  static void showErrorDialog(BuildContext context, String message) {
    showErrorSnackBar(context, message);
  }

  static void showInfoDialog(BuildContext context, String message, {String? title}) {
    showInfoSnackBar(context, message);
  }

  // 统一的卡片构建器
  static BoxDecoration cardDecoration(BuildContext context, {
    bool hasBorder = true,
    bool hasShadow = true,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      borderRadius: BorderRadius.circular(cardRadius),
      border: hasBorder ? Border.all(
        color: Theme.of(context).colorScheme.outline.withOpacity(0.15),
      ) : null,
      boxShadow: hasShadow ? [
        BoxShadow(
          color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ] : null,
    );
  }

  // 统一的图标容器构建器
  static BoxDecoration iconContainerDecoration(BuildContext context, Color color) {
    return BoxDecoration(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(iconContainerRadius),
    );
  }

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      primaryContainer: AppColors.primaryContainer,
      secondary: AppColors.secondary,
      secondaryContainer: AppColors.secondaryContainer,
      error: AppColors.error,
      errorContainer: AppColors.errorContainer,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      surfaceContainerHighest: AppColors.surfaceVariant,
      outline: AppColors.outline,
    ),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.onBackground,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardRadius),
      ),
      color: AppColors.surface,
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceVariant.withOpacity(0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primary,
      linearTrackColor: AppColors.surfaceVariant,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.surfaceVariant,
      thickness: 1,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      elevation: 0,
      indicatorColor: AppColors.primaryContainer,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          );
        }
        return TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: AppColors.onSurfaceVariant,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.primary, size: 24);
        }
        return IconThemeData(color: AppColors.onSurfaceVariant, size: 24);
      }),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryDarkMode,
      brightness: Brightness.dark,
      primary: AppColors.primaryDarkMode,
      primaryContainer: AppColors.primaryContainerDark,
      secondary: AppColors.secondary,
      secondaryContainer: AppColors.secondaryContainer,
      error: AppColors.error,
      errorContainer: AppColors.errorContainer,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.onSurfaceDark,
      surfaceContainerHighest: AppColors.surfaceVariantDark,
      outline: AppColors.outline,
    ),
    scaffoldBackgroundColor: AppColors.backgroundDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.backgroundDark,
      foregroundColor: AppColors.onBackgroundDark,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardRadius),
      ),
      color: AppColors.surfaceDark,
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceVariantDark.withOpacity(0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryDarkMode, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primaryDarkMode,
      linearTrackColor: AppColors.surfaceVariantDark,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.surfaceVariantDark,
      thickness: 1,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surfaceDark,
      elevation: 0,
      indicatorColor: AppColors.primaryContainerDark.withOpacity(0.3),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryDarkMode,
          );
        }
        return TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: AppColors.onSurfaceVariantDark,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.primaryDarkMode, size: 24);
        }
        return IconThemeData(color: AppColors.onSurfaceVariantDark, size: 24);
      }),
    ),
  );
}
