import 'dart:collection';
import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter_app_all/Model/StockOpname.dart';
import 'package:http/http.dart' as http;

// 
class itemCartSubmitted {
  final Data stockData;
  final TextEditingController inputQuantityController;
  final TextEditingController inputNotesController;

  itemCartSubmitted({
    required this.stockData,
    required this.inputNotesController,
    required this.inputQuantityController
  });
}

class itemSubmit{
  final Data stockData;
  final int quantity;
  final String notes;

  itemSubmit({
    required this.stockData,
    required this.quantity,
    required this.notes
  });
}

//
class InventoryTakingProvider extends ChangeNotifier {

  /// Internal, private state of the cart
  int _storeId = 1;

  // init value -> panggil api search with all item then save to list, result search juga dimasukin all item.


  // all items
  List<Data> _allItems = [];
  List<Data> _resultSearched = []; // caranya aku tau ini sudah di get sebelumnya? // haruse bisa pakai pointer...
  
  
  
  // cart
  List<itemCartSubmitted> _listItemCart = [];
  UnmodifiableListView<itemCartSubmitted> get listItemCart => UnmodifiableListView(_listItemCart);


  void addToCart(int index) {
    _listItemCart.add(itemCartSubmitted(stockData: _resultSearched[index], inputNotesController: TextEditingController(), inputQuantityController: TextEditingController()));

    // change notifier
    notifyListeners();
  
  }


  List<itemSubmit> getListSubmittedItem(){
    // NOTES: selesai kan ini...
    // kerjakan untuk pass ke dalam submited
    return [];
  }


   // buat suggestion?
  Future<void> searchItemWithFilter(String name, String batch, String unitType) async {
    List<Data> result = await _fetchSuggestionName(name, batch, unitType);
    _resultSearched = result.where((i) => i.expectedStock! > 0).toList();
    notifyListeners();
  }

  Future<List<Data>> _fetchSuggestionName(String name, String batch, String unitType) async {

    // NOTE : kalo mau satu kosong bisa di "-" , batch misal -
    final link =
        'http://leap.crossnet.co.id:8888/products/stock/opname/data/store_warehouse/${this._storeId}/$name/$batch/$unitType/0/0';

    // call api
    final response = await http.get(Uri.parse(link));
    print('---> response ' + response.statusCode.toString());

    // cek status
    if (response.statusCode == 200) {
      Map<String, dynamic> temp = json.decode(response.body);
      if (temp['status'] == 200) {
        print(link);
        print('result -->  $temp');
        return FetchStockOpnameWarehouse.fromJson(temp).data!;
      } else {
        return [];
      }
    } else {
      print('fetch failed');
      return [];
    }
  }
}