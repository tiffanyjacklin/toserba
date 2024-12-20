import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Toserba_App/Model/AllProduct.dart';
import 'package:Toserba_App/Model/StockOpname.dart' as opname;
import 'package:Toserba_App/Model/SubstractProductResponse.dart' as subsResponse;
import 'package:Toserba_App/Template.dart';
import 'package:http/http.dart' as http;
import 'package:Toserba_App/Model/UserData.dart' as user;

class SubstractProductProvider extends ChangeNotifier {
  SubstractProductProvider(user.Data user){
    _userData = user;
  }

  late user.Data _userData;
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

    try{
    // NOTE : kalo mau satu kosong bisa di "-" , batch misal -
    final link =
        'http://leap.crossnet.co.id:8888/products/stock/opname/data/store_warehouse/${_userData.storeWarehouseId!}/$name/$batch///////0/0';

    // call api
    final response = await http.get(Uri.parse(link)).timeout(const Duration(seconds: 10))
          .catchError((error, stacktrace) {
        print("catched error");
      });

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
    }  on SocketException catch (e) {
      print("Caught socketexception: $e");
    } on TimeoutException catch (e) {
      print('Caught: $e');
    } catch (e) {}
    //print('Done');
    return [];
  }

  // User ID 1 mengurangi produk dengan ID Subtract Product 23
  // fetch notif
  Future<bool> notificationSubstract(int substractId) async {
    // link api
    final link = 'http://leap.crossnet.co.id:8888/notifications/add';

    Map<String, dynamic> jsonBody = {
        "user_id": _userData.userId,
        "roles_id": _userData.roleId,
        "description":
            "User ID ${_userData.userId} mengurangi produk dengan ID Substract Product ${substractId}",
        "notification_type_id": 10 // id for substract
      };

    // call api (method POST)
    final response =
        await http.post(Uri.parse(link), body: json.encode(jsonBody));

    print(response.body);
    // cek status
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  // submit bro
  Future<void> submitSubstract() async {
      // NOTE : kalo mau satu kosong bisa di "-" , batch misal -
    final link =
        'http://leap.crossnet.co.id:8888/products/stock/subtract/${_userData.userId!}/${_userData.roleId!}';

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

    var hasilData = subsResponse.SubmitSubstractProduct.fromJson(temp);
      var result = await notificationSubstract(hasilData.data!.first.subtractStockId!);
      resetAll(); // COBA RESET SEMUA
    } 
  }
  else{ 
  print('error? ${response.statusCode} ${response.body}');
  }
  }


}
