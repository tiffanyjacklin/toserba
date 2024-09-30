import 'dart:collection';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_app_all/Model/AllProduct.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_app_all/Model/AllCategory.dart' as category;
import 'package:flutter_app_all/Model/AllSort.dart' as sort;
import 'package:number_paginator/number_paginator.dart';


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

class ProductProvider extends ChangeNotifier {
  ProductProvider(int userId, int roleId) {
    fetchAllSorting();
    fetchAllProductCategories();
    fetchProduct(userId, roleId).then((onValue) => {});
  }

  List<Data> _listProduct = [];
  bool isLoading = true;
  // Map<int, Data> mappingPaginator = {};
  UnmodifiableListView get listProduct => UnmodifiableListView(_listProduct);

  // >> for paginator
  int limit = 100000;
  // int indexPageNow = 0;
  int itemPerPage = 4;
  int maxRow = 0;
  final NumberPaginatorController _paginatorController =
      NumberPaginatorController();
  int get indexPageNow => _paginatorController.currentPage;
  NumberPaginatorController get paginatorController => _paginatorController;

  // >> for filter
  bool _isFiltering = false;
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

  set isFiltering(bool i) {
    _isFiltering = i;
    notifyListeners();
  }

  set filterProduct(String name) {
    _filterProduct = name;
    notifyListeners();
  }

  set ascDecNow(String name) {
    _ascDecNow = name;
    notifyListeners();
  }

  set unitNow(String name) {
    _unitNow = name;
    notifyListeners();
  }

  set typeNow(String name) {
    _typeNow = name;
    notifyListeners();
  }

  bool get isFiltering => _isFiltering;
  String get filterProduct => _filterProduct;
  String get ascDecNow => _ascDecNow;
  String get unitNow => _unitNow;
  String get typeNow => _typeNow;

  void resetFilter() {
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

  void clickFilter(int userId, int roleId ,String name) {
    isFiltering = !isFiltering;

    if (!isFiltering) {
      var resultfilter = getResult();
      fetchProduct(userId, roleId, searchQuery: name, sorting: resultfilter.sort, sort_type: resultfilter.productOrder, category: resultfilter.type, unit_type: resultfilter.unit, );
    }
    notifyListeners();
  }

  int getMaxPage() {
    if (_listProduct.isEmpty) {
      return 0;
    }
    return (_listProduct.length.toDouble() / itemPerPage.toDouble()).ceil();
  }

  List<Data> getItemPerPage() {
    if (_listProduct.isEmpty) {
      return [];
    }
    if (indexPageNow == getMaxPage() - 1) {
      return _listProduct.sublist(
          (indexPageNow * itemPerPage), _listProduct.length);
    }
    return _listProduct.sublist(
        (indexPageNow * itemPerPage), ((indexPageNow + 1) * itemPerPage));
  }

  Future<void> fetchProduct(int userId, int roleId,
      {
      String searchQuery = '',
      String category = '',
      String unit_type = '',
      String sort_type = '',
      String sorting = ''}) async {
        // ${$userId}/${$roleId}///${searchQuery}/${category}/${unit_type}/${sort_type}/${sorting}/${limit}/${offset}
    final link =
        'http://leap.crossnet.co.id:8888/products/store_warehouse/$userId/$roleId///${searchQuery}/${category}/${unit_type}/${sort_type}/${sorting}/$limit/0';
        print(link);
    isLoading = true;
    notifyListeners();

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
        isLoading = false;
        maxRow = FetchAllProducts.fromJson(temp).totalRows!;
        _paginatorController.currentPage = 0;
        notifyListeners();

        _listProduct = FetchAllProducts.fromJson(temp).data!;
      } else {
        _listProduct = [];
      }
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      // throw Exception('Login Failed, Try Again');
      print('fetch failed');
      _listProduct = [];
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
}
