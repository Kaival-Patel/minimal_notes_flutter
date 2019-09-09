import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';


class DatabaseHelper {
  static final _databasename="MyDatabase.db";
  static final _databaseVersion=1;
  static final table='my_table';
  static final columnId='_id';
  static final String columnNote='note'; 
  static final String columnColor='blue';

  //singleton class it means there can be only one object of a class at a time
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance=DatabaseHelper._privateConstructor();
  
  //only have single app-wide reference to the database
  static Database _database;
  Future<Database> get database async{
    if(_database!=null)
    {
      return _database;
    }
    else{
      //initialize database
      _database=await _initDatabase();
      return _database;
    }
  }

  //initialize database
  _initDatabase() async{
    Directory documentsdirectory= await getApplicationDocumentsDirectory();
    String path=join(documentsdirectory.path,_databasename);
    return await openDatabase(path,version: _databaseVersion,onCreate:_OnCreate);
  }

  //create database
  Future _OnCreate(Database db,int version) async{
    await db.execute('''CREATE TABLE $table (
      $columnId INTEGER NOT NULL,
      $columnNote TEXT NOT NULL,
      $columnColor TEXT NOT NULL
    )''');
  }

  // Helper methods

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
 Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }

 Future<List<Map<String, dynamic>>> queryColumn() async {
    Database db = await instance.database;
    return await db.rawQuery('SELECT $columnNote FROM $table');
  }


  Future<List<Map<String, dynamic>>> queryId() async {
    Database db = await instance.database;
    return await db.rawQuery('SELECT $columnId FROM $table');
  }

  Future<List<Map<String, dynamic>>> queryColors() async {
    Database db = await instance.database;
    return await db.rawQuery('SELECT $columnColor FROM $table');
  }
  
  Future<int> queryRowCount() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $table'));
  }

  Future<int> update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[columnId];
    return await db.update(table, row, where: '$columnId = ?', whereArgs: [id]);
  }
  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }

}