import 'dart:convert';
// import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_all/Model/StockOpname.dart';
import 'package:flutter_app_all/Tambahan/Provider/InventoryTakingProvider.dart';
import 'package:flutter_app_all/Template.dart';
import 'package:number_paginator/number_paginator.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

Future _fetchStockOpname(String name) async {
  var storeId = 2;
  // link api http://leap.crossnet.co.id:8888/user/1/1
  // link localhost -> http://localhost:8888/user/

  var batch = '';
  var unitType = '';


  final link =
      'http://leap.crossnet.co.id:8888/products/stock/opname/data/store_warehouse/$storeId/$name/$batch/$unitType/0/0';

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
      return FetchStockOpnameWarehouse.fromJson(temp).data!;
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



class InventoryTakingPageWithProvider extends StatefulWidget {
  const InventoryTakingPageWithProvider ({super.key});

  @override
  State<InventoryTakingPageWithProvider> createState() => _InventoryTakingPageWithProviderState();
}

class _InventoryTakingPageWithProviderState extends State<InventoryTakingPageWithProvider> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => InventoryTakingProvider(),
      child: InventoryTakingPage(),
    );
  }
}

class InventoryTakingPage extends StatefulWidget {
  InventoryTakingPage({super.key});

  @override
  State<InventoryTakingPage> createState() => _InventoryTakingPageState();
}

class _InventoryTakingPageState extends State<InventoryTakingPage> {
  final NumberPaginatorController _controller = NumberPaginatorController();

  var _currentPage = 1;
  List<Data> contentTableInventory =
      FetchStockOpnameWarehouse.fromJson(jsonStockOpname).data!;

  @override
  Widget build(BuildContext context) {
    final providerInventory = Provider.of<InventoryTakingProvider>(context);

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
              left: 20.0, right: 20.0, top: 16.0, bottom: 8.0),
          child: Column(
            children: [
              TitlePage(name: 'Inventory Taking'),
              SizedBox(
                height: 10,
              ),
              Container(
                // width: MediaQuery.of(context).size.width * 0.70,
                child: CupertinoSearchTextField(),
              ),
              SizedBox(
                height: 10,
              ),

              NumberPaginator(
                // by default, the paginator shows numbers as center content
                numberPages: 100,
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
                      ? () => _controller.prev()
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

              TableInventoryTaking(
                contentTable: contentTableInventory,
              ),

              SizedBox(
                height: 20,
              ),
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
                          ),
                        ),
                        child: Wrap(
                          spacing: 12,
                          children: [
                            Text(
                              'Discard',
                              style: TextStyle(
                                color: ColorPalleteLogin.OrangeColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        onPressed: () {
                          // keluarin popup discard
                          showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (context) => DiscardPopup(),
                          );
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
                          backgroundColor: ColorPalleteLogin.OrangeDarkColor,
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
                          // masuk ke popup lanjutan untuk buat stok card
                          showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (context) => InventoryTakingFormPopUp(),
                          );
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
    );
  }
}

class DetailProductInventoryTakingPopup extends StatelessWidget {
  DetailProductInventoryTakingPopup({
    super.key,
  });

  // controller
  var locationController = TextEditingController();
  var informationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.55,
        // height: MediaQuery.of(context).size.height * 0.3,
        decoration: BoxDecoration(
          color: ColorPalleteLogin.PrimaryColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
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
                'Product Detail',
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

              // input
              // location
              Text(
                'Location',
                style: TextStyle(
                    fontSize: 16,
                    color: ColorPalleteLogin.OrangeLightColor,
                    fontWeight: FontWeight.bold),
              ),

              Padding(
                  padding: EdgeInsets.all(8.0),
                  // >> note : BELUM DI LIMIT CHARACTER
                  child: TextField(
                    keyboardType: TextInputType.multiline,
                    controller: locationController,
                    minLines: 3,
                    maxLines: 3,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        fontSize: 16,
                        color: ColorPalleteLogin.PrimaryColor,
                        fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(10.0),
                      isDense: true,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(15.0),
                        ),
                        borderSide: new BorderSide(
                          color: Colors.black,
                          width: 1.0,
                        ),
                      ),
                    ),
                  )),

              SizedBox(
                height: 15,
              ),

              // Information
              Text(
                'Information',
                style: TextStyle(
                    fontSize: 16,
                    color: ColorPalleteLogin.OrangeLightColor,
                    fontWeight: FontWeight.bold),
              ),

              Padding(
                  padding: EdgeInsets.all(8.0),
                  // >> note : BELUM DI LIMIT CHARACTER
                  child: TextField(
                    keyboardType: TextInputType.multiline,
                    controller: informationController,
                    maxLines: 3,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 16,
                        color: ColorPalleteLogin.PrimaryColor,
                        fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(10.0),
                      isDense: true,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(15.0),
                        ),
                        borderSide: new BorderSide(
                          color: Colors.black,
                          width: 1.0,
                        ),
                      ),
                    ),
                  )),

              SizedBox(
                height: 30,
              ),

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
                              'Back',
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
                    width: 20,
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
    );
  }
}

class InventoryTakingFormPopUp extends StatefulWidget {
  const InventoryTakingFormPopUp({
    super.key,
  });

  @override
  State<InventoryTakingFormPopUp> createState() =>
      _InventoryTakingFormPopUpState();
}

class _InventoryTakingFormPopUpState extends State<InventoryTakingFormPopUp> {
  var _customTileExpanded = false;
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.7,
        decoration: BoxDecoration(
          color: ColorPalleteLogin.PrimaryColor,
          borderRadius: BorderRadius.circular(20),
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
                mainAxisSize: MainAxisSize.min,
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
                    'Inventory Taking',
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

                  // detail inventory taking
                  InventoryTakingDetailsChild(
                    judul: 'Responsible Person',
                    data: 'Budi Setiawan',
                  ),
                  InventoryTakingDetailsChild(
                    judul: 'Date',
                    data: '07:54 PM, 01 July 2024',
                  ),

                  // changes untuk yg udah di input actual stock (buat tabel)
                  Theme(
                    data: Theme.of(context)
                        .copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: EdgeInsets.only(left: 8.0),
                      trailing: Icon(
                        _customTileExpanded
                            ? Icons.arrow_drop_down_circle
                            : Icons.arrow_drop_down,
                        color: ColorPalleteLogin.OrangeColor,
                      ),
                      title: Text(
                        'Changes',
                        style: TextStyle(
                            fontSize: 16,
                            color: ColorPalleteLogin.OrangeLightColor,
                            fontWeight: FontWeight.bold),
                      ),
                      children: [
                        TableInventoryTakingPopUp(),
                        SizedBox(
                          height: 10,
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
                    height: 30,
                  ),

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
                                      color:
                                          ColorPalleteLogin.OrangeLightColor)),
                            ),
                            child: Wrap(
                              spacing: 12,
                              children: [
                                Text(
                                  'Back',
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
                        width: 20,
                      ),
                      Center(
                        child: Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width * 0.55 * 0.3,
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
                                  'Submit',
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

class DiscardPopup extends StatelessWidget {
  const DiscardPopup({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        decoration: BoxDecoration(
          color: ColorPalleteLogin.PrimaryColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
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
                'Discard',
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
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(''),
                  ),
                  Expanded(
                    flex: 4,
                    child: Text(
                      'Are you sure you want to discard the changes you\'ve made?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: ColorPalleteLogin.OrangeLightColor,
                          shadows: [
                            Shadow(
                                blurRadius: 2.0,
                                color: Colors.black,
                                offset: Offset(1, 1)),
                          ]),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(''),
                  ),
                ],
              ),
              SizedBox(
                height: 30,
              ),

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
                              'Back',
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
                    width: 20,
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
                              'Discard',
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
    );
  }
}

class TableInventoryTaking extends StatelessWidget {
  List<Data> contentTable = [];
  TableInventoryTaking({
    super.key,
    required this.contentTable,
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
            4: FlexColumnWidth(3),
            5: FlexColumnWidth(3),
            6: FlexColumnWidth(2),
            7: FlexColumnWidth(2),
            8: FlexColumnWidth(2),
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
                    child: Center(
                      child: Text('NO',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('PRODUCT NAME',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('BATCH',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('EXPIRY DATE',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('EXPECTED STOCK',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('ACTUAL STOCK',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('UNIT TYPE',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('FILL',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(6.0),
                    child: Text('DETAIL',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),

            // making the content
            ...List.generate(
              5,
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
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('${contentTable[index].productName}',
                            style: TextStyle(
                              fontSize: 12,
                            )),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('${contentTable[index].batch}',
                            style: TextStyle(
                              fontSize: 12,
                            )),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('${contentTable[index].expiredDate}',
                            style: TextStyle(
                              fontSize: 12,
                            )),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '${contentTable[index].expectedStock}',
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ),
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
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('${contentTable[index].unitType}',
                            style: TextStyle(
                              fontSize: 12,
                            )),
                      ),
                    ),

                    // action button
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 8.0, right: 8.0, top: 2, bottom: 2),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.all(0),
                            backgroundColor: ColorPalleteLogin.OrangeLightColor,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(color: Colors.black),
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                          ),
                          child: Icon(
                            Icons.fast_forward_sharp,
                            color: ColorPalleteLogin.PrimaryColor,
                          ),
                          onPressed: () {
                            // ubah input value di expected stock
                            controllerFill.text =
                                contentTable[index].expectedStock.toString();
                          },
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 8.0, right: 8.0, top: 2, bottom: 2),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.all(0),
                            backgroundColor: ColorPalleteLogin.PrimaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                          ),
                          child: Icon(
                            Icons.remove_red_eye_outlined,
                            color: ColorPalleteLogin.OrangeColor,
                          ),
                          onPressed: () {
                            // keluarin popup detail
                            showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (context) =>
                                  DetailProductInventoryTakingPopup(),
                            );
                          },
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

class TableInventoryTakingPopUp extends StatelessWidget {
  const TableInventoryTakingPopUp({
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
            1: FlexColumnWidth(7),
            2: FlexColumnWidth(3),
            3: FlexColumnWidth(3),
            4: FlexColumnWidth(3),
            5: FlexColumnWidth(3),
            6: FlexColumnWidth(2),
            7: FlexColumnWidth(4),
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
                    child: Center(
                      child: Text('NO',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'PRODUCT NAME',
                      style: TableContentTextStyle.textStyle,
                    ),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('BATCH',
                        style: TableContentTextStyle.textStyle,),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('EXPIRY DATE',
                        style: TableContentTextStyle.textStyle,),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('EXPECTED STOCK',
                        style: TableContentTextStyle.textStyle,),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('ACTUAL STOCK',
                        style: TableContentTextStyle.textStyle,),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('UNIT TYPE',
                        style: TableContentTextStyle.textStyle,),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('INFORMATION',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),

            // making the content
            ...List.generate(
              5,
              (index) => TableRow(
                decoration: (index + 1) % 2 == 0
                    ? BoxDecoration(
                        color: ColorPalleteLogin.TableColor,
                      )
                    : null,
                children: [
                  TableCell(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Nama Produk',
                          style: TextStyle(
                            fontSize: 12,
                          )),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('B010101',
                          style: TextStyle(
                            fontSize: 12,
                          )),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('10/10/2024',
                          style: TextStyle(
                            fontSize: 12,
                          )),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '10000',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '10000',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Unit',
                          style: TextStyle(
                            fontSize: 12,
                          )),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Lokasi Kuuuuu',
                          style: TextStyle(
                            fontSize: 12,
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

class InventoryTakingDetailsChild extends StatelessWidget {
  String judul;
  String data;

  InventoryTakingDetailsChild({
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

// // Menambah stock opname
// e.POST("/products/stock/opname/add", controller.InsertStockOpname)
// [
//     {
//         "product_detail_id": 4,
//         "batch": "1",
//         "expired_date": "2025-08-25",
//         "actual_stock": 15,
//         "unit_type": "gram",
//         "store_warehouse_id": 2
//     }
// ]

class InputStockOpname {
  Data data;
  late int actualStock;
  late String additional_information;

  InputStockOpname({
    required this.data,
  });
}

var jsonStockOpname = {
  "status": 200,
  "message": "Berhasil",
  "data": [
    {
      "stock_opname_id": 0,
      "product_detail_id": 14,
      "product_name": "Tomato",
      "batch": "1",
      "expired_date": "2024-08-23",
      "expected_stock": 1000,
      "actual_stock": 0,
      "unit_type": "gram",
      "timestamp": "",
      "store_warehouse_id": 2
    },
    {
      "stock_opname_id": 0,
      "product_detail_id": 3,
      "product_name": "Spinach",
      "batch": "1",
      "expired_date": "2025-08-16",
      "expected_stock": 0,
      "actual_stock": 0,
      "unit_type": "gram",
      "timestamp": "",
      "store_warehouse_id": 2
    },
    {
      "stock_opname_id": 0,
      "product_detail_id": 4,
      "product_name": "Pepper",
      "batch": "1",
      "expired_date": "2025-08-20",
      "expected_stock": 20,
      "actual_stock": 0,
      "unit_type": "gram",
      "timestamp": "",
      "store_warehouse_id": 2
    },
    {
      "stock_opname_id": 0,
      "product_detail_id": 4,
      "product_name": "Pepper",
      "batch": "1",
      "expired_date": "2025-08-25",
      "expected_stock": 15,
      "actual_stock": 0,
      "unit_type": "gram",
      "timestamp": "",
      "store_warehouse_id": 2
    },
    {
      "stock_opname_id": 0,
      "product_detail_id": 3,
      "product_name": "Spinach",
      "batch": "2",
      "expired_date": "2025-08-20",
      "expected_stock": 25,
      "actual_stock": 0,
      "unit_type": "gram",
      "timestamp": "",
      "store_warehouse_id": 2
    },
    {
      "stock_opname_id": 0,
      "product_detail_id": 4,
      "product_name": "Pepper",
      "batch": "2",
      "expired_date": "2025-08-25",
      "expected_stock": 10,
      "actual_stock": 0,
      "unit_type": "gram",
      "timestamp": "",
      "store_warehouse_id": 2
    },
    {
      "stock_opname_id": 0,
      "product_detail_id": 4,
      "product_name": "Pepper",
      "batch": "3",
      "expired_date": "2025-08-25",
      "expected_stock": 5,
      "actual_stock": 0,
      "unit_type": "gram",
      "timestamp": "",
      "store_warehouse_id": 2
    },
    {
      "stock_opname_id": 0,
      "product_detail_id": 4,
      "product_name": "Pepper",
      "batch": "4",
      "expired_date": "2025-08-25",
      "expected_stock": 5,
      "actual_stock": 0,
      "unit_type": "gram",
      "timestamp": "",
      "store_warehouse_id": 2
    },
    {
      "stock_opname_id": 0,
      "product_detail_id": 4,
      "product_name": "Pepper",
      "batch": "5",
      "expired_date": "2025-08-25",
      "expected_stock": 0,
      "actual_stock": 0,
      "unit_type": "gram",
      "timestamp": "",
      "store_warehouse_id": 2
    }
  ]
};
