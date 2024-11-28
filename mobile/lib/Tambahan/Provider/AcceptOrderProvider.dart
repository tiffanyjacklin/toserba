import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:Toserba_App/Template.dart';
import 'package:http/http.dart' as http;
import 'package:Toserba_App/Model/DeliveryOrderStore.dart' as deliveryStore;

class AcceptOrderProvider extends ChangeNotifier {
  AcceptOrderProvider(int storeId) {
    storeIdProvider = storeId;
    _fetchDeliveryOrderStore(storeId).then((onValue) => {notifyListeners()});
  }

  // >> store id
  int storeIdProvider = 0;
  // >> for filter
  bool isFiltering = false;
  List<DateTime> rangeDate = [DateTime(2000), DateTime.now()];
  String _checkStatus = '';
  Map<String, int> listChecked = {'Unchecked': 0, 'Checked': 1};

  String get checkStatus => _checkStatus;

  // >> for paginator
  int limitPerPage = 3;
  int currentPage = 0;

  /// Internal, private state of the cart.
  List<deliveryStore.Data> _items = [];

  /// An unmodifiable view of the items in the cart.
  UnmodifiableListView<deliveryStore.Data> get items =>
      UnmodifiableListView(_items);

  // loading
  bool isLoading = true;
  int totalRow = 0;

  List<deliveryStore.Data> get listPerPage => _items.isEmpty
      ? []
      : UnmodifiableListView(_items.sublist(getStartIndex(), getEndIndex()));

  // paginator purpose
  int getStartIndex() {
    return currentPage * limitPerPage;
  }

  int getEndIndex() {
    if (currentPage == getMaxPage() - 1) {
      return _items.length;
    }
    return (currentPage + 1) * limitPerPage;
  }

  int getMaxPage() {
    return (totalRow.toDouble() / limitPerPage.toDouble()).ceil();
  }

  void refresh(){
    _fetchDeliveryOrderStore(storeIdProvider);
    notifyListeners();
  }
  // filter
  void setRangeDate(DateTime dateTime, bool isStart) {
    if (isStart) {
      rangeDate.first = dateTime;
    } else {
      rangeDate.last = dateTime;
    }
    notifyListeners();
  }

  void setCheckStatus(String name) {
    if (name == '') {
      _checkStatus = '';
    } else {
      _checkStatus = listChecked[name].toString();
    }
    notifyListeners();
  }

  void filter(String name) {
    // isFiltering = !isFiltering;
    if (!isFiltering) {
      _fetchDeliveryOrderStore(storeIdProvider,
          search: name,
          statusAccept: checkStatus,
          startDate: formatOnlyDateSQL(rangeDate.first),
          endDate: formatOnlyDateSQL(rangeDate.last),
          isSearch: true);
      
    }
    notifyListeners();
  }

  void resetFilter() {
    _checkStatus = '';
    rangeDate = [DateTime(2000), DateTime.now()];
    notifyListeners();
  }

  // api fetch accept order --> ambil semua delivery order yang ada ke toko ini anggep ni toko 1
  Future<void> _fetchDeliveryOrderStore(int storeId,
      {String search = '',
      String statusAccept = '',
      String startDate = '',
      String endDate = '',
      bool isSearch = false}) async {
    int limit = 100000; // set default 10,000
    int offset = 0;

    if(isSearch){
      currentPage = 0;
    }

    isLoading = true;
    notifyListeners();

    try {
      // /to/:sw_to_id/:status_accept/:start_date/:end_date/:limit/:offset
      final link =
          'https://leap.crossnet.co.id:8888/orders/delivery/warehouse/to/$storeId/$statusAccept//$search/$startDate/$endDate/$limit/$offset';
      // NOTE : 3 = limit row yang diambil, 0 = start index,

      // call api
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
          _items = deliveryStore.FetchDeliveryOrderStore.fromJson(temp).data!;
          totalRow =
              deliveryStore.FetchDeliveryOrderStore.fromJson(temp).totalRows!;
        } else {
          _items = [];
        }
      } else {
        print('fetch failed');
        _items = [];
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
