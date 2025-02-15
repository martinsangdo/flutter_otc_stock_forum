//author: Sang Do
import 'package:otc_stock_forum/model/user_setting_model.dart';
import 'package:path/path.dart';
import 'metadata_model.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._instance();
  static Database? _database;

  DatabaseHelper._instance();

  Future<Database> get db async {
    _database ??= await initDb();
    return _database!;
  }

  Future<Database> initDb() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'otc_stock_forum.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE metadata (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TINYTEXT,
        fin_key TINYTEXT,
        fin_uri TINYTEXT,
        gem_key TINYTEXT,
        gem_uri TINYTEXT,
        avatar_uri TINYTEXT,
        backend_uri TINYTEXT,
        otc_market_uri TINYTEXT,
        update_time INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE user_settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TINYTEXT,
        name TINYTEXT,
        usr TINYTEXT,
        stocks TINYTEXT
      )
    ''');
  }

  Future<List<Map>> rawQuery(String query, List<String> conditions) async {
    Database db = await instance.db;
    return await db.rawQuery(query, conditions);
  }

  /////////////// METADATA
  Future<int> insertMetadata(MetaDataModel newMetadata) async {
    Database db = await instance.db;
    return await db.insert('metadata', newMetadata.toMap());
  }
  Future<int> updateMetadata(MetaDataModel newMetadata) async {
    Database db = await instance.db;
    return await db.update('metadata', newMetadata.toMap(), where: 'uuid = ?', whereArgs: [newMetadata.uuid]);
  }
  /////////////// LOCAL USER SETTINGS (saved in the local app, not cloud)
  Future<int> insertUserSettings(UserSettingModel newMetadata) async {
    Database db = await instance.db;
    return await db.insert('user_settings', newMetadata.toMap());
  }
  Future<int> updateUserSettings(UserSettingModel newMetadata) async {
    Database db = await instance.db;
    return await db.update('user_settings', newMetadata.toMap(), where: 'uuid = ?', whereArgs: [newMetadata.uuid]);
  }
}
