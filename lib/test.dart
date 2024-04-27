import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Item {
  final int? id;
  final String barcode;
  final String imagePath;

  Item({this.id, required this.barcode, required this.imagePath});

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

  Future<int> insertItem(Item item) async {
    Database db = await database;
    return await db.insert(TABLE_NAME, item.toMap());
  }

  Future<List<Item>> getItems() async {
    Database db = await database;
    List<Map> maps = await db.query(TABLE_NAME);
    return List.generate(maps.length, (i) {
      return Item(
        id: maps[i]['id'],
        barcode: maps[i]['barcode'],
        imagePath: maps[i]['imagePath'],
      );
    });
  }
}

class MyApp extends StatelessWidget {
  final DBHelper dbHelper = DBHelper();

  Future<void> _takePicture() async {
    final picker = ImagePicker();
    final imageFile =
        await picker.pickImage(source: ImageSource.camera, imageQuality: 30);
    final appDir = await getApplicationDocumentsDirectory();
    if (imageFile != null) {
      final fileName = imageFile.path.split('/').last;
      final savedImage =
          await File(imageFile.path).copy('${appDir.path}/$fileName');
      final newItem = Item(barcode: '12345', imagePath: savedImage.path);
      await dbHelper.insertItem(newItem);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Supermarket Items')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _takePicture,
                child: const Text('Take Picture'),
              ),
              FutureBuilder<List<Item>>(
                future: dbHelper.getItems(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }
                  return Expanded(
                    child: ListView.builder(
                      itemCount: snapshot.data?.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(snapshot.data![index].barcode),
                          leading:
                              Image.file(File(snapshot.data![index].imagePath)),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MyApp());
}
