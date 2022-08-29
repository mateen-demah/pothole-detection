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
      moving_speed REAL NOT NULL,
      moving_speed_accuracy REAL NOT NULL,
      session_id TEXT NOT NULL,
      is_extracted INTEGER DEFAULT 0
      )''');

    // schema for registered potholes
    await db.execute('''CREATE TABLE potholes (
      timestamp INTEGER PRIMARY KEY,
      session_id TEXT NOT NULL,
      is_exported INTEGER DEFAULT 0
    )''');

    await db.execute('''CREATE TABLE ramps (
      timestamp INTEGER PRIMARY KEY,
      session_id TEXT NOT NULL,
      is_exported INTEGER DEFAULT 0
    )''');

    // schema for sessionInfo
    await db.execute('''CREATE TABLE sessionInfo(
      session_id TEXT PRIMARY KEY,
      is_extracted INTEGER DEFAULT 0,
      is_predicted INTEGER DEFAULT 0,
      is_uploaded INTEGER DEFAULT 0,
      date INTEGER,
    )''');

    // schema road class labelling data
    await db.execute('''CREATE TABLE rawRoadSegmentLabel(
      timestamp INTEGER PRIMARY KEY,
      session_id TEXT NOT NULL,
      is_exported INTEGER DEFAULT 0,
      category TEXT NOT NULL
    )''');

    await db.execute('''CREATE TABLE extractedFeatures (
      session_id TEXT NOT NULL,
      timestamp INTEGER PRIMARY KEY,
      latitude REAL NOT NULL,
      longitude REAL NOT NULL,
      avg_acc_x REAL NOT NULL,
      avg_acc_y REAL NOT NULL,
      avg_acc_z REAL NOT NULL,
      std_acc_x REAL NOT NULL,
      std_acc_y REAL NOT NULL,
      std_acc_z REAL NOT NULL,
      max_acc_x REAL NOT NULL,
      max_acc_y REAL NOT NULL,
      max_acc_z REAL NOT NULL,
      min_acc_x REAL NOT NULL,
      min_acc_y REAL NOT NULL,
      min_acc_z REAL NOT NULL,
      avg_gyro_x REAL NOT NULL,
      avg_gyro_y REAL NOT NULL,
      avg_gyro_z REAL NOT NULL,
      std_gyro_x REAL NOT NULL,
      std_gyro_y REAL NOT NULL,
      std_gyro_z REAL NOT NULL,
      max_gyro_x REAL NOT NULL,
      max_gyro_y REAL NOT NULL,
      max_gyro_z REAL NOT NULL,
      min_gyro_x REAL NOT NULL,
      min_gyro_y REAL NOT NULL,
      min_gyro_z REAL NOT NULL,
      avg_speed REAL NOT NULL,
      std_speed REAL NOT NULL,
      max_speed REAL NOT NULL,
      min_speed REAL NOT NULL,
      label INTEGER DEFAULT 0
      )''');
    // TODO: create schema for model output
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
    final deletedRamps = await db.delete(
      'ramps',
      where: 'session_id = ?',
      whereArgs: [session_id],
    );
    final deletedSession = await db.delete('sessionInfo',
        where: 'session_id = ?', whereArgs: [session_id]);
    print(
        "$deletedRaw ===========\n$deletedPotholes =================\n$deletedSession =========================");
    return [deletedRaw, deletedPotholes, deletedSession];
  }

  Future<List<Map<String, Object?>>> readAllSessionInfo() async {
    final db = await instance.database;
    final sessionInfoList = await db!.query("sessionInfo", orderBy: "date");
    return sessionInfoList.toList();
  }

  Future<void> close() async {
    final db = await instance.database;
    db!.close();
  }
}
