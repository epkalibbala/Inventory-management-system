import 'dart:async';
import 'dart:convert';
import 'package:bar_scanner/api/sheets/user_api_sheets.dart';
import 'package:bar_scanner/model/item_picture.dart';
import 'package:bar_scanner/model/secondary_map.dart';
// import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

// import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart' show rootBundle;
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:intl/intl.dart';

import 'package:flutter/services.dart';

import 'model/item.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barcode Scanner',
      home: MyWidget(),
    );
  }
}

class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  String _indexNo = '';
  Map _dataCodes = {};
  String _barcode = '';
  String _result = '';
  String _resultCodes = '';
  String displayResult = '';
  List<Secondary> itemsId = [];
  List<String> barcodesSimilarItem = [];
  List<Item> items = [];
  late TextEditingController controllerVolume;
  late TextEditingController controllerDescription;
  late TextEditingController controllerCode;
  final formKey = GlobalKey<FormState>();
  final DBHelper dbHelper = DBHelper();
  List<ItemPicture> pictures = [];
  List<String> itemPictures = [];

  @override
  void initState() {
    super.initState();

    dbHelper.getItems().then((value) => pictures = value); // Fetching pictures from Sqlite

    if (_indexNo.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showDialog());
    }
    // _showDialog;

    controllerVolume = TextEditingController();
    controllerDescription = TextEditingController();
    controllerCode = TextEditingController();

    getItems().then((value) {
      // Fetching stock
      Map<dynamic, dynamic> data = {};
      items.forEach((item) {
        data[item.code] = {
          'Description': item.description,
          'Qty_pc': item.quantityPC,
          'Qty_bx': item.quantityBX,
          'exp_Qty': item.expQuantity,
          'price': item.price,
          'date': item.date
        };
      });

      // print("Data is up here");
      // print(items);
      // print("Data is up here");
      // print(data);

      setState(() {
        // Create a new map to store the modified keys
        Map<String, dynamic> modifiedMap = {};

        // Iterate through the keys of the original map
        data.forEach((key, value) {
          // Check if the key ends with ".0"
          if (key != null) {
            if (key.endsWith('.0')) {
              // Remove ".0" from the key and store the modified key in the new map
              modifiedMap[(key.replaceAll('.0', '')).trim()] = value;
            } else {
              // If the key does not end with ".0", simply copy it to the new map
              modifiedMap[key.trim()] = value;
            }
          }
        });

        _result = jsonEncode(modifiedMap);
        // print(_result);
      });
    });
    // print('data');
    getItemsCodes().then((value) {
      // Fetching secondary barcodes data
      Map<dynamic, dynamic> dataCodes = {};
      itemsId.forEach((item) {
        dataCodes[item.barcode] = {
          'item_id': item.id,
          'category': item.category
        };
      });

      _dataCodes = dataCodes;

      setState(() {
        // Create a new map to store the modified keys
        Map<String, dynamic> modifiedMap = {};

        // Iterate through the keys of the original map
        dataCodes.forEach((key, value) {
          // Check if the key ends with ".0"
          if (key != null) {
            if (key.endsWith('.0')) {
              // Remove ".0" from the key and store the modified key in the new map
              modifiedMap[(key.replaceAll('.0', '')).trim()] = value;
            } else {
              // If the key does not end with ".0", simply copy it to the new map
              modifiedMap[key.trim()] = value;
            }
          }
        });

        _resultCodes = jsonEncode(modifiedMap);
        // print(_result);
      });
    });
  }

  int countSpecificValueOccurrences(
      // Count of how many barcodes have similar itemIDs
      Map dataCodes,
      String fieldName,
      dynamic targetValue) {
    int count = 0;
    dataCodes.values.forEach((value) {
      if (value[fieldName] == targetValue) {
        // Count of items under specific bar code
        count++;
        barcodesSimilarItem.add(dataCodes.keys.firstWhere(
          // List of barcodes with similar item id
          (key) => dataCodes[key] == value,
        ));
      }
    });
    return count;
  }

  Future<void> _scanBarcode() async {
    barcodesSimilarItem.clear(); // Clear barcode list under single item 
    _showDialog();
    try {
      ScanResult result = await BarcodeScanner.scan();
      setState(() {
        _barcode = result.rawContent;
      });
      print(_barcode);
      if (_resultCodes.isNotEmpty) {
        var decodedResult = jsonDecode(_resultCodes);

        if (decodedResult.containsKey(_barcode)) {
          // print("Not empty_______");
          var itemId = decodedResult[_barcode][
              'item_id']; // The bar code reads from the secondary codes file, returns item id which is used to identify the item
          if (itemsId.isNotEmpty) { // Testing if itemsId is not a number
            var decodedResult = jsonDecode(_result);
            if (decodedResult.containsKey(itemId)) {
              var description = decodedResult[itemId]['Description'];
              var quantityPC = decodedResult[itemId]['Qty_pc'];
              var quantityBX = decodedResult[itemId]['Qty_bx'];
              var expQuantity = decodedResult[itemId]['exp_Qty'];
              var formatter = NumberFormat('#,###');
              var price = decodedResult[itemId.toString()]['price'];
              var date = decodedResult[itemId.toString()]['date'];
              DateTime referenceDate = DateTime(0000, 1, 1);
              // DateTime myDate = DateTime.fromMicrosecondsSinceEpoch(int.parse(date) * 24 * 60 * 60 * 1000);
              DateTime myDate =
                  referenceDate.add(Duration(days: int.parse(date)));
              // print(myDate);
              String formattedDate = DateFormat('d MMM yyyy').format(myDate);

              setState(() {
                displayResult =
                    // 'Description: $description\nExpected Quantity: $expQuantity\nCurrent Quantity (PC): $quantityPC\nCurrent Quantity (BX/CTN/DZ): $quantityBX\nPrice: ${formatter.format(int.parse(price))}\nCount of items under barcode: ${countSpecificValueOccurrences(_dataCodes, 'item_id', itemId)}\nList of item barcodes:\n${barcodesSimilarItem.join(', ')}\n\nAs of: $formattedDate';
                    'Description: $description\nExpected Quantity: $expQuantity\nCurrent Quantity (PC): $quantityPC\nCurrent Quantity (BX/CTN/DZ): $quantityBX\nPrice: ${formatter.format(int.parse(price))}\nCount of items under barcode: ${countSpecificValueOccurrences(_dataCodes, 'item_id', itemId)}\nList of item barcodes:\n${barcodesSimilarItem.join(', ')}\n\nAs of: $formattedDate';
                // print(displayResult);
                // print("result one");
              });
              final item = {
                ItemFields.code: itemId,
                ItemFields.id: _barcode,
                ItemFields.description: description,
                ItemFields.quantityPC: quantityPC,
                ItemFields.quantityBX: quantityBX,
                ItemFields.expQuantity: expQuantity,
                ItemFields.date: DateTime.now().toIso8601String(),
                ItemFields.shelfQuantity: 0
              };
              await UserSheetsApi.insertLog([item]).then((value) => null);
            } else {
              setState(() {
                displayResult = 'Item not found';
                // print(displayResult);
                // print("result two");
              });
              final item = {
                ItemFields.id: _barcode,
                ItemFields.description: 'Item not found',
                ItemFields.quantityPC: 'Item not found',
                ItemFields.quantityBX: 'Item not found',
                ItemFields.expQuantity: 'Item not found',
                ItemFields.date: DateTime.now().toIso8601String(),
                ItemFields.shelfQuantity: 0
              };
              await UserSheetsApi.insertLog([item]).then((value) => null);
            }
          }  
        }
        else { // Second block of code to capture unregistered barcodes by setting displayResult to item not found
              setState(() {
                displayResult = 'Item not found';
                // print(displayResult);
                // print("result two");
              });
              final item = {
                ItemFields.id: _barcode,
                ItemFields.description: 'Item not found',
                ItemFields.quantityPC: 'Item not found',
                ItemFields.quantityBX: 'Item not found',
                ItemFields.expQuantity: 'Item not found',
                ItemFields.date: DateTime.now().toIso8601String(),
                ItemFields.shelfQuantity: 0
              };
              await UserSheetsApi.insertLog([item]).then((value) => null);
            }
      }
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.cameraAccessDenied) {
        setState(() {
          displayResult = 'Camera permission not granted';
        });
      } else {
        setState(() {
          displayResult = 'Unknown error: $e';
        });
      }
    } on FormatException {
      setState(() {
        displayResult = 'Scanning cancelled';
      });
    } catch (e) {
      setState(() {
        displayResult = 'Unknown error: $e';
      });
    }
  }

  Future getItems() async {
    final items = await UserSheetsApi.getAll();
    // print(items[8].description);

    setState(() {
      this.items = items;
    });
  }

  Future getItemsCodes() async {
    final itemsId = await UserSheetsApi.getAllSec();
    // print(items[8].description);

    setState(() {
      this.itemsId = itemsId;
    });
  }

  Future<void> _takePicture() async {
    final picker = ImagePicker();
    final imageFile =
        await picker.pickImage(source: ImageSource.camera, imageQuality: 30);
    final appDir = await getApplicationDocumentsDirectory();
    if (imageFile != null) {
      final fileName = imageFile.path.split('/').last;
      final savedImage =
          await File(imageFile.path).copy('${appDir.path}/$fileName');
      final newItem = ItemPicture(barcode: _barcode, imagePath: savedImage.path);
      setState(() {
        pictures.add(newItem);
      });
      await dbHelper.insertItem(newItem);
    }
  }

  void _showDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter code'),
          content: TextFormField(
            keyboardType: TextInputType.number,
            controller: controllerCode,
            decoration: const InputDecoration(
              labelText: 'Code',
              border: OutlineInputBorder(),
            ),
            validator: (value) =>
                value!.length < 4 || value.isEmpty ? 'Enter correct code' : null,
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _indexNo = controllerCode.text;
                });
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {

    itemPictures = (pictures
              .where((ItemPicture item) =>
                      // item.barcode ==
                      //     _barcode 
                      barcodesSimilarItem.contains(item.barcode) // List of all bar codes attached to same item Id
                  ) // List of ItemPicture objects
              .toList()).map((obj) => obj.imagePath).toList(); // Extracting imagePath properties to a list

    // indexNo == '' ? showDialog(
    //             context: context,
    //             barrierDismissible: false,
    //             builder: (BuildContext context) {
    //               return AlertDialog(
    //                 title: const Text('Enter code'),
    //                 content: TextFormField(
    //                                     keyboardType: TextInputType.number,
    //                                     controller: controllerCode,
    //                                     decoration: const InputDecoration(
    //                                       labelText: 'Code',
    //                                       border: OutlineInputBorder(),
    //                                     ),
    //                                     validator: (value) =>
    //                                         value!.length < 4 || value.isEmpty
    //                                             ? 'Enter correct code'
    //                                             : null,
    //                                   ),
    //                 actions: [
    //                   TextButton(
    //                     onPressed: () {
    //                       indexNo = controllerCode.text;
    //                       Navigator.of(context).pop();
    //                     },
    //                     child: Text('OK'),
    //                   ),
    //                 ],
    //               );
    //             },
    //           ) : (){};

    return Scaffold(
        appBar: AppBar(
          title: const Text('Barcode Scanner'),
        ),
        body: Stack(children: [
          // Center(
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  itemPictures.isNotEmpty ? Container(padding: const EdgeInsets.all(8),
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (BuildContext context, int index) { // horizotal listview of item pictures
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Image.file(File(itemPictures[index])),
                        );
                       },
                       itemCount: itemPictures.length,
                      // children: [],
                    ),
                  ) : Container(),
                  Text('Scanned Barcode: $_barcode'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _scanBarcode,
                    child: const Text('Scan Barcode'),
                  ),
                  const SizedBox(height: 20),
                  // _barcode.isNotEmpty ? Text(displayResult) : const Text(""),
                  Text(displayResult),
                ],
              ),
            ),
          // ),
          DraggableScrollableSheet(
              initialChildSize: 0.125,
              minChildSize: 0.125,
              maxChildSize: 0.5,
              snapSizes: const [0.125, 0.5],
              snap: true,
              builder: (BuildContext context, scrollSheetController) {
                return Container(
                    color: Colors.white,
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      physics: const ClampingScrollPhysics(),
                      controller: scrollSheetController,
                      itemCount: 1,
                      itemBuilder: (BuildContext context, int index) {
                        // final car = cars[index];
                        if (_barcode.isEmpty ||
                            displayResult == 'Scanning cancelled') {
                          // Body returned incase of scanning error
                          return const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  SizedBox(
                                    width: 50,
                                    child: Divider(
                                      thickness: 5,
                                    ),
                                  ),
                                  Text('Swipe up to update stock.')
                                ],
                              ));
                        }
                        if (displayResult == 'Item not found' || displayResult.trim() == '' ) {
                          // Fires if displayCode is changed to Item not found
                          return Card(
                              // The card has two fields which take quantity and description
                              margin: EdgeInsets.zero,
                              elevation: 5,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Form(
                                  key: formKey,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(
                                        width: 50,
                                        child: Divider(
                                          thickness: 5,
                                        ),
                                      ),
                                      const Text('Swipe up to update stock.'),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      TextFormField(
                                        keyboardType: TextInputType.number,
                                        controller: controllerVolume,
                                        decoration: const InputDecoration(
                                          labelText: 'Volume',
                                          border: OutlineInputBorder(),
                                        ),
                                        validator: (value) =>
                                            value != null && value.isEmpty
                                                ? 'Enter Volume'
                                                : null,
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      TextFormField(
                                        controller: controllerDescription,
                                        decoration: const InputDecoration(
                                          labelText: 'Description',
                                          border: OutlineInputBorder(),
                                        ),
                                        validator: (value) =>
                                            value != null && value.isEmpty
                                                ? 'Enter Description'
                                                : null,
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          // print('One two three');
                                          final form = formKey.currentState!;
                                          final isValid = form.validate();
                                          if (isValid) {
                                            // print('What the fuck is going on?');
                                            FocusScope.of(context).unfocus();
                                            // if (_result.isNotEmpty) {
                                            //   var decodedResult =
                                            //       jsonDecode(_result);
                                            // if (decodedResult
                                            //     .containsKey(_barcode)) {
                                            // var description =
                                            //     decodedResult[_barcode]
                                            //         ['Description'];
                                            // var quantity =
                                            //     decodedResult[_barcode]
                                            //         ['Qty'];
                                            // setState(() {
                                            final item = {
                                              ItemFields.id: _barcode,
                                              ItemFields.description:
                                                  controllerDescription.text,
                                              ItemFields.quantityPC: 0,
                                              ItemFields.date: DateTime.now()
                                                  .toIso8601String(),
                                              ItemFields.shelfQuantity:
                                                  controllerVolume.text,
                                              ItemFields.indexNo:
                                                        _indexNo
                                            };
                                            await UserSheetsApi.insertNotFound(
                                                [item]).then((value) {
                                              const snackdemo = SnackBar(
                                                content: Text(
                                                    'Stock item successfully captured.'),
                                                backgroundColor: Colors.green,
                                                elevation: 10,
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                margin: EdgeInsets.all(5),
                                              );
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(snackdemo);
                                              controllerVolume.clear();
                                              controllerDescription.clear();
                                            });
                                            // });
                                            // } else {
                                            //   setState(() {
                                            //     displayResult =
                                            //         'Item not found';
                                            //   });
                                            // }
                                            // }
                                          }
                                        },
                                        child: const Text('Send update'),
                                      ),
                                    ],
                                  ),
                                ),
                              ));
                        }
                        return Card(
                            // Card returns with field to update quantity on shelf
                            margin: EdgeInsets.zero,
                            elevation: 5,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Form(
                                key: formKey,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(
                                      width: 50,
                                      child: Divider(
                                        thickness: 5,
                                      ),
                                    ),
                                    const Text('Swipe up to update stock.'),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    TextFormField(
                                      keyboardType: TextInputType.number,
                                      controller: controllerVolume,
                                      decoration: const InputDecoration(
                                        labelText: 'Volume',
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (value) =>
                                          value != null && value.isEmpty
                                              ? 'Enter Volume'
                                              : null,
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        final form = formKey.currentState!;
                                        final isValid = form.validate();
                                        if (isValid) {
                                          FocusScope.of(context).unfocus();
                                          if (_resultCodes.isNotEmpty) {
                                            var decodedResult =
                                                jsonDecode(_resultCodes);

                                            if (decodedResult
                                                .containsKey(_barcode)) {
                                              var itemId = decodedResult[
                                                      _barcode][
                                                  'item_id']; // The bar code reads from the secondary codes file, returns item id which is used to identify the item
                                              if (itemsId.isNotEmpty) {
                                                var decodedResult =
                                                    jsonDecode(_result);
                                                if (decodedResult
                                                    .containsKey(itemId)) {
                                                  var description =
                                                      decodedResult[itemId]
                                                          ['Description'];
                                                  var quantityPC =
                                                      decodedResult[itemId]
                                                          ['Qty_pc'];
                                                  var quantityBX =
                                                      decodedResult[itemId]
                                                          ['Qty_bx'];
                                                  var expQuantity =
                                                      decodedResult[itemId]
                                                          ['exp_Qty'];
                                                  final item = {
                                                    // Details sending updates of stock to google sheets
                                                    ItemFields.code: itemId,
                                                    ItemFields.id: _barcode,
                                                    ItemFields.description:
                                                        description,
                                                    ItemFields.quantityPC:
                                                        quantityPC,
                                                    ItemFields.quantityBX:
                                                        quantityBX,
                                                    ItemFields.expQuantity:
                                                        expQuantity,
                                                    ItemFields.date:
                                                        DateTime.now()
                                                            .toIso8601String(),
                                                    ItemFields.shelfQuantity:
                                                        controllerVolume.text,
                                                    ItemFields.indexNo:
                                                        _indexNo
                                                  };
                                                  await UserSheetsApi.insert(
                                                      [item]).then((value) {
                                                    const snackdemo = SnackBar(
                                                      content: Text(
                                                          'Stock volume successfully captured.'),
                                                      backgroundColor:
                                                          Colors.green,
                                                      elevation: 10,
                                                      behavior: SnackBarBehavior
                                                          .floating,
                                                      margin: EdgeInsets.all(5),
                                                    );
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                            snackdemo);
                                                    controllerVolume.clear();
                                                  });
                                                }
                                              }
                                            } else {
                                              setState(() {
                                                displayResult =
                                                    'Item not found';
                                              });
                                            }
                                          }
                                        }
                                      },
                                      child: const Text('Send update'),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    ElevatedButton(
                                      onPressed: _takePicture,
                                      child: const Text('Take Picture'),
                                    )
                                  ],
                                ),
                              ),
                            ));
                      },
                    ));
              }),
        ]),
      );
    // );
  }
}

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await UserSheetsApi.int();

  runApp(MyApp());
}
