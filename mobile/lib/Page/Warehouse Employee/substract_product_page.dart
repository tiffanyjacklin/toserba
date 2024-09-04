import 'package:date_field/date_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_all/Model/AllStockProductWarehouse.dart';
// import 'package:flutter_app_all/Model/AllProduct.dart';
import 'package:flutter_app_all/Template.dart';

class SubstractProductPage extends StatefulWidget {
  SubstractProductPage({super.key});

  @override
  State<SubstractProductPage> createState() => _SubstractProductPageState();
}

class _SubstractProductPageState extends State<SubstractProductPage> {
  TextEditingController controllerName = TextEditingController();
  TextEditingController controllerBatch = TextEditingController();
  TextEditingController controllerDate = TextEditingController();

  var selectedDate;
  var isInput = false;
  List<Data> listData = [];

  @override
  Widget build(BuildContext context) {
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
              TableSubstractProduct(contentTable: listData),
        
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
              isInput ? Container(
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
                          child: TextField(
                            controller: controllerName,
                            keyboardType: TextInputType.name,
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
        
                      // INPUT BATCH
                      BodyPage(name: 'Product Batch'),
                      Padding(
                          padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                          // >> note : BELUM DI LIMIT
                          child: TextField(
                            controller: controllerBatch,
                            keyboardType: TextInputType.name,
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
        
                      // INPUT EXP DATE (CHECK LIST) NOTE : ganti checklist
                      DateTimeFormField(
                        decoration: const InputDecoration(
                          labelText: 'Enter Date',
                        ),
                        firstDate: DateTime.now().add(const Duration(days: 10)),
                        lastDate: DateTime.now().add(const Duration(days: 40)),
                        initialPickerDateTime:
                            DateTime.now().add(const Duration(days: 20)),
                        onChanged: (DateTime? value) {
                          selectedDate = value;
                        },
                      ),
                    
        
                      SizedBox(
                        height: 10,
                      ),
        
                      // SUBMIT BUTTON
                      Center(
                        child: Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width * 0.55 * 0.3,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorPalleteLogin.OrangeLightColor,
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
                                    'Add',
                                    style: TextStyle(
                                      color: ColorPalleteLogin.PrimaryColor,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onPressed: (){
                              setState(() {
                                isInput = false;
        
                                // NOTE : masukin ke table
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ) : Container(),
              SizedBox(
                height: 20,
              ),
        
              // // buat container jika klik
              // Container(
              //   child: Column(
              //     children: [],
              //   ),
              // ),
        
              // save button
              Container(
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
                    showDialog( barrierDismissible: false,
                            context: context,
                            builder: (context) => SubmitPopup());
                  },
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}


class TableSubstractProduct extends StatelessWidget {
  List<Data> contentTable = [];
  TableSubstractProduct({
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
                      child: Text('NO',
                          style: TableContentTextStyle.textStyle),
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
                    child: Text('BATCH',
                        style: TableContentTextStyle.textStyle),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('STOCK',
                        style: TableContentTextStyle.textStyle),
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
                    child: Text('NOTES',
                        style: TableContentTextStyle.textStyle),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('ACTION',
                        style: TableContentTextStyle.textStyle),
                  ),
                ), 
              ],
            ),

            // making the content
            ...List.generate(
              contentTable.length,
              (index) {
                TextEditingController controllerAmount = TextEditingController();
                TextEditingController controllerNotes = TextEditingController();
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
                          style: TableContentTextStyle.textStyleBody
                        ),
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
                        child: TextField(
                          controller: controllerAmount,
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
                          controller: controllerNotes,
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
                          this.contentTable.remove(index);
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
  const SubmitPopup({
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
