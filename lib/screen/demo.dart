// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flutter/material.dart';

import '../services/SQFlite.dart';

class DataDisplayPage1 extends StatefulWidget {
  const DataDisplayPage1({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _DataDisplayPageState1 createState() => _DataDisplayPageState1();
}

class _DataDisplayPageState1 extends State<DataDisplayPage1> {
  final dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> data = [];
  List<String> categories = [];

  void check() {
    for (var data in data) {
      if (!categories.contains(data['category'])) {
        categories.add(data['category']);
      }
    }
    // ignore: avoid_print
    print(categories);
    setState(() {});
  }

  void refresh1() {
    Duration delayDuration = Duration(seconds: 1);

    Future.delayed(delayDuration, () {
      check();
      refresh1();
      print('Function executed after 1 seconds');
    });
  }

  @override
  void initState() {
    check();
    super.initState();
    refresh1();
    _queryData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TASK'),
      ),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ' ${categories[index]}',
                style:
                    const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _buildProductCards(categories[index]),
                ),
              ),
              const Divider(),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          _showInsertDialog(context);

          check();
        },
      ),
    );
  }

  void _queryData() async {
    // Retrieve all rows from the database
    List<Map<String, dynamic>> rows = await dbHelper.queryAllRows();

    setState(() {
      data = rows;
    });
  }

  void _showInsertDialog(BuildContext context) {
    String product = '';
    String category = '';
    check();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Insert Data'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Product'),
                onChanged: (value) {
                  product = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Category'),
                onChanged: (value) {
                  category = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                check();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Insert'),
              onPressed: () {
                _insertData(product, category);

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _insertData(String product, String category) async {
    // Prepare the data to be inserted
    Map<String, dynamic> row = {
      DatabaseHelper.columnProduct: product,
      DatabaseHelper.columnCategory: category,
    };

    // Insert the data into the database
    int id = await dbHelper.insert(row);
    // ignore: avoid_print
    print('Inserted row id: $id');

    // Refresh the displayed data
    _queryData();
    setState(() {});
  }
  // void _insertData(String product, String category) async {
  //   // Check if the category already exists in the database
  //   List<Map<String, dynamic>> categoryRows =
  //       await dbHelper.queryRowsByCategory(category);

  //   if (categoryRows.isNotEmpty) {
  //     // Category already exists, update the existing products
  //     int categoryId = categoryRows[0][DatabaseHelper.columnId];

  //     // Get the existing products for the category
  //     List<String> existingProducts = [];
  //     for (var row in categoryRows) {
  //       String existingProduct = row[DatabaseHelper.columnProduct];
  //       if (existingProduct != null && existingProduct.isNotEmpty) {
  //         existingProducts.add(existingProduct);
  //       }
  //     }

  //     // Add the new product to the existing products
  //     existingProducts.add(product);

  //     // Update the category with the combined products
  //     String updatedProduct = existingProducts.join(', ');
  //     dbHelper.updateProduct(categoryId, updatedProduct);
  //   } else {
  //     // Category doesn't exist, insert the new product with the category
  //     Map<String, dynamic> row = {
  //       DatabaseHelper.columnProduct: product,
  //       DatabaseHelper.columnCategory: category,
  //     };

  //     await dbHelper.insert(row);
  //   }

  //   // Refresh the displayed data
  //   _queryData();
  // }

  List<Widget> _buildProductCards(String category) {
    List<Widget> cards = [];

    List<String> products = [];

    for (var i = 0; i < data.length; i++) {
      if (data[i][DatabaseHelper.columnCategory] == category &&
          data[i][DatabaseHelper.columnProduct] != null) {
        products.add(data[i][DatabaseHelper.columnProduct]);
      }
    }

    if (products.isNotEmpty) {
      // Check if the category has already been displayed
      bool categoryDisplayed = false;
      int existingCategoryIndex = 0;

      for (var i = 0; i < cards.length; i++) {
        if (cards[i] is Text && (cards[i] as Text).data == category) {
          categoryDisplayed = true;
          existingCategoryIndex = i;
          break;
        }
      }

      if (categoryDisplayed) {
        // If category already exists, append products to existing card
        List<Widget> existingCardChildren = [];

        if (existingCategoryIndex > 0) {
          existingCardChildren
              .addAll(cards.sublist(0, existingCategoryIndex + 1));
        }

        existingCardChildren.addAll(
          products.map(
            (product) => Card(
              child: Container(
                width: 40.0,
                height: 40.0,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    product,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        cards = existingCardChildren;
      } else {
        // If category doesn't exist, create a new card
        cards.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: products
                      .map(
                        (product) => Card(
                          child: Container(
                            width: 70.0,
                            height: 70.0,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(8.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                product,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        );
      }
    }

    return cards;
  }
}
