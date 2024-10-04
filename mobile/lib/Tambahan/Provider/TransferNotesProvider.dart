import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_app_all/Model/StockTransferNotesWarehouse.dart'
    as transfer;
import 'package:flutter_app_all/Template.dart';
import 'package:number_paginator/number_paginator.dart';
import 'package:http/http.dart' as http;

class TransferNotesProvider extends ChangeNotifier {
  TransferNotesProvider(int storeWarehouseId) {
    fetchTransferNotes(storeWarehouseId);
  }

  List<transfer.Data> _listTransferNotes = [];
  bool isLoading = true;
  // Map<int, Data> mappingPaginator = {};
  UnmodifiableListView get listTransferNotes =>
      UnmodifiableListView(_listTransferNotes);

  // >> for paginator
  int limit = 100000;
  // int indexPageNow = 0;
  int itemPerPage = 3;
  int maxRow = 0;
  final NumberPaginatorController _paginatorController =
      NumberPaginatorController();
  int get indexPageNow => _paginatorController.currentPage;
  NumberPaginatorController get paginatorController => _paginatorController;

  // >> for filter
  bool _isFiltering = false;
  List<String> listStatusVerify = ['Not Verified', 'Verified'];
  List<String> listStatusSend = ['Not Send', 'Send'];
  List<DateTime> rangeDate = [DateTime(2000), DateTime.now()];

  String _statVer = '';
  String _statSend = '';

  // getter
  bool get isFiltering => _isFiltering;
  String get statusVerify => _statVer;
  String get statusSend => _statSend;

  // setter
  set isFiltering(bool i) {
    _isFiltering = i;
    notifyListeners();
  }

  set statusVerify(String name) {
    _statVer = name;
    notifyListeners();
  }

  set statusSend(String name) {
    _statSend = name;
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
    _statSend = '';
    _statVer = '';
    rangeDate = [DateTime(2000), DateTime.now()];
    notifyListeners();
  }

  void clickFilter(int storeId, String name) {
    isFiltering = !isFiltering;

    if (!isFiltering) {
      String verified = '';
      String sended = '';

      if (_statVer.isNotEmpty) {
        verified = listStatusVerify.indexOf(_statVer).toString();
      }
      if (_statSend.isNotEmpty) {
        sended = listStatusSend.indexOf(_statSend).toString();
      }

      fetchTransferNotes(storeId,
          search: name,
          statusVerify: verified,
          statusSend: sended,
          startDate: formatOnlyDateSQL(rangeDate.first),
          endDate: formatOnlyDateSQL(rangeDate.last),
          isSearch: true);
    }
    notifyListeners();
  }

  int getMaxPage() {
    if (_listTransferNotes.isEmpty) {
      return 0;
    }
    return (_listTransferNotes.length.toDouble() / itemPerPage.toDouble())
        .ceil();
  }

  List<transfer.Data> getItemPerPage() {
    if (_listTransferNotes.isEmpty) {
      return [];
    }
    if (indexPageNow == getMaxPage() - 1) {
      return _listTransferNotes.sublist(
          (indexPageNow * itemPerPage), _listTransferNotes.length);
    }
    return _listTransferNotes.sublist(
        (indexPageNow * itemPerPage), ((indexPageNow + 1) * itemPerPage));
  }

  // fecth api
  Future<void> fetchTransferNotes(int storeId,
      {String search = '',
      String statusVerify = '',
      String statusSend = '',
      String startDate = '',
      String endDate = '',
      bool isSearch = false}) async {
    // var fromId = 2; // anggepannya ngirim barang dari gudang ini
    // http://leap.crossnet.co.id:8888/orders/transfer/notes/all/2///1////0/0
    // /orders/transfer/notes/all/:transfernote_id/:sw_from/:sw_to/:status_verif/:status_send/:start_date/:end_date/:limit/:offset
    final link =
        'http://leap.crossnet.co.id:8888/orders/transfer/notes/all/$search/$storeId//$statusVerify/$statusSend/$startDate/$endDate/$limit/0';
    print(link);

    try {
      isLoading = true;
      notifyListeners();
      // call api (method PUT)
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
          maxRow =
              transfer.StockTransferNotesWarehouse.fromJson(temp).totalRows!;
          if (isSearch) {
            paginatorController.currentPage = 0;
          }
          _listTransferNotes =
              transfer.StockTransferNotesWarehouse.fromJson(temp).data!;
        } else {
          _listTransferNotes = [];
        }
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        // throw Exception('Login Failed, Try Again');
        print('fetch failed');
        _listTransferNotes = [];
      }

      isLoading = false;
      notifyListeners();
    } on SocketException catch (e) {
      print("Caught socketexception: $e");
    } on TimeoutException catch (e) {
      print('Caught: $e');
    } catch (e) {}
    //print('Done');
    return null;
  }
}
