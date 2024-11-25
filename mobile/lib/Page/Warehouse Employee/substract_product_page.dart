import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Toserba_App/Tambahan/Provider/Auth.dart';
import 'package:Toserba_App/Tambahan/Provider/SeachedSubstractProvider.dart';
import 'package:Toserba_App/Template.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:Toserba_App/Model/StockOpname.dart' as opname;
import 'package:provider/provider.dart';
import 'package:Toserba_App/Model/AllProduct.dart' as product;

Future<List<product.Data>> fetchProduct(
    int userId, int roleId, int swId, String search) async {
  // ${$userId}/${$roleId}///${searchQuery}/${category}/${unit_type}/${sort_type}/${sorting}/${limit}/${offset}

  try {
    final link =
        'http://leap.crossnet.co.id:8888/products/store_warehouse/$userId/$roleId/$swId///$search/////10/0';

    print(link);

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
        return product.FetchAllProducts.fromJson(temp).data!;
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
  } on SocketException catch (e) {
    print("Caught socketexception: $e");
  } on TimeoutException catch (e) {
    print('Caught: $e');
  } catch (e) {}
  //print('Done');
  return [];
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
    final providerAuth = Provider.of<AuthState>(context);
    return ChangeNotifierProvider(
      create: (context) => SubstractProductProvider(providerAuth.userData),
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
    final providerAuth = Provider.of<AuthState>(context);
    final providerSubstract = Provider.of<SubstractProductProvider>(context);
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28.0),
            border: Border.all(color: Colors.grey),
          ),
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.only(
                left: 4.0, right: 4.0, top: 16.0, bottom: 8.0),
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
                            isInput = !isInput;
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
                                child: TypeAheadField<product.Data>(
                                  debounceDuration: Duration(milliseconds: 200),
                                  controller: controllerName,
                                  hideWithKeyboard: false,
                                  itemBuilder: (context, value) {
                                    return ListTile(
                                      title: Text(
                                          value.productDetails!.productName!),
                                    );
                                  },
                                  onSelected: (value) {
                                    controllerName.text =
                                        value.productDetails!.productName!;
                                    providerSubstract.searchItemByName(
                                        value.productDetails!.productName!);
                                  },
                                  suggestionsCallback: (search) async {
                                    if (search.isEmpty) {
                                      return [];
                                    } else {
                                      final suggestion = await fetchProduct(
                                          providerAuth.userData.userId!,
                                          providerAuth.userData.roleId!,
                                          providerAuth
                                              .userData.storeWarehouseId!,
                                          search.toLowerCase());
                                      providerSubstract.listAutoComplete =
                                          suggestion;
                                      return suggestion;
                                    }
                                  },
                                ),
                              ),
                            ),

                            // INPUT BATCH
                            BodyPage(name: 'Product Batch and expire date'),
                            Padding(
                              padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
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
                                      : providerSubstract.suggestionitems[
                                          providerSubstract
                                              .itemSuggestionSelectedIndex],

                                  // Down Arrow Icon
                                  icon: const Icon(Icons.keyboard_arrow_down),

                                  // Array list of items
                                  items: providerSubstract
                                      .makeListItemSuggestion(),
                                  // After selecting the desired option,it will
                                  // change button value to selected value
                                  onChanged: (val) {
                                    providerSubstract
                                            .itemSuggestionSelectedIndex =
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
              providerSubstract.cartItems.length != 0
                  ? Container(
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
                              builder: (context) =>
                                  SubmitPopup(provider: providerSubstract));
                        },
                      ),
                    )
                  : Container(),
            ]),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controllerName.dispose();
  }
}

class TableSubstractProduct extends StatelessWidget {
  TableSubstractProduct({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final List<opname.Data> contentTable =
        context.select((SubstractProductProvider i) => i.cartItems);
    final List<TextEditingController> controllerInputList =
        context.select((SubstractProductProvider i) => i.listInputQuantity);
    final List<TextEditingController> controllerNotes =
        context.select((SubstractProductProvider i) => i.listNotes);

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
            7: FlexColumnWidth(3),
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
                        softWrap: true, style: TableContentTextStyle.textStyle),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('BATCH',
                        softWrap: true, style: TableContentTextStyle.textStyle),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('STOCK',
                        softWrap: true, style: TableContentTextStyle.textStyle),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('QTY',
                        softWrap: true, style: TableContentTextStyle.textStyle),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('UNIT TYPE',
                        softWrap: true, style: TableContentTextStyle.textStyle),
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
                    child: Text('ACTION',
                        softWrap: true, style: TableContentTextStyle.textStyle),
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
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  if (int.parse(value) >
                                      contentTable[index].expectedStock!) {
                                    controllerInputList[index].text =
                                        contentTable[index]
                                            .expectedStock!
                                            .toString();
                                  }
                                }
                                else{
                                  controllerInputList[index].text = '1';
                                }
                              },
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
                            keyboardType: TextInputType.multiline,
                            textAlign: TextAlign.start,
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
  final SubstractProductProvider provider;

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
                      'Are you sure want to submit the changes you\'ve made?',
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
                          provider.submitSubstract().then((onValue) {
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
