import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_all/Template.dart';
import 'package:screenshot/screenshot.dart';
import 'package:stroke_text/stroke_text.dart';
import 'package:flutter_app_all/Model/StockCardProductStoreWarehouse.dart'
    as stock;

class StockTransferNotesPage extends StatelessWidget {
  const StockTransferNotesPage({super.key});

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
              Text('Stock Transfer Notes',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: ColorPalleteLogin.PrimaryColor,
                    fontFamily: 'Helvetica',
                  )),
              SizedBox(
                height: 20,
              ),
              // search bar
              Container(
                width: MediaQuery.of(context).size.width * 0.70,
                child: CupertinoSearchTextField(
                    // trailing: Icon(Icons.abc),
                    ),
              ),

              SizedBox(
                height: 20,
              ),

              // pagination nya

              // list tiles view

              // making self
              StockTransferNotesChild()
            ],
          ),
        ),
      ),
    );
  }
}

class StockTransferNotesChild extends StatelessWidget {
  StockTransferNotesChild({
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
                      'Stock Trasfer Note #112345667 ',
                      style: TextStyle(
                        color: ColorPalleteLogin.PrimaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '01-07-2024, 07:40 PM ',
                      style: TextStyle(
                        color: ColorPalleteLogin.PrimaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    // NOTE : Perbaiki ini
                    StrokeText(
                      text: 'Verified, sent.',
                      textStyle: true == true
                          ? TextStyle(
                              color: ColorPalleteLogin.OrangeLightColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            )
                          : TextStyle(
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
                      builder: (context) => StockTransferNotePopup(),
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

class StockTransferNotePopup extends StatefulWidget {
  const StockTransferNotePopup({
    super.key,
  });

  @override
  State<StockTransferNotePopup> createState() => _StockTransferNotePopupState();
}

class _StockTransferNotePopupState extends State<StockTransferNotePopup> {
  var _customTileExpanded = false;
  var isFormNotCreated = true;

  // controller
  final controllerPrintStock = ScreenshotController();
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.75,
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
                      'Stock Transfer Note Detail',
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
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),

                  TableBodyText(
                    judul: 'Stock Transfer Note ID',
                    data: '#101010101010',
                  ),
                  TableBodyText(
                    judul: 'Created at',
                    data: '07:31 PM, 01 July 2024',
                  ),

                  // table stock card
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                            // table bro
                            Screenshot(
                                controller: controllerPrintStock,
                                child: TableStockCardTransferNotes(
                                  listStockCard: [],
                                )),
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
                        await controllerPrintStock.capture().then((bytes) {
                          if (bytes != null) {
                            // panggil woe
                            saveImage(bytes, 'StockCardTransferNotes');
                            // saveAndShare(bytes, 'DeliveryOrder');
                          }
                        }).catchError((onError) {
                          debugPrint(onError);
                        });
                      },
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
                    ],
                  ),

                 
                  SizedBox(
                    height: 20,
                  ),

                  // if di klik createnya (perlu set function buat dia jadi true)

                  // delivery order
                  isFormNotCreated
                      ? TableBodyText(
                          judul: 'Delivery Order',
                        )
                      : TableBodyText(judul: 'Delivery Order', data: '#hehehe'),

                  // product loaded on truck
                  isFormNotCreated
                      ? Column(
                        children: [
                          Container(
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
                                        '+ Create Delivery Order',
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
                            ),

                            SizedBox(height: 20,),
                        ],
                      )
                      : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TableInputProductLoaded(),
                            SizedBox(height: 10,),
                            Container(
                              // height: 50,
                              width: MediaQuery.of(context).size.width *
                                  0.55 *
                                  0.25,
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
                                        Icons.repeat,
                                        color: ColorPalleteLogin.PrimaryColor,
                                      ),
                                      Text(
                                        'Reset',
                                        style: TextStyle(
                                          color: ColorPalleteLogin.PrimaryColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                onPressed: () {},
                              ),
                            ),
                          ],
                        ),

                        // action button (ini misal belum ke sent)
                        // Action Button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Container(
                      height: 50,
                      width: MediaQuery.of(context).size.width * 0.55 * 0.3,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorPalleteLogin.PrimaryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              side: BorderSide(
                                  color: ColorPalleteLogin.OrangeLightColor)),
                        ),
                        child: Wrap(
                          spacing: 12,
                          children: [
                            Text(
                              'Discard',
                              style: TextStyle(
                                color: ColorPalleteLogin.OrangeLightColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  Center(
                    child: Container(
                      height: 50,
                      width: MediaQuery.of(context).size.width * 0.55 * 0.3,
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
                              'Confirm',
                              style: TextStyle(
                                color: ColorPalleteLogin.PrimaryColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        onPressed: () {
                          // Note: GANTI
                          Navigator.pop(context);
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
}

class TableInputProductLoaded extends StatelessWidget {
  TableInputProductLoaded({
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
            3: FlexColumnWidth(2),
            4: FlexColumnWidth(3),
            5: FlexColumnWidth(4),
            6: FlexColumnWidth(2),
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
                      'Loaded',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
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
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Action',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),

            // making the content
            ...List.generate(
              10,
              (index) {
                TextEditingController controllerFill = TextEditingController();
                var tableRow = TableRow(
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
                          // >> note : BELUM DI LIMIT
                          child: TextField(
                            controller: controllerFill,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.end,
                            style: TextStyle(fontSize: 12),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(5.0),
                              isDense: true,
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: const BorderRadius.all(
                                  const Radius.circular(18.0),
                                ),
                                borderSide: new BorderSide(
                                  color: Colors.black,
                                  width: 1.0,
                                ),
                              ),
                            ),
                          )),
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
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () => {
                            // NOTE : HAPUS
                          },
                          child: Icon(Icons.delete),
                        ),
                      ),
                    ),
                  ],
                );
                return tableRow;
              },
            ),
          ],
        ),
      ),
    );
  }
}

// List<TableRow> ListRowTableInputProductLoaded {
//   int count;
//   // var listdata

//   ListRowTableInputProductLoaded({required count});

// }

class TableStockCardTransferNotes extends StatelessWidget {
  List<stock.Data> listStockCard = List.empty();
  var size = 14;
  TableStockCardTransferNotes({
    required this.listStockCard,
    super.key,
  });

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

class ProductDetailsChild extends StatelessWidget {
  String judul;
  String data;

  ProductDetailsChild({
    this.judul = '',
    this.data = '',
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}
