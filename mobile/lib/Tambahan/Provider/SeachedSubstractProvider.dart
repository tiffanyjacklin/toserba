import 'dart:collection';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_all/Model/AllProduct.dart';
import 'package:flutter_app_all/Model/StockOpname.dart' as opname;
import 'package:flutter_app_all/Template.dart';
import 'package:http/http.dart' as http;

class SubstractProductProvider extends ChangeNotifier {
  /// Internal, private state of the cart
  int _storeId = 2;
  // bool _onSearch = false;

  // search product need
  List<opname.Data> _suggestionItem = [];
  int _itemSuggestionSelectedIndex = 0; // default pertama 
  set itemSuggestionSelectedIndex(int index){
    _itemSuggestionSelectedIndex = index;
    notifyListeners();
  }
  List<Data> listAutoComplete = [];

  int get itemSuggestionSelectedIndex => _itemSuggestionSelectedIndex;

 /// An unmodifiable view of the items in the cart.
  UnmodifiableListView<opname.Data> get suggestionitems =>
      UnmodifiableListView(_suggestionItem);


  // cart
  List<opname.Data> _cartItems = [];
  List<TextEditingController> _listInputQuantity = [];
  List<TextEditingController> _listNotes = [];

  /// An unmodifiable view of the items in the cart.
  UnmodifiableListView<opname.Data> get cartItems =>
      UnmodifiableListView(_cartItems);
  
  /// An unmodifiable view of the items in the cart.
  UnmodifiableListView<TextEditingController> get listInputQuantity =>
      UnmodifiableListView(_listInputQuantity);
  
    /// An unmodifiable view of the items in the cart.
  UnmodifiableListView<TextEditingController> get listNotes =>
      UnmodifiableListView(_listNotes);

  void addToCart(opname.Data item) {
    _cartItems.add(item);
    _listInputQuantity.add(TextEditingController());
    _listNotes.add(TextEditingController());

    // change notifier
    notifyListeners();
  
  }
  
  void addToCart2() {
    if(_itemSuggestionSelectedIndex != null){
    _cartItems.add(_suggestionItem[_itemSuggestionSelectedIndex]);
    _listInputQuantity.add(TextEditingController());
    _listNotes.add(TextEditingController());

    // change notifier
    notifyListeners();
    }
  }

  void deleteItem(int cartItemId) {
    _cartItems.removeAt(cartItemId);
    _listInputQuantity.removeAt(cartItemId);
    _listNotes.removeAt(cartItemId);

    // change notifier
    notifyListeners();
    print('HAPUS + $cartItemId - ${_cartItems.length}');
  }

  List<DropdownMenuItem> makeListItemSuggestion(){
    List<DropdownMenuItem> listItem = [];
    
    for(var item in _suggestionItem){
      // masukan ke dalam list (should be batch and the exp date)
      listItem.add(
        DropdownMenuItem(value : item, child: Text('${item.batch} - ${getOnlyDate(item.expiredDate!)}', style: TextStyle(fontSize: fontSizeBody),))
      );
    }
    return listItem;
  }

  void resetAll(){
    _suggestionItem.clear();
    _itemSuggestionSelectedIndex = 0;

    _cartItems.clear();
    _listInputQuantity.clear();
    _listNotes.clear();

    notifyListeners();
  }

  // buat suggestion?
  Future<void> searchItemByName(String name) async {
    _suggestionItem = [];
    List<opname.Data> result = await _fetchSuggestionName(name, '', '');
    _suggestionItem = result.where((i) => i.expectedStock! > 0).toList();

    notifyListeners();
  }

  Future<List<opname.Data>> _fetchSuggestionName(String name, String productName, String batch) async {
    // var batch = '';
    // var unitType = '';

    // NOTE : kalo mau satu kosong bisa di "-" , batch misal -
    final link =
        'http://leap.crossnet.co.id:8888/products/stock/opname/data/store_warehouse/${this._storeId}/$name/$batch///////0/0';

    // call api
    final response = await http.get(Uri.parse(link));
    print('---> response ' + response.statusCode.toString());
    print(link);

    // cek status
    if (response.statusCode == 200) {
      Map<String, dynamic> temp = json.decode(response.body);
      if (temp['status'] == 200) {
        print(link);
        print('result -->  $temp');
        return opname.FetchStockOpnameWarehouse.fromJson(temp).data!;
      } else {
        return [];
      }
    } else {
      print('fetch failed');
      return [];
    }
  }


  Future<void> fetchProduct(int userId, int roleId, String search) async {
        // ${$userId}/${$roleId}///${searchQuery}/${category}/${unit_type}/${sort_type}/${sorting}/${limit}/${offset}
    final link =
        'http://leap.crossnet.co.id:8888/products/store_warehouse/$userId/$roleId///$search/////10/0';
    
    print(link);

    // call api
    final response = await http.get(Uri.parse(link));
    print('---> response ' + response.statusCode.toString());

    // cek status
    if (response.statusCode == 200) {
      // misal oke berati masuk
      // json
      Map<String, dynamic> temp = json.decode(response.body);
      // decode?
      print(response.body);
      if (temp['status'] == 200) {
        print(temp);
        listAutoComplete = FetchAllProducts.fromJson(temp).data!;
        notifyListeners();
      } else {
        listAutoComplete = [];
      }
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      // throw Exception('Login Failed, Try Again');
      print('fetch failed');
      listAutoComplete = [];
    }
  }

//   // Menambah subtract product baru
// e.POST("/products/stock/subtract/:user_id/:role_id", controller.InsertSubtractStock)
// [
//     {
//         "product_detail_id": 4,
//         "batch": "1",
//         "subtract_quantity": 1,
//         "expired_date": "2025-08-25"
//         "notes": "Dimakan tikus pak bos"
//     }
// ]



  // submit bro
  Future<void> submitSubstract(int userId, int roleId) async {
      // NOTE : kalo mau satu kosong bisa di "-" , batch misal -
    final link =
        'http://leap.crossnet.co.id:8888/products/stock/subtract/$userId/$roleId';

    // buat isi nya dulu
    List<Map<String, dynamic>> bodyContent = List.generate(
      _cartItems.length,
      (i) => {
            "product_detail_id": _cartItems[i].productDetailId,
            "batch": _cartItems[i].batch,
            "subtract_quantity": int.parse(_listInputQuantity[i].text),
            "expired_date":
                '${getOnlyDateSQL(_cartItems[i].expiredDate!)}', //   "2024-08-20",
            "notes": _listNotes[i].text,
          });

    print('FUTURE - ${cartItems.length}');
    // call api
    final response = await http.post(Uri.parse(link) , body: json.encode(bodyContent));

     // cek status
  if (response.statusCode == 200) {
    Map<String, dynamic> temp = json.decode(response.body);
    if (temp['status'] == 200) {
      print(temp);
      resetAll(); // COBA RESET SEMUA
    } 
  }
  else{ 
  print('error? ${response.statusCode} ${response.body}');
  }
  }


}
