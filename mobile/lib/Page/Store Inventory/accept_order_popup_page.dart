import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:Toserba_App/Page/Store%20Inventory/accept_order_accepting_page.dart';
import 'package:Toserba_App/TableTemplate/TableSuratJalan.dart';
import 'package:Toserba_App/Tambahan/Provider/AcceptOrderDelivery.dart';
import 'package:Toserba_App/Tambahan/Provider/Auth.dart';
import 'package:Toserba_App/Template.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:Toserba_App/Model/DeliveryOrderStore.dart' as deliveryStore;
import 'package:Toserba_App/Model/DeliveryTransferDetail.dart'
    as deliveryDetail;
import 'package:http/http.dart' as http;

class DeliveryOrderDetailPopUp extends StatefulWidget {
  final deliveryStore.Data dataDelivery;

  DeliveryOrderDetailPopUp({
    required this.dataDelivery,
    super.key,
  });

  @override
  State<DeliveryOrderDetailPopUp> createState() =>
      _DeliveryOrderDetailPopUpState();
}

class _DeliveryOrderDetailPopUpState extends State<DeliveryOrderDetailPopUp> {
  var isFormNotCreated = true;
  var _customTileExpanded = false;

  // controller
  final controllerPrintOrder = ScreenshotController();
  final controllerPrintStock = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    final deliveryList = Provider.of<AcceptOrderDeliveryProvider>(context);

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.7,
        decoration: BoxDecoration(
          color: ColorPalleteLogin.PrimaryColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            // BoxShadow(
            //   color: ColorPalleteLogin.OrangeColor,
            //   offset: Offset(0, 6),
            // ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Scrollbar(
            thickness: 1,
            thumbVisibility: false,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Align(
                    child: GestureDetector(
                      onTap: () {
                        // help pop
                        Navigator.of(context).pop();
                      },
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    alignment: Alignment.topRight,
                  ),
                  Center(
                      child: Text(
                    'Delivery Order',
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                              blurRadius: 2.0,
                              color: Colors.black,
                              offset: Offset(1, 1)),
                        ]),
                  )),
                  SizedBox(
                    height: 20,
                  ),

                  DeliveryOrderDetailsChild(
                    judul: 'Delivery Order ID',
                    data: '${widget.dataDelivery.deliveryOrderId}',
                  ),
                  DeliveryOrderDetailsChild(
                    judul: 'Date',
                    data: getOnlyDate(widget.dataDelivery.orderTimestamp!),
                  ),

                  DeliveryOrderDetailsChild(
                    judul: 'Delivery Order',
                  ),

                  deliveryList.isLoading
                      ? CircularProgressIndicator()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // nota delivery nya
                            Screenshot(
                                controller: controllerPrintOrder,
                                child: NoteDeliveryOrder(
                                    listItemDelivery: deliveryList.items)),

                            SizedBox(
                              height: 10,
                            ),

                            // button print table
                            Container(
                              // height: 50,
                              width: MediaQuery.of(context).size.width *
                                  0.55 *
                                  0.45,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      ColorPalleteLogin.OrangeLightColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Wrap(
                                    spacing: 6,
                                    children: [
                                      Icon(
                                        Icons.print_outlined,
                                        color: ColorPalleteLogin.PrimaryColor,
                                      ),
                                      Text(
                                        'Print delivery order',
                                        style: TextStyle(
                                          color: ColorPalleteLogin.PrimaryColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                onPressed: () async {
                                  await controllerPrintOrder
                                      .capture()
                                      .then((bytes) {
                                    if (bytes != null) {
                                      // panggil woe
                                      saveImage(bytes, 'DeliveryOrder');
                                      // saveAndShare(bytes, 'DeliveryOrder');
                                    }
                                  }).catchError((onError) {
                                    debugPrint(onError);
                                  });
                                },
                              ),
                            ),
                          ],
                        ),

                  // table stock card
                  Theme(
                    data: Theme.of(context)
                        .copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      trailing: Icon(
                        _customTileExpanded
                            ? Icons.arrow_drop_down_circle
                            : Icons.arrow_drop_down,
                        color: ColorPalleteLogin.OrangeColor,
                      ),
                      title: Text(
                        'Stock Card',
                        style: TextStyle(
                            fontSize: fontSizeBody,
                            color: ColorPalleteLogin.OrangeLightColor,
                            fontWeight: FontWeight.bold),
                      ),
                      children: [
                        Screenshot(
                            controller: controllerPrintStock,
                            child: TableStockCard(
                              listData: deliveryList.items,
                            )),
                        SizedBox(
                          height: 10,
                        ),

                        // button print table
                        Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            // height: 50,
                            width:
                                MediaQuery.of(context).size.width * 0.55 * 0.45,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    ColorPalleteLogin.OrangeLightColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Wrap(
                                  spacing: 6,
                                  children: [
                                    Icon(
                                      Icons.print_outlined,
                                      color: ColorPalleteLogin.PrimaryColor,
                                    ),
                                    Text(
                                      'Print Stock Card',
                                      style: TextStyle(
                                        color: ColorPalleteLogin.PrimaryColor,
                                        fontSize: fontSizeSmall,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              onPressed: () async {
                                await controllerPrintStock
                                    .capture()
                                    .then((bytes) {
                                  if (bytes != null) {
                                    // panggil woe
                                    saveImage(bytes, 'StockCard');
                                    // saveAndShare(bytes, 'StockCard');
                                  }
                                }).catchError((onError) {
                                  debugPrint(onError);
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                      onExpansionChanged: (value) {
                        setState(() {
                          _customTileExpanded = !_customTileExpanded;
                        });
                      },
                    ),
                  ),

                  SizedBox(
                    height: 20,
                  ),
                  
                  // Button Save
                  deliveryList.isAccepted
                      ? Row(
                          children: [
                            Center(
                              child: Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width *
                                    0.55 *
                                    0.5,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        ColorPalleteLogin.OrangeLightColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                  ),
                                  child: Wrap(
                                    spacing: 12,
                                    children: [
                                      Text(
                                        'Save',
                                        style: TextStyle(
                                          color: ColorPalleteLogin.PrimaryColor,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  onPressed: () {
                                    // input barang yang diterima

                                    if (!deliveryList.isAccepted) {
                                      // sementara masih close popup
                                      fetchAcceptOrder(widget
                                              .dataDelivery.deliveryOrderId!)
                                          .then((onValue) => {
                                                Navigator.pop(context,
                                                    'Success'),
                                              });
                                    } else {
                                      Navigator.pop(context, '');
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Center(
                              child: Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width *
                                    0.55 *
                                    0.5,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        ColorPalleteLogin.OrangeLightColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                  ),
                                  child: Wrap(
                                    spacing: 12,
                                    children: [
                                      Text(
                                        'Close',
                                        style: TextStyle(
                                          color: ColorPalleteLogin.PrimaryColor,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context, '');
                                  }
                                ),
                              ),
                            ),

                            SizedBox(
                              width: 30,
                            ),

                            Center(
                              child: Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width *
                                    0.55 *
                                    0.5,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        ColorPalleteLogin.OrangeLightColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                  ),
                                  child: Wrap(
                                    spacing: 12,
                                    children: [
                                      Text(
                                        'Accept',
                                        style: TextStyle(
                                          color: ColorPalleteLogin.PrimaryColor,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  onPressed: () async {
                                    // pindah halaman selanjutnya
                                    // tinggal navigator push -> pindah ke selanjutnya
                                    final result  = await Navigator.push(context, MaterialPageRoute(
                                      builder: (context) => AcceptingPage(dataDelivery: deliveryList.items, userId : Provider.of<AuthState>(context).userId!)));

                                    if(result.toString().isNotEmpty){
                                      // balik ke halaman awal, tanpa popup
                                      Navigator.pop(context, result.toString());
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  final time = DateTime.now().toIso8601String().replaceAll('.', '-');

  // function saveimage
  Future<void> saveImage(Uint8List bytes, String name1) async {
    final name = 'Screentshot_$name1$time';
    await Permission.storage.request();
    final result = await ImageGallerySaver.saveImage(bytes, name: name);
    debugPrint('result : $result');
  }

  // function saveimage
  Future<void> saveAndShare(Uint8List bytes, String name1) async {
    final dir = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();

    // final image = File('${dir!.path}/$name1$time.png');
    // image.writeAsBytes(bytes);
    // await Share.shareXFiles([XFile(image.path)]);
  }

  Future<bool> fetchAcceptOrder(int deliveryOrder) async {
    final userId = 1;

    final link =
        'https://leap.crossnet.co.id:8888/store/orders/delivery/accept/$deliveryOrder/$userId'; // NOTE : diganti nanti kalo udah ada

    // call api
    final response = await http.put(Uri.parse(link));
    print('---> response ' + response.statusCode.toString());

    // cek status
    if (response.statusCode == 200) {
      // misal oke berati masuk
      // json
      Map<String, dynamic> temp = json.decode(response.body);
      // decode?
      print(response.body);
      if (temp['status'] == 200) {
        return true;
      }
    }
    return false;
  }
}

class TableAcceptStockForm extends StatelessWidget {
  const TableAcceptStockForm({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(6),
            2: FlexColumnWidth(3),
            3: FlexColumnWidth(3),
            4: FlexColumnWidth(2),
            5: FlexColumnWidth(3),
          },
          children: [
            // making the judul
            const TableRow(
              decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.black))),
              children: [
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('NO',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Product name',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('In',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Out',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Unit Type',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Total Counted',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),

            // making the content
            ...List.generate(
              10,
              (index) => TableRow(
                decoration: (index + 1) % 2 == 0
                    ? BoxDecoration(
                        color: ColorPalleteLogin.TableColor,
                      )
                    : null,
                children: [
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Nama Produk',
                          style: TextStyle(
                            fontSize: 14,
                          )),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        '10000',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        '-',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Unit',
                          style: TextStyle(
                            fontSize: 14,
                          )),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                        padding: EdgeInsets.all(8.0),
                        // >> note : BELUM DI LIMIT
                        child: TextField(
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(5.0),
                            isDense: true,
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: const BorderRadius.all(
                                const Radius.circular(10.0),
                              ),
                              borderSide: new BorderSide(
                                color: Colors.black,
                                width: 1.0,
                              ),
                            ),
                          ),
                        )),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TableStockCard extends StatelessWidget {
  List<deliveryDetail.Data> listData;

  TableStockCard({
    required this.listData,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(6),
            2: FlexColumnWidth(3),
            3: FlexColumnWidth(3),
            4: FlexColumnWidth(2),
            5: FlexColumnWidth(3),
            6: FlexColumnWidth(4),
          },
          children: [
            // making the judul
            const TableRow(
              decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.black))),
              children: [
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'NO',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Product name',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'In',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Out',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Unit Type',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Batch Number',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Expire Date',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),

            // making the content
            ...List.generate(
              listData.length,
              (index) => TableRow(
                decoration: (index + 1) % 2 == 0
                    ? BoxDecoration(
                        color: ColorPalleteLogin.TableColor,
                      )
                    : null,
                children: [
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('${listData[index].productName}',
                          style: TextStyle(
                            fontSize: 14,
                          )),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        '${listData[index].quantity}',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        '-',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('${listData[index].unitType}',
                          style: TextStyle(
                            fontSize: 14,
                          )),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('${listData[index].batch}',
                          style: TextStyle(
                            fontSize: 14,
                          )),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(getOnlyDate(listData[index].expiredDate!),
                          style: TextStyle(
                            fontSize: 14,
                          )),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DeliveryOrderDetailsChild extends StatelessWidget {
  String judul;
  String data;

  DeliveryOrderDetailsChild({
    this.judul = '',
    this.data = '',
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            this.judul,
            style: TextStyle(
                fontSize: 16,
                color: ColorPalleteLogin.OrangeLightColor,
                fontWeight: FontWeight.bold),
          ),
          Text(
            this.data,
            style: TextStyle(
                fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
