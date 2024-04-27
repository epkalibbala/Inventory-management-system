// import 'dart:io';
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:sqflite/sqflite.dart';

// class Item {
//   final int id;
//   final String barcode;
//   final List<String> imagePaths;

//   Item({required this.id, required this.barcode, required this.imagePaths});

//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'barcode': barcode,
//       'imagePaths': imagePaths.join(','), // Convert list to comma-separated string
//     };
//   }

//   static List<String> imagePathFromString(String imagePathString) {
//     if (imagePathString == null || imagePathString.isEmpty) {
//       return [];
//     }
//     return imagePathString.split(','); // Split comma-separated string to list
//   }
// }

// class DBHelper {
//   static final String _databaseName = "items.db";
//   static final int _databaseVersion = 1;
//   static final String TABLE_NAME = 'items';

//   DBHelper._privateConstructor();
//   static final DBHelper instance = DBHelper._privateConstructor();

//   static Database? _database;

//   Future<Database> get database async {
//     if (_database != null) return _database!;

//     _database = await _initDatabase();
//     return _database!;
//   }

//   _initDatabase() async {
//     Directory documentsDirectory = await getApplicationDocumentsDirectory();
//     String path = join(documentsDirectory.path, _databaseName);
//     return await openDatabase(path,
//         version: _databaseVersion, onCreate: _onCreate);
//   }

//   Future _onCreate(Database db, int version) async {
//     await db.execute('''
//           CREATE TABLE $TABLE_NAME (
//             id INTEGER PRIMARY KEY,
//             barcode TEXT,
//             imagePaths TEXT
//           )
//           ''');
//   }

//   Future<int> insertItem(Item item) async {
//     Database db = await database;
//     return await db.insert(TABLE_NAME, item.toMap());
//   }

//   Future<List<Item>> getItems() async {
//     Database db = await database;
//     List<Map> maps = await db.query(TABLE_NAME);
//     return List.generate(maps.length, (i) {
//       return Item(
//         id: maps[i]['id'],
//         barcode: maps[i]['barcode'],
//         imagePaths: Item.imagePathFromString(maps[i]['imagePaths']),
//       );
//     });
//   }
// }

// class MyApp extends StatelessWidget {
//   final DBHelper dbHelper = DBHelper();

//   Future<void> _takePicture() async {
//     final picker = ImagePicker();
//     final imageFile = await picker.pickImage(source: ImageSource.camera);
//     final appDir = await getApplicationDocumentsDirectory();
//     final fileName = imageFile.path.split('/').last;
//     final savedImage = await File(imageFile.path).copy('${appDir.path}/$fileName');
//     final newItem = Item(barcode: '12345', imagePaths: [savedImage.path]); // Store image path in a list
//     await dbHelper.insertItem(newItem);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(title: Text('Supermarket Items')),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               RaisedButton(
//                 onPressed: _takePicture,
//                 child: Text('Take Picture'),
//               ),
//               FutureBuilder<List<Item>>(
//                 future: dbHelper.getItems(),
//                 builder: (context, snapshot) {
//                   if (!snapshot.hasData) {
//                     return CircularProgressIndicator();
//                   }
//                   return Expanded(
//                     child: ListView.builder(
//                       itemCount: snapshot.data.length,
//                       itemBuilder: (context, index) {
//                         return ListTile(
//                           title: Text(snapshot.data[index].barcode),
//                           leading: SizedBox(
//                             height: 100,
//                             width: 100,
//                             child: ListView.builder(
//                               scrollDirection: Axis.horizontal,
//                               itemCount: snapshot.data[index].imagePaths.length,
//                               itemBuilder: (context, idx) {
//                                 return Image.file(File(snapshot.data[index].imagePaths[idx]));
//                               },
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
