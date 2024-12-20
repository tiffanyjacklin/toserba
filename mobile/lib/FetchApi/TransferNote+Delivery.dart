import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:Toserba_App/Model/DeliveryTransferDetail.dart'
    as deliveryDetail;
import 'package:Toserba_App/Model/DeliveryTransferNote.dart'
    as deliveryTrasnfer;


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