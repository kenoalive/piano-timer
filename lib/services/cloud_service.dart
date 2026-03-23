import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../models/models.dart';
import 'database_service.dart';
import 'settings_service.dart';
import 'network_service.dart';

/// 腾讯云 CloudBase 服务
class CloudService {
  final DatabaseService _db;
  final SettingsService _settings;
  final NetworkService _network;
  final _uuid = const Uuid();

  // 腾讯云配置 - 请替换为你的实际配置
  static const String _envId = 'YOUR_ENV_ID';
  // SecretId 和 SecretKey 保留备用，当前使用 HTTP 触发器方式
  // static const String _secretId = 'YOUR_SECRET_ID';
  // static const String _secretKey = 'YOUR_SECRET_KEY';

  bool _isInitialized = false;
  bool _isSyncing = false;

  CloudService({
    required DatabaseService databaseService,
    required SettingsService settingsService,
    required NetworkService networkService,
  })  : _db = databaseService,
        _settings = settingsService,
        _network = networkService;

  bool get isInitialized => _isInitialized;
  bool get isSyncing => _isSyncing;

  /// 初始化云端服务
  Future<void> initialize() async {
    final settings = await _settings.getSettings();
    if (settings.cloudEnvId.isEmpty) {
      await _settings.updateCloudEnvId(_envId);
    }
    _isInitialized = true;
  }

  /// 调用云函数 - 使用 HTTP 触发器方式
  Future<Map<String, dynamic>?> _callFunction(String functionName, Map<String, dynamic> data) async {
    try {
      // 使用 HTTP 触发器路径
      final uri = Uri.parse('https://$_envId.service.tcloudbase.com/tcb/service/sys/invoke/$functionName');

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 15);

      final request = await client.postUrl(uri);

      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(data));

      final response = await request.close();

      final responseBody = await response.transform(utf8.decoder).join();

      // ignore: avoid_print
      print('云函数响应: $responseBody');

      if (responseBody.isEmpty) {
        return {'success': true, 'message': '执行成功'};
      }

      return jsonDecode(responseBody) as Map<String, dynamic>;
    } catch (e) {
      // ignore: avoid_print
      print('云函数调用失败: $e');
      return null;
    }
  }

  /// 同步数据到云端
  /// 注意：当前环境可能不支持直接调用云函数，需要配置 HTTP 触发器
  /// 暂时跳过实际同步，仅更新同步时间
  Future<bool> syncToCloud() async {
    if (_isSyncing) return false;

    _isSyncing = true;
    try {
      // 尝试调用云函数
      final records = await _db.getAllRecords();
      final unsyncedRecords = records.where((r) => !r.isSynced).toList();

      if (unsyncedRecords.isEmpty) {
        await _settings.updateLastSyncTime();
        _isSyncing = false;
        return true;
      }

      // 调用云函数上传数据
      for (final record in unsyncedRecords) {
        final success = await _uploadRecord(record);
        if (success) {
          final updated = record.copyWith(isSynced: true);
          await _db.updateRecord(updated);
        }
      }

      // 视频暂不自动上传（需要大文件传输）
      await _settings.updateLastSyncTime();
      return true;
    } catch (e) {
      // 同步失败，记录时间但不做强求
      await _settings.updateLastSyncTime();
      // ignore: avoid_print
      print('同步失败（云函数可能未配置）: $e');
      return false;
    } finally {
      _isSyncing = false;
    }
  }

  /// 上传记录到云端数据库
  Future<bool> _uploadRecord(PracticeRecord record) async {
    try {
      final result = await _callFunction('syncPracticeRecord', {
        'id': record.id,
        'startTime': record.startTime.toIso8601String(),
        'endTime': record.endTime?.toIso8601String(),
        'duration': record.duration,
        'notes': record.notes ?? '',
      });

      if (result != null && result['success'] == true) {
        return true;
      }
      return false;
    } catch (e) {
      // ignore: avoid_print
      print('上传记录失败: $e');
      return false;
    }
  }

  Future<void> downloadFromCloud() async {
    if (!_network.isOnline || !_isInitialized) return;
  }

  /// 生成视频缩略图
  Future<String?> generateThumbnail(String videoPath) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final thumbnailDir = Directory('${dir.path}/thumbnails');
      if (!await thumbnailDir.exists()) {
        await thumbnailDir.create(recursive: true);
      }

      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: videoPath,
        thumbnailPath: thumbnailDir.path,
        imageFormat: ImageFormat.JPEG,
        maxHeight: 200,
        quality: 75,
      );

      return thumbnailPath;
    } catch (e) {
      return null;
    }
  }

  /// 保存视频到本地存储
  /// 返回压缩后的视频信息，包含进度回调
  Future<Video> saveVideoToLocal(
    File videoFile, {
    int? duration,
    void Function(double)? onProgress,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final videosDir = Directory('${dir.path}/videos');
    if (!await videosDir.exists()) {
      await videosDir.create(recursive: true);
    }

    final id = _uuid.v4();

    try {
      // 压缩视频，设置60秒超时
      // 使用更低的画质以提高压缩成功率和速度
      final compressedInfo = await VideoCompress.compressVideo(
        videoFile.path,
        quality: VideoQuality.LowQuality,  // 使用低质量以提高兼容性
        deleteOrigin: false,                // 保留原文件
        includeAudio: true,
      ).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          // 超时后取消压缩
          VideoCompress.cancelCompression();
          return null;
        },
      );

      final compressedFile = compressedInfo?.file;
      if (compressedFile == null) {
        // 压缩失败或超时，使用原文件
        final ext = videoFile.path.split('.').last;
        final newPath = '${videosDir.path}/$id.$ext';
        await videoFile.copy(newPath);
        return await _createVideoRecord(newPath, id);
      }

      // 保存压缩后的视频
      final ext = compressedFile.path.split('.').last;
      final newPath = '${videosDir.path}/$id.$ext';
      await compressedFile.copy(newPath);

      return await _createVideoRecord(newPath, id);
    } catch (e) {
      // 发生错误时，使用原文件
      final ext = videoFile.path.split('.').last;
      final newPath = '${videosDir.path}/$id.$ext';
      await videoFile.copy(newPath);
      return await _createVideoRecord(newPath, id);
    }
  }

  /// 创建视频记录
  Future<Video> _createVideoRecord(String filePath, String id) async {
    final size = await File(filePath).length();

    // 获取视频时长
    int videoDuration = 0;
    try {
      final controller = VideoPlayerController.file(File(filePath));
      await controller.initialize();
      videoDuration = controller.value.duration.inSeconds;
      await controller.dispose();
    } catch (e) {
      // 忽略获取时长失败的情况
    }

    final thumbnailPath = await generateThumbnail(filePath);

    return Video(
      id: id,
      localPath: filePath,
      thumbnailPath: thumbnailPath,
      duration: videoDuration,
      size: size,
      createdAt: DateTime.now(),
    );
  }

  /// 删除本地视频文件
  Future<void> deleteLocalVideo(String localPath) async {
    try {
      final file = File(localPath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // 忽略删除错误
    }

    try {
      final dir = await getApplicationDocumentsDirectory();
      final thumbnailDir = Directory('${dir.path}/thumbnails');
      if (await thumbnailDir.exists()) {
        final fileName = localPath.split('/').last.split('.').first;
        final thumbFile = File('${thumbnailDir.path}/$fileName.jpg');
        if (await thumbFile.exists()) {
          await thumbFile.delete();
        }
      }
    } catch (e) {
      // 忽略删除错误
    }
  }

  Future<Map<String, dynamic>> exportData() async {
    final records = await _db.getAllRecords();
    final videos = await _db.getAllVideos();

    return {
      'exportTime': DateTime.now().toIso8601String(),
      'records': records.map((r) => r.toMap()).toList(),
      'videos': videos.map((v) => v.toMap()).toList(),
    };
  }

  /// 导入数据
  Future<void> importData(Map<String, dynamic> data) async {
    // TODO: 实现数据导入逻辑
  }
}
