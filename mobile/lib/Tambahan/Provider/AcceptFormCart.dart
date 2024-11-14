import 'dart:collection';
import 'dart:convert';
// import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app_all/Model/DeliveryTransferDetail.dart'
    as deliveryDetail;
import 'package:http/http.dart' as http;

class AcceptFormCart extends ChangeNotifier {

  AcceptFormCart(List<deliveryDetail.Data> listData, String userDataId) {
    userId = userDataId;

    _items = listData.toList();
    _listInputQuantity = List.generate(listData.length, (index) => TextEditingController());
    _listInputSection = List.generate(listData.length, (index) => TextEditingController());
    _listInputNotes = List.generate(listData.length, (index) => TextEditingController());
  }

  // user id
  late String userId;
  String message = '';

  /// Internal, private state of the cart.
  List<deliveryDetail.Data> _items = [];
  // late List<deliveryDetail.Data> _allItemRemaining = [];
  List<TextEditingController> _listInputQuantity = [];
  List<TextEditingController> _listInputSection = [];
  List<TextEditingController> _listInputNotes = [];

  /// An unmodifiable view of the items in the cart.
  UnmodifiableListView<deliveryDetail.Data> get items =>
      UnmodifiableListView(_items);

  /// An unmodifiable view of the items in the cart.
  UnmodifiableListView<TextEditingController> get listControllerInput =>
      UnmodifiableListView(_listInputQuantity);
  
    /// An unmodifiable view of the items in the cart.
  UnmodifiableListView<TextEditingController> get listControllerSection =>
      UnmodifiableListView(_listInputSection);
  
    /// An unmodifiable view of the items in the cart.
  UnmodifiableListView<TextEditingController> get listControllerNotes =>
      UnmodifiableListView(_listInputNotes);

  // check if empty
  bool get isEmptyCart => _items.isEmpty;

  /// loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool isload) {
    _isLoading = isload;
    notifyListeners();
  }

  // check cart if there is empty input
  bool isThereEmptyField() {
    for(int i = 0; i < _listInputQuantity.length; i++){
      if(_listInputQuantity[i].text.isEmpty || _listInputSection[i].text.isEmpty){
        message = 'Masih Ada Yang Belum Diisi, Silahkan Di cek lagi';
        notifyListeners();
        return true;
      }
    }
    message = '';
    notifyListeners();
    return false;
  }

  // submit the cart
  Future<bool> submit() async {
    // cek misal apakah ada yg masih kosong
    if(isThereEmptyField()){
      return false;
    }

    // jalanin api
    var result = await _fetchAcceptOrder();

    if(result){
      // reset cart ?
    }
    else{
      message = 'Error Silahkan Coba lagi';
      notifyListeners();
    }
    return result;


  }


  Future<bool> _fetchAcceptOrder() async {
    int deliveryId = _items[0].deliveryOrderId!;
    final link = 'http://leap.crossnet.co.id:8888/store/orders/delivery/accept/$deliveryId/$userId';

    // buat isi nya dulu
    List<Map<String, dynamic>> bodyContent = List.generate(
        _items.length,
        (i) => {
              "product_detail_id":
                  _items[i].productDetailId!,
              "expired_date": _items[i].expiredDate! ,
              "batch": _items[i].batch!,
              "actual_quantity": int.parse(_listInputQuantity[i].text),
              "section_placement": _listInputSection[i].text,
              "notes": _listInputNotes[i].text.isEmpty ? "-" : _listInputNotes[i].text
            });

    print('FUTURE - ${_items.length}  ---> ${jsonEncode(bodyContent)}');
    
    // call api
    final response = await http.put(Uri.parse(link), body: json.encode(bodyContent));
    

    // cek status
    if (response.statusCode == 200) {
      Map<String, dynamic> temp = json.decode(response.body);
      if (temp['status'] == 200) {
        message = '';
        print(temp);
        return true;
        // resetAll(); // COBA RESET SEMUA
        
      }
      message = 'error';
      return false;
    } 
    else {
      print('error? ${response.statusCode} ${response.body}');
      return false;
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    for (int i = 0; i < listControllerInput.length; i++){
      listControllerInput[i].dispose();
      listControllerSection[i].dispose();
      listControllerNotes[i].dispose();
    }
  }

  // Future<void> _fetchAccepted() async {
  //   // accept fetch

  //   // stock card minus (alternative solution)
  // }

  // // buat taruh notes
  // Future<bool> fetchAcceptOrder(int deliveryOrder) async {
  //   final userId = 1;

  //   final link =
  //       'http://leap.crossnet.co.id:8888/store/orders/delivery/accept/$deliveryOrder/$userId'; // NOTE : diganti nanti kalo udah ada

  //   // call api
  //   final response = await http.put(Uri.parse(link));
  //   print('---> response ' + response.statusCode.toString());

  //   // cek status
  //   if (response.statusCode == 200) {
  //     // misal oke berati masuk
  //     // json
  //     Map<String, dynamic> temp = json.decode(response.body);
  //     // decode?
  //     print(response.body);
  //     if (temp['status'] == 200) {
  //       return true;
  //     }
  //   }
  //   return false;
  // }
}
