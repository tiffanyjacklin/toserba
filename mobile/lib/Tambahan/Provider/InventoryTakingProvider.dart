import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:Toserba_App/Model/AllCategory.dart' as category;
import 'package:Toserba_App/Model/AllSort.dart' as sort;
import 'package:http/http.dart' as http;
import 'package:number_paginator/number_paginator.dart';

import 'package:Toserba_App/Model/StockOpname.dart';
// import 'package:provider/provider.dart';

class itemSubmit {
  final Data stockData;
  int quantity;
  String notes;

  itemSubmit(
      {required this.stockData, required this.quantity, required this.notes});
}

class ResultFilter {
  String productOrder;
  String sort;
  String unit;
  String type;

  ResultFilter(
      {required this.productOrder,
      required this.sort,
      required this.unit,
      required this.type});
}

class InventoryTakingProvider extends ChangeNotifier {
  // constructor
  InventoryTakingProvider(int storeId) {
    this._storeId = storeId;
    _resultController = List<TextEditingController>.generate(
      _lengthPerPage,
      (index) => TextEditingController(),
    );
    fetchAllSorting();
    fetchAllProductCategories();
    searchItemWithFilter('');

    currentPage = 0;
  }

  /// Internal, private state of the cart
  int _storeId = 2;

  // >> for paginator
  // int _currentPage = 1;
  int _lengthPerPage = 4;
  int _checkerIndex = 0;
  bool afterFetch = false;

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
      resultSearched.sublist(getStartIndex(), getEndIndex()));
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

  List<sort.Data> productOrder = [];
  List<String> ascDec = ['Ascending', 'Descending'];
  List<String> unitType = ['Units', 'Grams'];
  List<category.Data> productType = [];

  String _filterProduct = ''; // productOrder[0]
  String _ascDecNow = '';
  String _unitNow = '';
  String _typeNow = '';
  late Map<String, category.Data> _mapCategory;
  late Map<String, sort.Data> _mapSort;

  String get filterProduct => _filterProduct;
  String get ascDecNow => _ascDecNow;
  String get unitNow => _unitNow;
  String get typeNow => _typeNow;

  // >> for submit item
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

  void clickFilter(String name) {
    isFiltering = !isFiltering;

    if (!isFiltering) {
      var resultfilter = getResult();
      searchItemWithFilter(name,
          order: resultfilter.productOrder,
          asc: resultfilter.sort,
          category: resultfilter.type,
          unitType: resultfilter.unit,
          search: true);
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
    _filterProduct = '';
    _ascDecNow = 'Ascending';
    _unitNow = '';
    _typeNow = '';
    notifyListeners();
  }

  ResultFilter getResult() {
    var asc = 'desc';
    // var unit = '';
    if (_ascDecNow == 'Ascending') {
      asc = 'asc';
    }
    var category = '';
    if (_typeNow != '') {
      // cari dalam index
      category = _mapCategory[_typeNow]!
          .productCategoryId
          .toString(); // kudu cari namanya !!!!
    }

    var unit = '';
    if (_unitNow != '') {
      unit = _unitNow.substring(0, _unitNow.length - 1).toLowerCase();
    }

    var sortBy = '';
    if (_filterProduct != '') {
      sortBy = _mapSort[_filterProduct]!.sortId!.toString();
    }

    return ResultFilter(
        productOrder: sortBy, sort: asc, unit: unit, type: category);
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
    // print(_resultSearched.length);
    return _resultSearched.length;
  }

  int getStartIndex() {
    return currentPage * _lengthPerPage;
  }

  int getEndPage() {
    return (_resultSearched.length.toDouble() / _lengthPerPage.toDouble())
            .ceil() -
        1;
  }

  String getNotes(Data data) {
    if (_mapListItemSubmit.containsKey(createKey(data))) {
      return _mapListItemSubmit[createKey(data)]!.notes;
    }
    return '';
  }

  void checkControllerPageChanges(String name) {
    if (_paginatorController.currentPage != _checkerIndex) {
      _checkerIndex = _paginatorController.currentPage;
      changeControllerQtyValue();
      notifyListeners();
      
      // check misal sudah melebihi limit page (misal sudah sama dengan batas fetch dan fetch masih belum ke max page)
      if (_checkerIndex == getEndPage() && getEndPage() + 1 != getMaxPage()) {
        var resultfilter = getResult();
        searchItemWithFilter(name,
            order: resultfilter.productOrder,
            asc: resultfilter.sort,
            category: resultfilter.type,
            unitType: resultfilter.unit);
        afterFetch = true;
      } 
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
        // print(i);
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
    searchItemWithFilter('', search: true);
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
                  '${listItemSubmited[i].stockData.expiredDate!}',
              "actual_stock": listItemSubmited[i].quantity,
              "unit_type": listItemSubmited[i].stockData.unitType,
              "store_warehouse_id": _storeId
            });

    print('FUTURE - ${listItemSubmited.length}  ---> ${jsonEncode(bodyContent)}');
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
    String order = '',
    bool search = false,
  }) async {
    if (search) {
      // reset state sekarang
      _paginatorController.currentPage = 0;
    }

    isLoading = true;
    notifyListeners();

    List<Data> result = await fetchSuggestionName(
        name, batch, unitType, productId, expDate, category, asc, order);

    if(search){
    _resultSearched = result;
    }
    else{
      _resultSearched += result;
    }
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
      String asc,
      String order) async {
    // NOTE : kalo mau satu kosong bisa di "" , batch misal kosongin aja , offset limit belum di set
    // cari offset (start index)
    // products/stock/opname/data/store_warehouse/:sw_id/:product_name/:batch/:unit_type/:product_id/:expired_date/:category/:asc/:limit/:offset /:category/:product_sort/:asc/:limit/:offset
    var startIndex = (currentPage) * _lengthPerPage;
    final link =
        'http://leap.crossnet.co.id:8888/products/stock/opname/data/store_warehouse/${this._storeId}/$name/$batch/$unitType/$productId/$expDate/$category/$order/$asc/0/$startIndex';

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

  // future for intial value
  Future<void> fetchAllProductCategories() async {
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
        _mapCategory = {
          for (int i = 0; i < productType.length; i++)
            productType[i].productCategoryName!: productType[i]
        };
        notifyListeners();
      }
    } else {
      print('fetch failed');
    }
  }

  Future<void> fetchAllSorting() async {
    // http://leap.crossnet.co.id:8888/products/category
    final link = 'http://leap.crossnet.co.id:8888/products/sorting';

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
        productOrder = sort.AllSortProduct.fromJson(temp).data!;
        _mapSort = {
          for (int i = 0; i < productOrder.length; i++)
            productOrder[i].sortType!: productOrder[i]
        };
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
}


//   e.PUT("/store/orders/delivery/accept/:deliveryorder_id/:user_id", controller.AcceptDeliveryOrders)
// [
//     {
//         "product_detail_id": 1,
//         "expired_date": 2025-03-22,
//         "batch": 1,
//         "actual_quantity": 10,
//         "section_placement": A1,
//         "notes": "dimakan naga"
//     },
//     {
//         "product_detail_id": 2,
//         "expired_date": 2025-03-22,
//         "batch": 2,
//         "actual_quantity": 5,
//         "section_placement": A2,
//         "notes": "terbang"
//     }
// ]
