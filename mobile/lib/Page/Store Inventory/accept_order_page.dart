import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_all/Model/DeliveryOrderStore.dart' as deliveryStore;
import 'package:flutter_app_all/Tambahan/Provider/AcceptOrderDelivery.dart';
import 'package:flutter_app_all/Template.dart';
import 'package:flutter_app_all/Page/Store%20Inventory/accept_order_popup_page.dart';
import 'package:number_paginator/number_paginator.dart';
import 'package:provider/provider.dart';
import 'package:stroke_text/stroke_text.dart';
import 'package:http/http.dart' as http;

// api fetch accept order --> ambil semua delivery order yang ada ke toko ini anggep ni toko 1
Future<List<deliveryStore.Data>> _fetchDeliveryOrderStore(int storeId) async {
  final link =
      'http://leap.crossnet.co.id:8888/orders/delivery/warehouse/to/$storeId/3/0'; // NOTE : diganti nanti kalo udah ada

  // NOTE : 3 = limit row yang diambil, 0 = start index,

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
      return deliveryStore.FetchDeliveryOrderStore.fromJson(temp).data!;
    } else {
      return [];
    }
  } else {
    print('fetch failed');
    return [];
  }
}

class AcceptOrderPage extends StatefulWidget {
  AcceptOrderPage({super.key});

  @override
  State<AcceptOrderPage> createState() => _AcceptOrderPageState();
}

class _AcceptOrderPageState extends State<AcceptOrderPage> {
  final NumberPaginatorController _controller = NumberPaginatorController();
  var _currentPage = 1;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: Colors.grey),
        ),
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.only(
              left: 8.0, right: 8.0, top: 16.0, bottom: 8.0),
          child: Column(
            children: [
              TitlePage(name: 'Accept Order'),
              SizedBox(
                height: 20,
              ),
              // search bar
              Container(
                width: MediaQuery.of(context).size.width * 0.70,
                child: const CupertinoSearchTextField(
                    // trailing: Icon(Icons.abc),
                    ),
              ),

              SizedBox(
                height: 20,
              ),

              // pagination nya

              // list tiles view
              // making self
              // DeliveryOrderChild(),
              // DeliveryOrderChild(),
              // DeliveryOrderChild(),

              Container(
                width: MediaQuery.of(context).size.width * 0.70,
                child: NumberPaginator(
                  // by default, the paginator shows numbers as center content
                  numberPages: 5,
                  onPageChange: (int index) {
                    setState(() {
                      _currentPage =
                          index; // _currentPage is a variable within State of StatefulWidget
                    });
                  },
                  // show/hide the prev/next buttons
                  showPrevButton: true,
                  showNextButton: true, // defaults to true
                  // custom content of the prev/next buttons, maintains their behavior
                  nextButtonBuilder: (context) => TextButton(
                    onPressed: _controller.currentPage > 0
                        ? () => _controller.next()
                        : null, // _controller must be passed to NumberPaginator
                    child: const Row(
                      children: [
                        Text("Next"),
                        Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                  // custom prev/next buttons using builder (ignored if showPrevButton/showNextButton is false)
                  prevButtonBuilder: (context) => TextButton(
                    onPressed: _controller.currentPage > 0
                        ? () => _controller.prev()
                        : null, // _controller must be passed to NumberPaginator
                    child: const Row(
                      children: [
                        Icon(Icons.chevron_left),
                        Text("Previous"),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),

              // with api run
              Container(
                // height: 400,
                child: FutureBuilder<List<deliveryStore.Data>>(
                    future: _fetchDeliveryOrderStore(1),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        // get error
                        if (snapshot.hasError) {
                          return Center(
                            child: Text('error fetch'),
                          );
                        } else {
                          if (!(snapshot.data!.isEmpty)) {
                            return ListView.builder(
                              shrinkWrap: true,
                              itemCount: 3,
                              itemBuilder: (BuildContext context, int index) {
                                return DeliveryOrderChild(
                                    data: snapshot.data![
                                        index + 0 + ((_currentPage - 1) * 3)]);
                              },
                            );
                          } else {
                            return Column();
                          }
                        }
                      } else {
                        return CircularProgressIndicator();
                      }
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DeliveryOrderChild extends StatelessWidget {
  deliveryStore.Data data;

  DeliveryOrderChild({
    required this.data,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.70,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black38,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              // leading
              Expanded(
                flex: 1,
                child: Icon(
                  Icons.insert_drive_file_outlined,
                  size: 40,
                ),
              ),

              // center
              Expanded(
                flex: 6,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivery Order ${data.deliveryOrderId}',
                      style: TextStyle(
                        color: ColorPalleteLogin.PrimaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      getDateWithTime(data.orderTimestamp!),
                      style: TextStyle(
                        color: ColorPalleteLogin.PrimaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    // cek status accepted
                    data.statusAccept == 0
                        ? StrokeText(
                            text: 'Unchecked !!',
                            textStyle: TextStyle(
                              color: ColorPalleteLogin.OrangeLightColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          )
                        : Text(
                            'Checked',
                            style: TextStyle(
                              color: ColorPalleteLogin.PrimaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                  ],
                ),
              ),

              // trailing
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: () {
                    // buat alert dialog
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (context) => ChangeNotifierProvider(
                        create: (context) => AcceptOrderDeliveryProvider(data.deliveryOrderId!),
                        child: DeliveryOrderDetailPopUp(dataDelivery: data),
                      ),
                    );
                  },
                  child: Container(
                    height: double.maxFinite,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(10),
                          bottomRight: Radius.circular(10)),
                      color: ColorPalleteLogin.PrimaryColor,
                    ),
                    child: Icon(
                      Icons.remove_red_eye_outlined,
                      size: 32,
                      color: ColorPalleteLogin.OrangeLightColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }
}
