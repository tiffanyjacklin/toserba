import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_app_all/Model/StockDescription.dart' as description;
import 'package:flutter_app_all/Model/AllCategory.dart' as category;
import 'package:flutter_app_all/Model/StockCardProductStoreWarehouse.dart'
    as stock;
import 'package:flutter_app_all/Template.dart';
import 'package:http/http.dart' as http;
import 'package:number_paginator/number_paginator.dart';

class ResultFilter {
  String description, unit, type, startDate, endDate;

  ResultFilter(
      {required this.description,
      required this.startDate,
      required this.endDate,
      required this.unit,
      required this.type});
}

class HistoryAllProductProvider extends ChangeNotifier {
  // constructor
  HistoryAllProductProvider() {
    // fetch result and fetch categories and fetch descripstion
    searchItemWithFilter('');
    _fetchAllProductCategories();
    _fetchAllDescription();
  }
  // >> check fetch
  bool isLoading = true;
  int totalRow = 0;

  // >> result stockcard
  List<stock.Data> _result = [];

  // >> for filter
  bool isFiltering = false;
  List<description.Data> descStock = [];
  List<String> unitType = ['Units', 'Grams'];
  List<category.Data> productType = [];
  late Map<String, category.Data> _mapCategory;

  String _descNow = '';
  List<DateTime> rangeDate = [DateTime(2000), DateTime.now()];
  String _unitNow = '';
  String _typeNow = '';

  // Getter
  String get descNow => _descNow;
  String get unitNow => _unitNow;
  String get typeNow => _typeNow;

  DateTime getIsStartDate(bool isStart) {
    if (isStart) {
      return rangeDate.first;
    } else {
      return rangeDate.last;
    }
  }

  // >> for paginator
  int limitPerPage = 5;
  // int currentPage = 0;
  final NumberPaginatorController _paginatorController =
      NumberPaginatorController();
  int get currentPage => _paginatorController.currentPage;
  NumberPaginatorController get paginatorController => _paginatorController;
  List<stock.Data> get resultSearched => UnmodifiableListView(_result);
  List<stock.Data> get listPerPage =>
      UnmodifiableListView(_result.sublist(getStartIndex(), getEndIndex() + 1));

  // Setter filter
  void setDesc(String name) {
    _descNow = name;
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

  void setRangeDate(DateTime dateTime, bool isStart) {
    if (isStart) {
      rangeDate.first = dateTime;
    } else {
      rangeDate.last = dateTime;
    }
    notifyListeners();
  }

  void resetFilter() {
    _descNow = '';
    _unitNow = '';
    _typeNow = '';
    rangeDate = [DateTime(2000), DateTime.now()];
    notifyListeners();
  }

  ResultFilter getResult() {
    var category = '';
    if (_typeNow != '') {
      // cari dalam index
      category = _mapCategory[_typeNow]!.productCategoryId.toString();
    }

    var unit = '';
    if (_unitNow != '') {
      unit = _unitNow.substring(0, _unitNow.length - 1).toLowerCase();
    }

    var startDate = formatOnlyDateSQL(rangeDate.first);
    var endDate = formatOnlyDateSQL(rangeDate.last);

    return ResultFilter(
        startDate: startDate,
        endDate: endDate,
        description: _descNow,
        unit: unit,
        type: category);
  }

  void clickFilter(String name) {
    isFiltering = !isFiltering;

    if (!isFiltering) {
      var resultfilter = getResult();
      searchItemWithFilter(name,
          startDate: resultfilter.startDate,
          endDate: resultfilter.endDate,
          category: resultfilter.type,
          unitType: resultfilter.unit,
          description: resultfilter.description,
          isSearch: true);
    }
    notifyListeners();
  }

  // paginator purpose
  int getStartIndex() {
    return currentPage * limitPerPage;
  }

  int getEndIndex() {
    if (currentPage == getMaxPage() - 1) {
      return _result.length - 1;
    }
    return (currentPage + 1) * limitPerPage - 1;
  }

  int getCurrentMaxPage() {
    return (_result.length.toDouble() / limitPerPage.toDouble()).floor();
  }

  int getMaxPage() {
    return (totalRow.toDouble() / limitPerPage.toDouble()).ceil();
  }

  // lah rusak lagi ?? lahhhhhh
  void setCurrentPage(String name, int number) {
    _paginatorController.currentPage = number;
    // cek butuh fetch setelah page ini?
    if (number > getCurrentMaxPage() - 1 && _result.length != totalRow) {
      searchItemWithFilter(name);
    }
    notifyListeners();
  }

  // void increase(String name){
  //   setCurrentPage(name, currentPage+1);
  // }

  // void decrease(String name){
  //   setCurrentPage(name, currentPage-1);
  // }

  // Api fetch
  Future<void> searchItemWithFilter(
    String name, {
    String startDate = '',
    String endDate = '',
    String category = '',
    String unitType = '',
    String description = '',
    String search = '',
    bool isSearch = false,
  }) async {
    isLoading = true;
    notifyListeners();

    List<stock.Data> result = await _fetchAllStockProductWarehouse(
        2, startDate, endDate, category, unitType, description, name, isSearch);

    if (isSearch) {
      _result = result;
    } else {
      _result += result;
    }
    isLoading = false;
    notifyListeners();
  }

  Future<List<stock.Data>> _fetchAllStockProductWarehouse(
      int warehouseId,
      String startDate,
      String endDate,
      String category,
      String unitType,
      String description,
      String search,
      bool isSearch) async {
    int startIndex = 0;
    int limitData = 100000;

    try {
      // /products/stock/card/product/store_warehouse/:storewarehouse_id/:start_date/:end_date/:category/:unit_type/:description/:product_name_id_code_batch/:limit/:offset
      final link =
          'http://leap.crossnet.co.id:8888/products/stock/card/product/store_warehouse/$warehouseId/$startDate/$endDate/$category/$unitType/$description/$search/$limitData/$startIndex';

      // call api (method PUT)
      final response = await http.get(Uri.parse(link));
      print('---> response ' + response.statusCode.toString());
      print(link);
      // cek status
      if (response.statusCode == 200) {
        // misal oke berati masuk
        // json
        Map<String, dynamic> temp = json.decode(response.body);
        // decode?
        print(response.body);
        if (temp['status'] == 200) {
          print(temp);
          totalRow = stock.FetchStockCardProductStoreWarehouse.fromJson(temp)
              .totalRows!;
          if (isSearch) {
            _paginatorController.currentPage = 0;
          }

          return stock.FetchStockCardProductStoreWarehouse.fromJson(temp).data!;
        } else {
          return [];
        }
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        // throw Exception('Login Failed, Try Again');
        print('fetch failed');
        return [];
      }
    } on SocketException catch (e) {
      print("Caught socketexception: $e");
    } on TimeoutException catch (e) {
      print('Caught: $e');
    } catch (e) {}
    //print('Done');
    return [];
  }

  Future<void> _fetchAllDescription() async {
    try {
      // http://leap.crossnet.co.id:8888/products/stock/card/description
      final link =
          'http://leap.crossnet.co.id:8888/products/stock/card/description';

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
          descStock = description.FetchStockDescription.fromJson(temp).data!;
          isLoading = false;
          notifyListeners();
        }
      } else {
        print('fetch failed');
      }
    } on SocketException catch (e) {
      print("Caught socketexception: $e");
    } on TimeoutException catch (e) {
      print('Caught: $e');
    } catch (e) {}
    //print('Done');
    return;
  }

  // future for intial value
  Future<void> _fetchAllProductCategories() async {
    try {
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
    } on SocketException catch (e) {
      print("Caught socketexception: $e");
    } on TimeoutException catch (e) {
      print('Caught: $e');
    } catch (e) {}
    //print('Done');
    return;
  }
}
