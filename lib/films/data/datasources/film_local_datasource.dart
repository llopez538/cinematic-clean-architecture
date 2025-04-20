import 'dart:convert';

import 'package:cinematic/films/data/models/film.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

abstract class FilmLocalDataSource {
  Future<void> cacheFilms(int page, int genre, List<Film> films);
  Future<List<Film>?> getCachedFilms(int page, int genre);
  Future<void> cleanupCache();
  Future<void> close();
}

class FilmLocalDataSourceImpl implements FilmLocalDataSource {
  static Database? _database;
  static const String _tableName = 'cached_films';
  static const int _maxCachedPages = 5;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'films_cache.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id INTEGER PRIMARY KEY,
            page INTEGER,
            genre INTEGER,
            data TEXT,
            timestamp INTEGER
          )
        ''');
      },
    );
  }

  @override
  Future<void> cacheFilms(int page, int genre, List<Film> films) async {
    final db = await database;
    await db.insert(_tableName, {
      'page': page,
      'genre': genre,
      'data': json.encode(films.map((f) => f.toMap()).toList()),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    await cleanupCache();
  }

  @override
  Future<List<Film>?> getCachedFilms(int page, int genre) async {
    final db = await database;
    final results = await db.query(
      _tableName,
      where: 'page = ? AND genre = ?',
      whereArgs: [page, genre],
      orderBy: 'timestamp DESC',
      limit: 1,
    );

    if (results.isNotEmpty) {
      final data = results.first['data'] as String;
      return (json.decode(data) as List)
          .map((json) => Film.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return null;
  }

  @override
  Future<void> cleanupCache() async {
    final db = await database;
    final entries = await db.query(_tableName, orderBy: 'timestamp ASC');
    
    if (entries.length > _maxCachedPages) {
      final idsToDelete = entries
          .sublist(0, entries.length - _maxCachedPages)
          .map((e) => e['id'] as int)
          .toList();

      await db.delete(
        _tableName,
        where: 'id IN (${List.filled(idsToDelete.length, '?').join(',')})',
        whereArgs: idsToDelete,
      );
    }
  }

  @override
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}