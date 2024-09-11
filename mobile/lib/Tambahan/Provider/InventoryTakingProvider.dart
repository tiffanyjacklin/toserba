import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter_app_all/Model/StockOpname.dart';
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

class InventoryTakingProvider extends ChangeNotifier {
  // constructor
  InventoryTakingProvider() {
    _resultController = List<TextEditingController>.generate(
      _lengthPerPage,
      (index) => TextEditingController(),
    );
    searchItemWithFilter('');
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
    else{

    }
  }

  // API
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
      // _paginatorController.currentPage = 0;
    }

    isLoading = true;
    notifyListeners();

    List<Data> result = await fetchSuggestionName(
        name, batch, unitType, productId, expDate, category, asc);
    // _resultSearched = result.where((i) => i.expectedStock! > 0).toList();
    _resultSearched = result;

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
