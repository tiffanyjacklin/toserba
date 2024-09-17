import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_app_all/Model/AllCategory.dart' as category;
import 'package:flutter_app_all/Model/StockOpname.dart';
import 'package:flutter_app_all/Template.dart';
import 'package:http/http.dart' as http;
import 'package:number_paginator/number_paginator.dart';
// import 'package:provider/provider.dart';

class itemSubmit {
  final Data stockData;
  int quantity;
  String notes;

  itemSubmit(
      {required this.stockData, required this.quantity, required this.notes});
}


class ResultFilter{
  String productOrder;
  String sort;
  String unit;
  String type;

  ResultFilter({required this.productOrder, required this.sort,  required this.unit, required this.type});
}

class InventoryTakingProvider extends ChangeNotifier {
  // constructor
  InventoryTakingProvider() {
    _resultController = List<TextEditingController>.generate(
      _lengthPerPage,
      (index) => TextEditingController(),
    );
    searchItemWithFilter('');
    fetchAllProductType();

    currentPage = 0;
  }

  /// Internal, private state of the cart
  int _storeId = 2;

  // >> for paginator
  // int _currentPage = 1;
  int _lengthPerPage = 4;
  int _checkerIndex = 0;

  final NumberPaginatorController _paginatorController =
      NumberPaginatorController();

  int get currentPage => _paginatorController.currentPage;
  set currentPage(int index) {
    _paginatorController.currentPage = index;
    changeControllerQtyValue();
    notifyListeners();
  }

  get paginatorController => _paginatorController;

  // for content table awal
  List<Data> get listPerPage => UnmodifiableListView(
      resultSearched.sublist((currentPage) * _lengthPerPage, getEndIndex()));
  late List<TextEditingController> _resultController;
  List<TextEditingController> get resultController =>
      UnmodifiableListView(_resultController);

  // >> for search
  List<Data> _resultSearched =
      []; // caranya aku tau ini sudah di get sebelumnya? // haruse bisa pakai pointer...
  UnmodifiableListView<Data> get resultSearched =>
      UnmodifiableListView(_resultSearched);
  int _rowCount = 0;
  int get rowCount => _rowCount;
  set rowCount(int count) {
    _rowCount = count;
    notifyListeners();
  }

  // >> for filter
  bool isFiltering = false;
    List<String> productOrder = [
    'Expire Date',
    'Stock',
    'Last Checked',
    'Alphabetical',
    'Batch Number',
  ];
  List<String> ascDec = ['Ascending', 'Descending'];
  List<String> unitType = ['Units', 'Grams'];
  List<category.Data> productType = [];

  String _filterProduct = 'Expire Date'; // productOrder[0]
  String _ascDecNow = 'Ascending';
  String _unitNow = '';
  String _typeNow = '';
  late Map<String, category.Data> _mapCategory;

  String get ascDecNow => _ascDecNow;
  String get unitNow => _unitNow;
  String get typeNow => _typeNow;

  // >> for submit item
  // bikin map aja kah?
  Map<String, itemSubmit> _mapListItemSubmit = {};
  UnmodifiableListView<itemSubmit> get listItemSubmit => UnmodifiableListView(
      _mapListItemSubmit.entries.map((item) => item.value).toList());

  // >> for loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  set isLoading(bool isload) {
    _isLoading = isload;
    notifyListeners();
  }

  // List<itemSubmit> getListSubmittedItem(){
  //   // NOTES: selesai kan ini...
  //   // kerjakan untuk pass ke dalam submited
  //   return [];
  // }

  // for filter function 
  bool isSelected(int index) {
    if (_filterProduct == productOrder[index]) {
      return true;
    }
    return false;
  }

  void clickFilter(String name) {
    isFiltering = !isFiltering;

    if(isFiltering == false){
      // search gas
      var resultfilter = getResult();
      searchItemWithFilter(name, asc: resultfilter.sort, category: resultfilter.type, unitType: resultfilter.unit);
    }
    notifyListeners();
  }

  void setFilterProduct(String name) {
    _filterProduct = name;
    notifyListeners();
  }

  void setAcs(String name) {
    _ascDecNow = name;
    notifyListeners();
  }

  void setUnitType(String name) {
    _unitNow = name;
    notifyListeners();
  }

  void setProductType(String name) {
    _typeNow = name;
    notifyListeners();
  }

  void resetFilter() {
    _filterProduct = 'Expire Date';
    _ascDecNow = 'Ascending';
    _unitNow = '';
    _typeNow = '';
    notifyListeners();
  }

  ResultFilter getResult(){
    var asc = 'dec';
    // var unit = '';
    if(_ascDecNow == 'Ascending'){
      asc = 'asc';
    }
    var category = '';
    if(_typeNow != ''){
      // cari dalam index
      category =  _mapCategory[_typeNow]!.productCategoryId.toString(); // kudu cari namanya !!!!
    }

    var unit = '';
    if(_unitNow != ''){
      unit = _unitNow.substring(0, _unitNow.length-1).toLowerCase();
    }

    return ResultFilter(productOrder: _filterProduct, sort: asc, unit: unit, type: category);
  }


  // for paginator function
  int findLengthListItem() {
    return min(rowCount - ((currentPage) * _lengthPerPage), _lengthPerPage);
  }

  int getMaxPage() {
    return (_rowCount.toDouble() / _lengthPerPage.toDouble()).ceil();
  }

  int getEndIndex() {
    if (currentPage != getMaxPage() - 1) {
      return (currentPage + 1) * _lengthPerPage;
    }
    print(_resultSearched.length);
    return _resultSearched.length;
  }

  int getStartIndex() {
    return currentPage * _lengthPerPage;
  }

  String getNotes(Data data) {
    if (_mapListItemSubmit.containsKey(createKey(data))) {
      return _mapListItemSubmit[createKey(data)]!.notes;
    }
    return '';
  }

  void checkControllerPageChanges() {
    if (_paginatorController.currentPage != _checkerIndex) {
      _checkerIndex = _paginatorController.currentPage;
      changeControllerQtyValue();
      notifyListeners();
    }
  }

  // for mapping purpose
  String createKey(Data data) {
    return '${data.productName}-${data.batch}-${data.expiredDate}';
  }

  // NOTE (CHECK DULU)
  void addToCart(int index, {int quantity = 0, String notes = ''}) {
    if (!_mapListItemSubmit.containsKey(createKey(_resultSearched[index]))) {
      _mapListItemSubmit[createKey(_resultSearched[index])] = itemSubmit(
          stockData: _resultSearched[index], quantity: quantity, notes: notes);

      // change notifier
      notifyListeners();
    } else {
      // posisi sudah ada dalam map, maka edit kan?
      if (quantity != 0) {
        _mapListItemSubmit[createKey(_resultSearched[index])]!.quantity =
            quantity;
      }
      if (notes != '') {
        _mapListItemSubmit[createKey(_resultSearched[index])]!.notes = notes;
      }
    }
  }

  void removeFromCart(int index) {
    if (_mapListItemSubmit.containsKey(createKey(_resultSearched[index]))) {
      _mapListItemSubmit.remove(createKey(_resultSearched[index]));
    }
  }

  void changeControllerQtyValue() {
    if (_resultController.isNotEmpty) {
      for (int i = 0; i < findLengthListItem(); i++) {
        print(i);
        // check misal ada dalam mapping
        if (_mapListItemSubmit.isNotEmpty) {
          if (_mapListItemSubmit
              .containsKey(createKey(_resultSearched[getStartIndex() + i]))) {
            _resultController[i].text = _mapListItemSubmit[
                    createKey(_resultSearched[getStartIndex() + i])]!
                .quantity
                .toString();
          } else {
            _resultController[i].text = '';
          }
        } else {
          _resultController[i].text = '';
        }
      }
    }
  }

  void resetAll() {
    _paginatorController.currentPage = 0;
    _checkerIndex = 0;

    for (final controller in _resultController) {
      controller.text = '';
    }
    _mapListItemSubmit = {};
    searchItemWithFilter('');
  }

  // API
  Future<void> SubmitInventoryTaking() async {
    final link = 'http://leap.crossnet.co.id:8888/products/stock/opname/add';

    List<itemSubmit> listItemSubmited = listItemSubmit;
    // buat isi nya dulu
    List<Map<String, dynamic>> bodyContent = List.generate(
        listItemSubmited.length,
        (i) => {
              "product_detail_id":
                  listItemSubmited[i].stockData.productDetailId,
              "batch": listItemSubmited[i].stockData.batch,
              "expired_date":
                  '${getOnlyDateSQL(listItemSubmited[i].stockData.expiredDate!)}',
              "actual_stock": listItemSubmited[i].quantity,
              "unit_type": listItemSubmited[i].stockData.unitType,
              "store_warehouse_id": _storeId
            });

    print('FUTURE - ${listItemSubmited.length}');
    // call api
    final response =
        await http.post(Uri.parse(link), body: json.encode(bodyContent));

    // cek status
    if (response.statusCode == 200) {
      Map<String, dynamic> temp = json.decode(response.body);
      if (temp['status'] == 200) {
        print(temp);
        resetAll(); // COBA RESET SEMUA
      }
    } else {
      print('error? ${response.statusCode} ${response.body}');
    }
  }

  // buat suggestion? + filter?
  Future<void> searchItemWithFilter(
    String name, {
    String batch = '',
    String unitType = '',
    String productId = '',
    String expDate = '',
    String category = '',
    String asc = 'asc',
    bool search = false,
  }) async {
    if (search) {
      // reset state sekarang
      _paginatorController.currentPage = 0;
    }

    isLoading = true;
    notifyListeners();

    List<Data> result = await fetchSuggestionName(
        name, batch, unitType, productId, expDate, category, asc);
    // _resultSearched = result.where((i) => i.expectedStock! > 0).toList();
    _resultSearched = result;
    changeControllerQtyValue();
    isLoading = false;
    notifyListeners();
  }

  Future<List<Data>> fetchSuggestionName(
      String name,
      String batch,
      String unitType,
      String productId,
      String expDate,
      String category,
      String asc) async {
    // NOTE : kalo mau satu kosong bisa di "" , batch misal kosongin aja , offset limit belum di set
    // cari offset (start index)
    // products/stock/opname/data/store_warehouse/:sw_id/:product_name/:batch/:unit_type/:product_id/:expired_date/:category/:asc/:limit/:offset
    var startIndex = (currentPage) * _lengthPerPage;
    final link =
        'http://leap.crossnet.co.id:8888/products/stock/opname/data/store_warehouse/${this._storeId}/$name/$batch/$unitType/$productId/$expDate/$category/$asc/$startIndex/20';

    // call api
    final response = await http.get(Uri.parse(link));
    print(link);
    print('---> response ' + response.statusCode.toString());

    Future.delayed(const Duration(milliseconds: 1000)).then((r) {
      return [];
    });

    // cek status
    if (response.statusCode == 200) {
      Map<String, dynamic> temp = json.decode(response.body);
      if (temp['status'] == 200) {
        print(link);
        print('result -->  $temp');
        rowCount = FetchStockOpnameWarehouse.fromJson(temp).totalRows!;
        return FetchStockOpnameWarehouse.fromJson(temp).data!;
      } else {
        return [];
      }
    } else {
      print('fetch failed');
      return [];
    }
  }
  // future brow
  Future<void> fetchAllProductType() async {
    // http://leap.crossnet.co.id:8888/products/category
    final link = 'http://leap.crossnet.co.id:8888/products/category';

    // call api (method PUT)
    final response = await http.get(Uri.parse(link));
    print('---> response ' + response.statusCode.toString());

    // cek status
    if (response.statusCode == 200) {
      Map<String, dynamic> temp = json.decode(response.body);
      print(response.body);

      if (temp['status'] == 200) {
        print(temp);
        // insert here ....
        productType = category.AllCategory.fromJson(temp).data!;
        _mapCategory = {for (int i = 0; i < productType.length; i++) productType[i].productCategoryName!: productType[i]};
        notifyListeners();
      }
    } else {
      print('fetch failed');
    }
  }

  @override
  void dispose() {
    super.dispose();
    // textediting controller
    for (final controller in _resultController) {
      controller.dispose();
    }

    // paginator controller
    _paginatorController.dispose();
  }
  // /products/stock/opname/add
}
