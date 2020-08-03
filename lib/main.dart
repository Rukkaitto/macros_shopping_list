import 'package:barcode_scan/platform_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:macros_shopping_list/utilities/constants.dart';
import 'dart:convert';

void main() {
  runApp(App());
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  var result;
  var data = Map();
  String text = '';

  Future scan() async {
    var scanResult = await BarcodeScanner.scan();
    fetchInfo(scanResult.rawContent.toString()).then((value) => {
          setState(() {
            result = value;
          })
        });
  }

  Future fetchInfo(String barcode) async {
    http.Response response = await http.get(kApiUrl + barcode + '.json');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print(response.statusCode);
    }
  }

  void parseInfo() {
    if (result['product'] == null) {
      text = 'Product is not food';
      return;
    }
    var nutriments = result['product']['nutriments'];
    text = '';

    data[kNutriments[0]] = nutriments['energy'] * kKjKcalFactor;
    data[kNutriments[1]] = nutriments['fat_100g'];
    data[kNutriments[2]] = nutriments['saturated-fat_100g'];
    data[kNutriments[3]] = nutriments['carbohydrates_100g'];
    data[kNutriments[4]] = nutriments['sugars_100g'];
    data[kNutriments[5]] = nutriments['proteins_100g'];

    for (var i = 0; i < kNutriments.length; i++) {
      text += (kNutriments[i] +
          ': ' +
          (i == 0
              ? data[kNutriments[i]].toStringAsFixed(0)
              : data[kNutriments[i]].toString()) +
          (i == 0 ? ' kcal' : ' g') +
          '\n');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (result != null) {
      parseInfo();
    }

    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    result != null
                        ? Image.network(
                            result['product']['image_front_url'],
                            width: 100.0,
                          )
                        : Container(),
                    Text(text),
                  ],
                ),
                RaisedButton(
                  onPressed: scan,
                  child: Text('Scanner'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
