import 'dart:io';
import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// class ItemPicture {
//   final String id;
//   final String itemId;
//   final String itemCode;
//   final List pictures;

//   ItemPicture({
//      required this.id,
//      required this.itemId,
//      required this.itemCode,
//      required this.pictures, 
//      });
// }

class ItemPicture {
  final int? id;
  final String barcode;
  final String imagePath;

  ItemPicture({this.id, required this.barcode, required this.imagePath});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'barcode': barcode,
      'imagePath': imagePath,
    };
  }
}

class DBHelper {
  static Database? _database;
  static const String DB_NAME = 'items.db';
  static const String TABLE_NAME = 'items';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, DB_NAME);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $TABLE_NAME (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        barcode TEXT,
        imagePath TEXT
      )
    ''');
  }

  Future<int> insertItem(ItemPicture item) async {
    Database db = await database;
    return await db.insert(TABLE_NAME, item.toMap());
  }

  Future<List<ItemPicture>> getItems() async {
    Database db = await database;
    List<Map> maps = await db.query(TABLE_NAME);
    return List.generate(maps.length, (i) {
      return ItemPicture(
        id: maps[i]['id'],
        barcode: maps[i]['barcode'],
        imagePath: maps[i]['imagePath'],
      );
    });
  }
}