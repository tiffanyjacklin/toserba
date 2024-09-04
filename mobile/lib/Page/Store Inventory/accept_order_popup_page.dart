import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_app_all/TableTemplate/TableSuratJalan.dart';
import 'package:flutter_app_all/Template.dart';
import 'package:screenshot/screenshot.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:share_plus/share_plus.dart';

class DeliveryOrderDetailPopUp extends StatefulWidget {
  DeliveryOrderDetailPopUp({
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
                    data: '#1110101010',
                  ),
                  DeliveryOrderDetailsChild(
                    judul: 'Date',
                    data: '01 July 2024',
                  ),
                  DeliveryOrderDetailsChild(
                    judul: 'Delivery Order',
                  ),

                  // nota delivery nya
                  Screenshot(
                      controller: controllerPrintOrder,
                      child: NoteDeliveryOrder()),

                  SizedBox(
                    height: 10,
                  ),

                  // button print table
                  Container(
                    // height: 50,
                    width: MediaQuery.of(context).size.width * 0.55 * 0.45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorPalleteLogin.OrangeLightColor,
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
                        await controllerPrintOrder.capture().then((bytes) {
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
                            fontSize: 16,
                            color: ColorPalleteLogin.OrangeLightColor,
                            fontWeight: FontWeight.bold),
                      ),
                      children: [
                        Screenshot(
                          controller: controllerPrintStock,
                          child: TableStockCard()
                          ),
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
                                        fontSize: 14,
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

                  // Table Accept Stock form
                  DeliveryOrderDetailsChild(
                    judul: 'Accept Stock Form',
                  ),
                  // cek button misal udah buka
                  isFormNotCreated
                      ? Container(
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
                                  Text(
                                    '+ Created Accept Stock Form',
                                    style: TextStyle(
                                      color: ColorPalleteLogin.PrimaryColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                isFormNotCreated = false;
                              });
                            },
                          ),
                        )
                      : TableAcceptStockForm(),

                  SizedBox(
                    height: 20,
                  ),
                  // Button Save
                  Center(
                    child: Container(
                      height: 50,
                      width: MediaQuery.of(context).size.width * 0.55 * 0.5,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorPalleteLogin.OrangeLightColor,
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
                          // sementara masih close popup
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
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
  const TableStockCard({
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
                      child: Text('Unit',
                          style: TextStyle(
                            fontSize: 14,
                          )),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('123456789',
                          style: TextStyle(
                            fontSize: 14,
                          )),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('10/10/2024',
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
