# 琴时 (Piano Timer) 🎹

一款用于记录钢琴练习时间的 Flutter 应用，支持视频录制、云端同步和统计分析。

## 功能特点

- ⏱️ 练习计时器（开始/暂停/停止）
- 📹 视频录制和上传（每次练习最多9个视频）
- ☁️ 云端同步（腾讯云 CloudBase）
- 📊 练习统计数据（周/月/年图表）
- 🔥 练习热力图
- 🎯 每日目标追踪

## 截图

| 首页 | 计时器 | 视频列表 | 统计 |
|------|--------|----------|------|
| ![Home](screenshots/home.png) | ![Timer](screenshots/timer.png) | ![Videos](screenshots/videos.png) | ![Stats](screenshots/stats.png) |

## 技术栈

- **框架**: Flutter 3.4+
- **语言**: Dart
- **状态管理**: flutter_bloc
- **本地数据库**: sqflite + shared_preferences
- **云服务**: 腾讯云 CloudBase
- **视频播放**: video_player + chewie
- **图表**: fl_chart

## 快速开始

### 环境要求

- Flutter 3.4+
- Android SDK / Xcode (iOS 开发)
- 腾讯云 CloudBase 账号

### 安装步骤

```bash
# 克隆仓库
git clone https://github.com/kenoalive/piano-timer.git
cd piano-timer

# 获取依赖
flutter pub get

# 运行
flutter run
```

### 配置

1. 创建腾讯云 CloudBase 环境
2. 修改 `lib/services/cloud_service.dart` 配置：
   ```dart
   static const String _envId = 'your-env-id';
   ```

## 项目结构

```
lib/
├── blocs/          # BLoC 状态管理
├── models/         # 数据模型
├── screens/        # 界面页面
├── services/       # 云端和数据库服务
├── utils/         # 工具类
└── widgets/       # 通用组件
```

## 许可证

MIT License
