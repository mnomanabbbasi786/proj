import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static const _databaseName = "my_database.db";
  static const _databaseVersion = 4;

  static const table = 'my_table';
  static const columnId = '_id';
  static const columnProduct = 'product';
  static const columnCategory = 'category';

  // Make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Only have a single app-wide reference to the database
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Opens the database (creates if it doesn't exist)
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  // Creates the database tables
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY,
            $columnProduct TEXT NOT NULL,
            $columnCategory TEXT NOT NULL
          )
          ''');
  }

  // Insert operation
  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }

  Future<int> updateProduct(int id, String product) async {
    Database db = await instance.database;
    return await db.update(
      table,
      {columnProduct: product},
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  // Retrieve operation
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(table);
  }

  // Update operation
  Future<int> update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[columnId];
    return await db.update(table, row, where: '$columnId = ?', whereArgs: [id]);
  }

  // Delete operation
  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }

  // Closes the database
  Future close() async {
    Database db = await instance.database;
    db.close();
  }

  Future<List<Map<String, dynamic>>> queryRowsByCategory(
      String category) async {
    Database db = await instance.database;
    return await db.query(
      table,
      where: '$columnCategory = ?',
      whereArgs: [category],
    );
  }
}
