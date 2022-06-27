import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SensorDataDb {
  static final SensorDataDb instance = SensorDataDb.init();
  static Database? sensorDataDb;

  SensorDataDb.init();

  Future<Database?> get database async {
    // if (sensorDataDb != null) return sensorDataDb;
    sensorDataDb = await initialiseDb('sensorData.db');
    return sensorDataDb;
  }

  Future<Database> initialiseDb(String dbFileName) async {
    final dir = await getDatabasesPath();
    final dbPath = join(dir, dbFileName);
    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: createTables,
      singleInstance: true,
    );
  }

  Future createTables(Database db, int version) async {
    // schema for raw sensor data
    await db.execute('''CREATE TABLE rawSensorData (
      timestamp INTEGER PRIMARY KEY,
      latitude REAL NOT NULL,
      longitude REAL NOT NULL,
      accelerometer_x REAL NOT NULL,
      accelerometer_y REAL NOT NULL,
      accelerometer_z REAL NOT NULL,
      gyroscope_x REAL NOT NULL,
      gyroscope_y REAL NOT NULL,
      gyroscope_z REAL NOT NULL,
      session_id TEXT NOT NULL,
      is_exported INTEGER DEFAULT 0
      )''');

    // schema for registered potholes
    await db.execute('''CREATE TABLE potholes (
      timestamp INTEGER PRIMARY KEY,
      session_id TEXT NOT NULL,
      is_exported INTEGER DEFAULT 0
    )''');

    // schema for sessionInfo
    await db.execute('''CREATE TABLE sessionInfo(
      session_id TEXT PRIMARY KEY,
      datapoints INTEGER,
      potholes INTEGER,
      date INTEGER
    )''');

    // TODO: create a schema for extracted features table
    // TODO: create a schema road class labelling data
  }

  Future<int> insert(String tableName, Map<String, Object> sensorData) async {
    final db = await instance.database;
    final id = await db!.insert(
      tableName,
      sensorData,
    );
    return id;
  }

  Future<List<int>> deleteSession(String session_id) async {
    final db = await instance.database;
    final deletedRaw = await db!.delete(
      'rawSensorData',
      where: 'session_id = ?',
      whereArgs: [session_id],
    );
    final deletedPotholes = await db.delete(
      'potholes',
      where: 'session_id = ?',
      whereArgs: [session_id],
    );
    final deletedSession = await db.delete('sessionInfo',
        where: 'session_id = ?', whereArgs: [session_id]);
    return [deletedRaw, deletedPotholes, deletedSession];
  }

  Future<List<Map<String, Object?>>> readAllSessionInfo() async {
    final db = await instance.database;
    final sessionInfoList = await db!.query("sessionInfo", orderBy: "date");
    return sessionInfoList;
  }

  Future<void> close() async {
    final db = await instance.database;
    db!.close();
  }
}
