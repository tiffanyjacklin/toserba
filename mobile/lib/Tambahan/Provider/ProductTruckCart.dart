import 'dart:collection';
import 'dart:convert';
// import 'dart:ffi';
import 'package:flutter_app_all/Model/ResponsePostTransferNotes.dart'
    as responseTransfer;
import 'package:flutter_app_all/Model/StockTransferNotesDetailWarehouse.dart'
    as transferDetail;
import 'package:flutter_app_all/Model/UpdateDeliveryOrder.dart';
import 'package:flutter_app_all/Model/UserData.dart' as user;
// import 'package:flutter_app_all/Page/Login/login_tablet.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class ProductTruckCartProvider extends ChangeNotifier {
  // Constructor init value
  ProductTruckCartProvider(int noteId, user.Data data) {
    this.userData = data;
    // call the api...
    resetCartDefault(noteId);

    this.noteId = noteId;
  }

  /// Internal, private state of the cart.
  user.Data? userData = null;

  List<transferDetail.Data> _items = [];
  late List<transferDetail.Data> _allItemRemaining = [];
  late int noteId;
  List<TextEditingController> _listInputQuantity = [];

  /// An unmodifiable view of the items in the cart.
  UnmodifiableListView<transferDetail.Data> get items =>
      UnmodifiableListView(_items);

  /// An unmodifiable view of the items in the cart.
  UnmodifiableListView<TextEditingController> get listControllerInput =>
      UnmodifiableListView(_listInputQuantity);

  // check if empty
  bool get isEmptyCart => _items.isEmpty;

  /// loading state
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  set isLoading(bool isload) {
    _isLoading = isload;
    notifyListeners();
  }

  // Removes all items from the cart.
  void remove(int index) {
    _items.removeAt(index);
    _listInputQuantity.removeAt(index);

    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  void resetCartDefault(int noteId) {
    isLoading = true;

    // hapus semua
    _items.clear();
    _listInputQuantity.clear();

    // misal belum di load dari api
    if (_allItemRemaining.isEmpty) {
      _fetchTransferNotesDetail(noteId).then((result) => {
            _allItemRemaining = result,
            // masukin dari hasil api sebelumnya
            _items = _allItemRemaining
                .toList()
                .where((i) => i.remainingQuantity != 0)
                .toList(), // NOTE coba

            _listInputQuantity =
                List.generate(_items.length, (i) => TextEditingController()),

            isLoading = false,
            notifyListeners(),
          });
    }

    // misal sudah
    else {
      // ubah cart karena dah difetch sebelumnya
      _items = _allItemRemaining.toList();
      _listInputQuantity =
          List.generate(_items.length, (i) => TextEditingController());

      isLoading = false;
      notifyListeners();
    }
  }

  // check cart if there is empty input
  bool isThereEmptyField() {
    for (TextEditingController input in _listInputQuantity) {
      if (input.text == '') {
        return true;
      }
    }
    return false;
  }

  // submit the cart
  Future<void> submit(String notes) async {
    // panggil lah semua api untuk post + put update
    _InsertDeliveryOrderDetails(noteId, items, listControllerInput)
        .then((result) => {
              if (result.isNotEmpty)
                {
                  print('selesai insert ==='),
                  _updateDeliveryOrderDetails(
                      result.first.deliveryOrderId!, userData!.userId!, notes).then((onValue){
                      })
                }
              else{
                print('failed to make delivery notes')
              }
            });
  }

// fecth ini buat cari barang yang kurang (buat di input data)
Future<List<transferDetail.Data>> _fetchTransferNotesDetail(int noteId) async {
  final link =
      'http://leap.crossnet.co.id:8888/orders/transfer/notes/detail/$noteId';

  // call api
  final response = await http.get(Uri.parse(link));
  print('---> response ' + response.statusCode.toString() + ' l ' + link);

  // cek status
  if (response.statusCode == 200) {
    Map<String, dynamic> temp = json.decode(response.body);
    print(response.body);
    if (temp['status'] == 200) {
      return transferDetail.StockTransferNotesDetailWarehouse.fromJson(temp)
          .data!;
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
}

// POST -> for adding create delivery order
Future<List<responseTransfer.Data>> _InsertDeliveryOrderDetails(
    int transferNoteId,
    List<transferDetail.Data> data,
    List<TextEditingController> controllerInput) async {
  final link =
      'http://leap.crossnet.co.id:8888/orders/delivery/add/$transferNoteId';

  // buat isi nya dulu
  List<Map<String, dynamic>> bodyContent = List.generate(
      data.length,
      (i) => {
            "product_detail_id": data[i].productDetailId,
            "quantity": int.parse(controllerInput[i].text),
            "expired_date":
                '${DateFormat('yyyy-MM-dd').format(DateTime.parse(data[i].expiredDate!))}', //   "2024-08-20",
            "batch": data[i].batch
          });

  // call api
  final response =
      await http.post(Uri.parse(link), body: jsonEncode(bodyContent));
  print(response.body + ' --> hasil notes');

  // cek status
  if (response.statusCode == 200) {
    Map<String, dynamic> temp = json.decode(response.body);

    if (temp['status'] == 200) {
      print(temp);
      return responseTransfer.ResponsePostTransfer.fromJson(temp).data!;
    } else {
      return [];
    }
  } else {
    print('fetch failed');
    return [];
  }
}

// // Menambah produk pada suatu surat jalan
// e.POST("/orders/delivery/add/:transfernote_id", controller.InsertDeliveryOrderDetails)
// [
//     {
//         "product_detail_id": 4,
//         "quantity": 5,
//         "expired_date" : "2024-08-20",
//         "batch": 1
//     }
// ]

// // Menambah detail surat jalan, setelah menambah semua produk
// e.PUT("/orders/delivery/update/:deliveryorder_id", controller.InsertDeliveryOrders)
// {
//     "user_id_from": 3,
//     "notes": "Apa aja boleh"
// }

Future<void> _updateDeliveryOrderDetails(
    int deliveryId, int userId, String notes) async {
  print('---- masuk update delivery');
  final link =
      'http://leap.crossnet.co.id:8888/orders/delivery/update/$deliveryId';

  Map<String, dynamic> bodyContext = {
    "user_id_from": userId,
    "notes": notes.toString()
  };
  // call api (method PUT)
  final response =
      await http.put(Uri.parse(link), body: jsonEncode(bodyContext));

  print('---> response ' + response.statusCode.toString());

  // cek status
  if (response.statusCode == 200) {
    // misal oke berati masuk
    // json
    Map<String, dynamic> temp = json.decode(response.body);
    // decode?
    print(response.body);
    if (temp['status'] == 200) {
      var response2 = UpdateDeliveryOrder.fromJson(temp);
      _fetchNotification(deliveryId);
      print('berhasil update');
    } else {
      print('gagal?');
    }
  } else {
    print('fetch failed');
  }
}

 // fetch notif
  Future<bool> _fetchNotification(int deliveryId) async {
    // link api
    final link = 'http://leap.crossnet.co.id:8888/notifications/add';

    Map<String, dynamic> jsonBody = {
        "user_id": userData!.userId,
        "roles_id": userData!.roleId,
        "description":
            "User ID ${userData!.userId!} telah membuat delivery order ID ${deliveryId} pada ${DateTime.now().toLocal().toString()}",
        "notification_type_id": 6 // id for create delivery
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
}
