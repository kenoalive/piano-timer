import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/models.dart';

class DatabaseService {
  static Database? _database;
  static const String _dbName = 'practice_timer.db';
  static const int _dbVersion = 1;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // 练习记录表
    await db.execute('''
      CREATE TABLE practice_records (
        id TEXT PRIMARY KEY,
        startTime TEXT NOT NULL,
        endTime TEXT,
        duration INTEGER NOT NULL,
        notes TEXT,
        isSynced INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // 视频表
    await db.execute('''
      CREATE TABLE videos (
        id TEXT PRIMARY KEY,
        recordId TEXT NOT NULL,
        localPath TEXT NOT NULL,
        cloudPath TEXT,
        thumbnailPath TEXT,
        duration INTEGER NOT NULL,
        size INTEGER NOT NULL,
        isSynced INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (recordId) REFERENCES practice_records (id) ON DELETE CASCADE
      )
    ''');

    // 创建索引
    await db.execute('CREATE INDEX idx_records_startTime ON practice_records (startTime)');
    await db.execute('CREATE INDEX idx_videos_recordId ON videos (recordId)');
  }

  // 练习记录 CRUD
  Future<void> insertRecord(PracticeRecord record) async {
    final db = await database;
    await db.insert(
      'practice_records',
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateRecord(PracticeRecord record) async {
    final db = await database;
    await db.update(
      'practice_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );

    // 同步更新视频列表
    // 先获取现有视频的ID
    final existingVideos = await getVideosByRecordId(record.id);
    final existingVideoIds = existingVideos.map((v) => v.id).toSet();
    final newVideoIds = record.videos.map((v) => v.id).toSet();

    // 删除不存在的视频
    for (final existing in existingVideos) {
      if (!newVideoIds.contains(existing.id)) {
        await deleteVideo(existing.id);
      }
    }

    // 添加或更新视频
    for (final video in record.videos) {
      if (!existingVideoIds.contains(video.id)) {
        await insertVideo(record.id, video);
      }
    }
  }

  Future<void> deleteRecord(String id) async {
    final db = await database;
    await db.delete('practice_records', where: 'id = ?', whereArgs: [id]);
  }

  Future<PracticeRecord?> getRecord(String id) async {
    final db = await database;
    final maps = await db.query(
      'practice_records',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;

    final videos = await getVideosByRecordId(id);
    return PracticeRecord.fromMap(maps.first, videos: videos);
  }

  Future<List<PracticeRecord>> getAllRecords() async {
    final db = await database;
    final maps = await db.query(
      'practice_records',
      orderBy: 'startTime DESC',
    );

    final records = <PracticeRecord>[];
    for (final map in maps) {
      final id = map['id'] as String;
      final videos = await getVideosByRecordId(id);
      records.add(PracticeRecord.fromMap(map, videos: videos));
    }
    return records;
  }

  /// 分页获取练习记录
  /// [page] 页码，从1开始
  /// [pageSize] 每页数量
  /// [hasContent] 是否只获取有视频或笔记的记录
  Future<List<PracticeRecord>> getRecordsPaginated({
    int page = 1,
    int pageSize = 20,
    bool hasContent = true,
  }) async {
    final db = await database;

    // 如果需要过滤有内容的记录，先获取所有记录再过滤
    if (hasContent) {
      final allRecords = await getAllRecords();
      final filtered = allRecords
          .where((r) => r.videos.isNotEmpty || (r.notes?.isNotEmpty ?? false))
          .toList();

      final start = (page - 1) * pageSize;
      final end = start + pageSize;

      if (start >= filtered.length) {
        return [];
      }
      return filtered.sublist(start, end > filtered.length ? filtered.length : end);
    }

    // 直接分页查询
    final offset = (page - 1) * pageSize;
    final maps = await db.query(
      'practice_records',
      orderBy: 'startTime DESC',
      limit: pageSize,
      offset: offset,
    );

    final records = <PracticeRecord>[];
    for (final map in maps) {
      final id = map['id'] as String;
      final videos = await getVideosByRecordId(id);
      records.add(PracticeRecord.fromMap(map, videos: videos));
    }
    return records;
  }

  /// 获取记录总数
  Future<int> getRecordsCount({bool hasContent = true}) async {
    final db = await database;
    final maps = await db.query('practice_records', orderBy: 'startTime DESC');

    if (hasContent) {
      int count = 0;
      for (final map in maps) {
        final id = map['id'] as String;
        final videos = await getVideosByRecordId(id);
        final notes = map['notes'] as String?;
        if (videos.isNotEmpty || (notes?.isNotEmpty ?? false)) {
          count++;
        }
      }
      return count;
    }

    return maps.length;
  }

  Future<List<PracticeRecord>> getRecordsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await database;
    final maps = await db.query(
      'practice_records',
      where: 'startTime >= ? AND startTime < ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'startTime DESC',
    );

    final records = <PracticeRecord>[];
    for (final map in maps) {
      final id = map['id'] as String;
      final videos = await getVideosByRecordId(id);
      records.add(PracticeRecord.fromMap(map, videos: videos));
    }
    return records;
  }

  Future<PracticeRecord?> getRunningRecord() async {
    final db = await database;
    final maps = await db.query(
      'practice_records',
      where: 'endTime IS NULL',
      limit: 1,
    );
    if (maps.isEmpty) return null;

    final id = maps.first['id'] as String;
    final videos = await getVideosByRecordId(id);
    return PracticeRecord.fromMap(maps.first, videos: videos);
  }

  Future<int> getTodayTotalDuration() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final db = await database;
    final result = await db.rawQuery('''
      SELECT COALESCE(SUM(duration), 0) as total
      FROM practice_records
      WHERE startTime >= ? AND startTime < ? AND endTime IS NOT NULL
    ''', [startOfDay.toIso8601String(), endOfDay.toIso8601String()]);

    return (result.first['total'] as int?) ?? 0;
  }

  Future<int> getConsecutiveDays() async {
    final records = await getAllRecords();
    if (records.isEmpty) return 0;

    final practicedDays = <String>{};
    for (final record in records) {
      if (record.endTime != null) {
        final day = DateTime(
          record.startTime.year,
          record.startTime.month,
          record.startTime.day,
        ).toIso8601String().split('T').first;
        practicedDays.add(day);
      }
    }

    if (practicedDays.isEmpty) return 0;

    final sortedDays = practicedDays.toList()..sort((a, b) => b.compareTo(a));
    final today = DateTime.now();
    final todayStr = DateTime(today.year, today.month, today.day)
        .toIso8601String()
        .split('T')
        .first;

    // 检查今天或昨天是否有练习
    if (sortedDays.first != todayStr) {
      final yesterday = DateTime(today.year, today.month, today.day - 1)
          .toIso8601String()
          .split('T')
          .first;
      if (sortedDays.first != yesterday) return 0;
    }

    int consecutive = 1;
    for (int i = 0; i < sortedDays.length - 1; i++) {
      final current = DateTime.parse(sortedDays[i]);
      final next = DateTime.parse(sortedDays[i + 1]);
      if (current.difference(next).inDays == 1) {
        consecutive++;
      } else {
        break;
      }
    }

    return consecutive;
  }

  Future<Map<String, int>> getDurationByDay(DateTime start, DateTime end) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT date(startTime) as day, SUM(duration) as total
      FROM practice_records
      WHERE startTime >= ? AND startTime < ? AND endTime IS NOT NULL
      GROUP BY date(startTime)
    ''', [start.toIso8601String(), end.toIso8601String()]);

    final map = <String, int>{};
    for (final row in result) {
      map[row['day'] as String] = (row['total'] as int?) ?? 0;
    }
    return map;
  }

  // 视频 CRUD
  Future<void> insertVideo(String recordId, Video video) async {
    final db = await database;
    final map = video.toMap();
    map['recordId'] = recordId;
    await db.insert('videos', map, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteVideo(String id) async {
    final db = await database;
    await db.delete('videos', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Video>> getVideosByRecordId(String recordId) async {
    final db = await database;
    final maps = await db.query(
      'videos',
      where: 'recordId = ?',
      whereArgs: [recordId],
      orderBy: 'createdAt ASC',
    );
    return maps.map((map) => Video.fromMap(map)).toList();
  }

  Future<List<Video>> getAllVideos() async {
    final db = await database;
    final maps = await db.query('videos', orderBy: 'createdAt DESC');
    return maps.map((map) => Video.fromMap(map)).toList();
  }

  Future<int> getTotalVideoCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM videos');
    return (result.first['count'] as int?) ?? 0;
  }

  // 统计
  Future<int> getTotalDuration() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(duration), 0) as total FROM practice_records WHERE endTime IS NOT NULL',
    );
    return (result.first['total'] as int?) ?? 0;
  }

  Future<int> getTotalVideoSize() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(size), 0) as total FROM videos',
    );
    return (result.first['total'] as int?) ?? 0;
  }

  // 清空数据
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('videos');
    await db.delete('practice_records');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
