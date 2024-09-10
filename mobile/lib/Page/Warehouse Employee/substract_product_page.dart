import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_all/Tambahan/Provider/SeachedSubstractProvider.dart';
// import 'package:flutter_app_all/Model/AllProduct.dart';
import 'package:flutter_app_all/Template.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_app_all/Model/StockOpname.dart' as opname;
import 'package:provider/provider.dart';

// buat api baru
Future<List<opname.Data>> _fetchStockOpnameSubstract(
    int storeId, String productName, String batch) async {
  // NOTE : kalo mau satu kosong bisa di "-"
  final link =
      'http://leap.crossnet.co.id:8888/products/stock/opname/data/store_warehouse/$storeId/$productName/$batch/0/0';

  // call api
  final response = await http.get(Uri.parse(link));
  print('---> response ' + response.statusCode.toString());

  // cek status
  if (response.statusCode == 200) {
    Map<String, dynamic> temp = json.decode(response.body);

    if (temp['status'] == 200) {
      print(temp);
      return opname.FetchStockOpnameWarehouse.fromJson(temp).data!;
    } else {
      return [];
    }
  } else {
    print('fetch failed');
    return [];
  }
}

class SubstractProductPageWithProvider extends StatefulWidget {
  const SubstractProductPageWithProvider({super.key});

  @override
  State<SubstractProductPageWithProvider> createState() =>
      _SubstractProductPageWithProviderState();
}

class _SubstractProductPageWithProviderState
    extends State<SubstractProductPageWithProvider> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SubstractProductProvider(),
      child: SubstractProductPage(),
    );
  }
}

class SubstractProductPage extends StatefulWidget {
  SubstractProductPage({super.key});

  @override
  State<SubstractProductPage> createState() => _SubstractProductPageState();
}

class _SubstractProductPageState extends State<SubstractProductPage> {
  TextEditingController controllerName = TextEditingController();
  // TextEditingController controllerBatch = TextEditingController();
  // TextEditingController controllerDate = TextEditingController();

  var selectedDate;
  var isInput = false;
  var initialVal = '-';


  @override
  Widget build(BuildContext context) {
    final providerSubstract = Provider.of<SubstractProductProvider>(context);
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: SingleChildScrollView(
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
            child: Column(children: [
              // judul
              TitlePage(name: 'Substract Product'),

              // table (tambah variable seperti cart)
              TableSubstractProduct(),

              // divider + add button
              Padding(
                padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.55,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Divider(color: Colors.black),
                      InkWell(
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.0),
                              color: ColorPalleteLogin.OrangeLightColor,
                              shape: BoxShape.rectangle,
                              border: Border.all(
                                width: 1,
                              )),
                          child: Icon(Icons.add, color: Colors.black),
                        ),
                        onTap: () {
                          setState(() {
                            isInput = true;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // With SetState ( NOTE: )
              // misal diklik button maka muncul input untuk masukin product yg ada
              // input container
              isInput
                  ? Container(
                      width: MediaQuery.of(context).size.width * 0.55 * 0.9,
                      // height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(
                          strokeAlign: 1,
                          color: Colors.grey,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 20.0, right: 20.0, top: 20.0, bottom: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // INPUT NAME
                            BodyPage(name: 'Product Name'),
                            Padding(
                              padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                              // >> note : BELUM DI LIMIT
                              child: SizedBox(
                                // child: TextField(
                                //     controller: controllerName,
                                //     keyboardType: TextInputType.name,
                                //     textAlign: TextAlign.start,
                                //     style: TextStyle(fontSize: 16),
                                //     decoration: InputDecoration(
                                //       contentPadding: EdgeInsets.all(5.0),
                                //       isDense: true,
                                //       filled: true,
                                //       fillColor: Colors.white,
                                //       border: OutlineInputBorder(
                                //         borderRadius: const BorderRadius.all(
                                //           const Radius.circular(10.0),
                                //         ),
                                //         borderSide: new BorderSide(
                                //           color: Colors.black,
                                //           width: 1.0,
                                //         ),
                                //       ),
                                //     ),
                                //     onSubmitted: (value) {
                                //       // lakukan sesuatu
                                //       providerSubstract.searchItemByName(controllerName.text);
                                //     },
                                //   ),

                                child: SearchAnchor(builder:
                                    (BuildContext context,
                                        SearchController controller) {
                                  return SearchBar(
                                    controller: controllerName,
                                    keyboardType: TextInputType.name,
                                    hintText: 'Search Name',
                                    backgroundColor:
                                        WidgetStateProperty.all<Color>(
                                            Colors.white),
                                    onSubmitted: (value) {
                                      // lakukan sesuatu
                                      providerSubstract.searchItemByName(
                                          controllerName.text);
                                    },
                                  );
                                }, suggestionsBuilder: (BuildContext context,
                                    SearchController controller) {
                                  return List<ListTile>.generate(5,
                                      (int index) {
                                    final String item = 'item $index';
                                    return ListTile(
                                      title: Text(item),
                                      onTap: () {
                                        setState(() {
                                          controller.closeView(item);
                                        });
                                      },
                                    );
                                  });
                                }),
                              ),
                            ),

                            // INPUT BATCH
                            BodyPage(name: 'Product Batch and expire date'),
                            Padding(
                              padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                              // >> note : BELUM DI LIMIT
                              child: Container(
                                width: MediaQuery.of(context).size.width *
                                    0.55 *
                                    0.8,
                                child: DropdownButton(
                                  // Initial Value
                                  value: providerSubstract
                                              .suggestionitems.length ==
                                          0
                                      ? '-'
                                      : providerSubstract.suggestionitems[providerSubstract.itemSuggestionSelectedIndex],

                                  // Down Arrow Icon
                                  icon: const Icon(Icons.keyboard_arrow_down),

                                  // Array list of items
                                  items: providerSubstract
                                      .makeListItemSuggestion(),
                                  // After selecting the desired option,it will
                                  // change button value to selected value
                                  onChanged: (val) {
                                    providerSubstract.itemSuggestionSelectedIndex =
                                        providerSubstract.suggestionitems
                                            .indexOf(val);
                                  },
                                ),
                              ),
                            ),

                            SizedBox(
                              height: 10,
                            ),

                            // SUBMIT BUTTON
                            Center(
                              child: Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width *
                                    0.55 *
                                    0.3,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        ColorPalleteLogin.OrangeLightColor,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        side: BorderSide(color: Colors.black)),
                                  ),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Wrap(
                                      spacing: 6,
                                      children: [
                                        Text(
                                          'Add',
                                          style: TextStyle(
                                            color:
                                                ColorPalleteLogin.PrimaryColor,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      isInput = false;

                                      // NOTE : masukin ke table
                                      providerSubstract.addToCart2();
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Container(),
              SizedBox(
                height: 20,
              ),

              // save button
              providerSubstract.cartItems.length != 0? Container(
                height: 55,
                width: MediaQuery.of(context).size.width * 0.55 * 0.4,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorPalleteLogin.PrimaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: BorderSide(color: Colors.black)),
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Wrap(
                      spacing: 6,
                      children: [
                        Text(
                          'Submit',
                          style: TextStyle(
                            color: ColorPalleteLogin.OrangeLightColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  onPressed: () {
                    showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (context) => SubmitPopup(provider: providerSubstract));
                  },
                ),
              ) : Container(),
            ]),
          ),
        ),
      ),
    );
  }
}

class TableSubstractProduct extends StatelessWidget {
  TableSubstractProduct({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final List<opname.Data> contentTable = context.select((SubstractProductProvider i) => i.cartItems);
    final List<TextEditingController> controllerInputList = context.select((SubstractProductProvider i) => i.listInputQuantity);
    final List<TextEditingController> controllerNotes = context.select((SubstractProductProvider i) => i.listNotes);

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
            5: FlexColumnWidth(2),
            6: FlexColumnWidth(4),
            7: FlexColumnWidth(2),
            // 8: FlexColumnWidth(),
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
                      child: Text('NO', style: TableContentTextStyle.textStyle),
                    ),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('PRODUCT NAME',
                        style: TableContentTextStyle.textStyle),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child:
                        Text('BATCH', style: TableContentTextStyle.textStyle),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child:
                        Text('STOCK', style: TableContentTextStyle.textStyle),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('SUBSTRACT AMOUNT',
                        style: TableContentTextStyle.textStyle),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('UNIT TYPE',
                        style: TableContentTextStyle.textStyle),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child:
                        Text('NOTES', style: TableContentTextStyle.textStyle),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child:
                        Text('ACTION', style: TableContentTextStyle.textStyle),
                  ),
                ),
              ],
            ),

            // making the content
            ...List.generate(
              contentTable.length,
              (index) {
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
                          child: Text('${index + 1}',
                              style: TableContentTextStyle.textStyleBody),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('${contentTable[index].productName}',
                            style: TableContentTextStyle.textStyleBody),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('${contentTable[index].batch}',
                            style: TableContentTextStyle.textStyleBody),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('${contentTable[index].expectedStock}',
                            style: TableContentTextStyle.textStyleBody),
                      ),
                    ),

                    TableCell(
                      child: Padding(
                          padding: EdgeInsets.all(8.0),
                          // >> note : BELUM DI LIMIT
                          child: SizedBox(
                            child: TextField(
                              controller: controllerInputList[index],
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.end,
                              style: TableContentTextStyle.textStyleBody,
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
                            ),
                          )),
                    ),

                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('${contentTable[index].unitType}',
                            style: TableContentTextStyle.textStyleBody),
                      ),
                    ),

                    // input notes
                    TableCell(
                      child: Padding(
                          padding: EdgeInsets.all(8.0),
                          // >> note : BELUM DI LIMIT
                          child: TextField(
                            controller: controllerNotes[index],
                            keyboardType: TextInputType.text,
                            textAlign: TextAlign.start,
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

                    // action button
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 8.0, right: 8.0, top: 2, bottom: 2),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.all(0),
                            backgroundColor: ColorPalleteLogin.OrangeDarkColor,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(color: Colors.black),
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                          ),
                          child: Icon(
                            Icons.delete_outline,
                            color: ColorPalleteLogin.PrimaryColor,
                          ),
                          onPressed: () {
                            // delete this row from table (hapus data)
                            context
                                .read<SubstractProductProvider>()
                                .deleteItem(index);
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

class SubmitPopup extends StatelessWidget {
  var provider;
  
  SubmitPopup({
    required this.provider,
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
                'Submit',
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
                      'Are you sure you want to submit the changes you\'ve made?',
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
                          provider.submitSubstract(3, 3).then((onValue){
                              Navigator.pop(context);
                          });
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
