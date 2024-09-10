import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_app_all/Model/DeliveryTransferDetail.dart'
    as deliveryDetail;
import 'package:flutter_app_all/Model/DeliveryTransferNote.dart'
    as deliveryTrasnfer;
import 'package:flutter_app_all/Model/StockTransferNotesWarehouse.dart'
    as transfer;

// fecth api
Future<List<transfer.Data>> fetchTransferNotes() async {
  // var fromId = 2; // anggepannya ngirim barang dari gudang ini

  final link = 'http://leap.crossnet.co.id:8888/orders/transfer/notes/all/0/0';

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
      return transfer.StockTransferNotesWarehouse.fromJson(temp).data!;
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

// fetch delivery transfer notes
Future<List<deliveryTrasnfer.Data>> fetchDeliveryTransferNotes(
    int noteId) async {
  final link =
      'http://leap.crossnet.co.id:8888/orders/delivery/transfernote/$noteId';

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
      return deliveryTrasnfer.FetchDeliveryTransferNotes.fromJson(temp).data!;
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

// fetch detail for delivery transfer note
// http://leap.crossnet.co.id:8888/orders/delivery/detail/13

Future<List<deliveryDetail.Data>> fetchDeliveryTransferNotesDetail(
    int deliveryId) async {
  final link =
      'http://leap.crossnet.co.id:8888/orders/delivery/detail/$deliveryId';

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
      return deliveryDetail.FetchDeliveryTransferDetail.fromJson(temp).data!;
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