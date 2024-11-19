import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_all/Tambahan/Provider/AcceptFormCart.dart';
import 'package:flutter_app_all/Tambahan/Provider/InventoryTakingProvider.dart';
import 'package:flutter_app_all/Template.dart';
import 'package:flutter_app_all/Model/DeliveryTransferDetail.dart';
import 'package:provider/provider.dart';

class AcceptingPage extends StatelessWidget {
  final List<Data> dataDelivery;
  final String userId;
  const AcceptingPage(
      {super.key, required this.dataDelivery, required this.userId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AcceptFormCart(dataDelivery, userId),
      child: AcceptingPage1(dataDelivery: dataDelivery),
    );
  }
}

class AcceptingPage1 extends StatefulWidget {
  final List<Data> dataDelivery;
  const AcceptingPage1({super.key, required this.dataDelivery});

  @override
  State<AcceptingPage1> createState() => _AcceptingPage1State();
}

class _AcceptingPage1State extends State<AcceptingPage1> {
  @override
  Widget build(BuildContext context) {
    var providerAcceptForm = Provider.of<AcceptFormCart>(context);
    return Scaffold(
      body: SafeArea(

        child: Container(
            child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 10,
              ),
              // back
              GestureDetector(
                onTap: () {
                  Navigator.pop(context, '');
                },
                child: Row(
                  children: [
                    Icon(Icons.arrow_back),
                    Text(
                      'Back',
                      style: TextStyle(fontSize: fontSizeBody - 2),
                    ),
                  ],
                ),
              ),

              // judul
              TitlePage(name: 'Accept Order'),

              SizedBox(
                height: 20,
              ),

              // table
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: TableAcceptForm1(
                  contentTable: widget.dataDelivery,
                ),
              ),
              SizedBox(height: 20,),

              // message?
              Text(
                providerAcceptForm.message,
                style: TextStyle(color: Colors.red, fontSize: fontSizeBody, fontWeight: FontWeight.bold,),
              ),

              SizedBox(height: 20,),

              // button accept (keluarin popup you sure?)
              Center(
                child: Container(
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
                              fontSize: fontSizeBody,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    onPressed: () {
                      if(!providerAcceptForm.isThereEmptyField()){
                      showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (context) =>
                                  SubmitPopup(provider: providerAcceptForm))
                          .then((onValue) => {
                                if(providerAcceptForm.message == ''){
                                  Navigator.pop(context, 'Berhasil'),
                                }
                              });
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        )),
      ),
    );
  }
}

class SubmitPopup extends StatelessWidget {
  final AcceptFormCart provider;

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
                'Alert',
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
                      'Are you sure want to submit the Accept Form?',
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
                          provider.submit().then((onValue) {
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

class TableAcceptForm1 extends StatelessWidget {
  final List<Data> contentTable;
  TableAcceptForm1({
    super.key,
    required this.contentTable,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AcceptFormCart>(context);
    return DataTable(
      border: TableBorder(
        horizontalInside: BorderSide(color: Colors.black, width: 0.7),
      ),
      columns: [
        DataColumn(
          label: Text('NO.', style: TableContentTextStyle.textStyle),
        ),
        DataColumn(
          label: Text('PRODUCT NAME', style: TableContentTextStyle.textStyle),
        ),
        DataColumn(
          label: Text('BATCH', style: TableContentTextStyle.textStyle),
        ),
        DataColumn(
          label: Text('EXPIRY DATE', style: TableContentTextStyle.textStyle),
        ),
        DataColumn(
          label: Text('EXPECTED', style: TableContentTextStyle.textStyle),
        ),
        DataColumn(
          label: Text('ACTUAL', style: TableContentTextStyle.textStyle),
        ),
        DataColumn(
          label: Text('UNIT TYPE', style: TableContentTextStyle.textStyle),
        ),
        DataColumn(
          label: Text('FILL', style: TableContentTextStyle.textStyle),
        ),
        DataColumn(
          label: Text('SECTION', style: TableContentTextStyle.textStyle),
        ),
        DataColumn(
          label: Text('NOTES', style: TableContentTextStyle.textStyle),
        ),
      ],
      rows: List.generate(
        !contentTable.isEmpty ? contentTable.length : 0,
        (i) => DataRow(
            color: (i + 1) % 2 == 1
                ? WidgetStateColor.resolveWith(
                    (states) => ColorPalleteLogin.TableColor)
                : null,
            cells: [
              DataCell(Text(
                (i + 1).toString(),
                style: TableContentTextStyle.textStyleBody,
              )),
              DataCell(
                Text(contentTable[i].productName!,
                    style: TableContentTextStyle.textStyleBody),
              ),
              DataCell(
                Text(contentTable[i].batch!,
                    style: TableContentTextStyle.textStyleBody),
              ),
              DataCell(
                Text(getOnlyDate(contentTable[i].expiredDate!),
                    style: TableContentTextStyle.textStyleBody),
              ),
              DataCell(
                Text(contentTable[i].quantity!.toString(),
                    style: TableContentTextStyle.textStyleBody),
              ),
              DataCell(
                Padding(
                    padding: EdgeInsets.all(8.0),
                    // >> note : BELUM DI LIMIT
                    child: TextField(
                      onChanged: (value) {
                        // check if can
                        provider.listControllerInput[i].text = int.tryParse(
                                    provider.listControllerInput[i].text) ==
                                null
                            ? '0'
                            : int.parse(provider.listControllerInput[i].text)
                                .toString();

                        // provider.listControllerInput[i].text =
                        //         int.tryParse(provider
                        //                     .listControllerInput[i]
                        //                     .text) ==
                        //                 null
                        //             ? '0'
                        //             : int.parse(provider.listControllerInput[i].text) > contentTable[i].quantity!
                        //                     ? contentTable[i].quantity!.toString()
                        //                     : int.parse(provider
                        //                     .listControllerInput[i].text)
                        //                 .toString();
                      },
                      controller: provider.listControllerInput[i],
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
                    )),
              ),
              DataCell(
                Text(contentTable[i].unitType!.toString(),
                    style: TableContentTextStyle.textStyleBody),
              ),
              DataCell(
                Padding(
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
                      // fill
                      provider.listControllerInput[i].text =
                          provider.items[i].quantity!.toString();
                    },
                  ),
                ),
              ),
              DataCell(
                Padding(
                    padding: EdgeInsets.all(8.0),
                    // >> note : BELUM DI LIMIT
                    child: TextField(
                      onChanged: (value) {
                        // // check if can
                        // controllerQty[index].text = int.tryParse(controllerQty[index].text) == null ? '0' : int.parse(controllerQty[index].text).toString();
                        // if (value.isNotEmpty) {
                        //   providerInventory.addToCart(index,
                        //       quantity:
                        //           int.parse(controllerQty[index].text)
                        //           );

                        // } else {
                        //   providerInventory
                        //       .removeFromCart(index);
                        // }
                      },
                      controller: provider.listControllerSection[i],
                      keyboardType: TextInputType.name,
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
                    )),
              ),
              DataCell(
                Padding(
                    padding: EdgeInsets.all(8.0),
                    // >> note : BELUM DI LIMIT
                    child: TextField(
                      onChanged: (value) {
                        // // check if can
                        // controllerQty[index].text = int.tryParse(controllerQty[index].text) == null ? '0' : int.parse(controllerQty[index].text).toString();
                        // if (value.isNotEmpty) {
                        //   providerInventory.addToCart(index,
                        //       quantity:
                        //           int.parse(controllerQty[index].text)
                        //           );

                        // } else {
                        //   providerInventory
                        //       .removeFromCart(index);
                        // }
                      },
                      controller: provider.listControllerNotes[i],
                      keyboardType: TextInputType.name,
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
                    )),
              ),
            ]),
      ),
    );
  }
}
