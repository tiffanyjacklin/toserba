import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_all/ColorPallete.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:stroke_text/stroke_text.dart';

class AcceptOrderPage extends StatelessWidget {
  const AcceptOrderPage({super.key});

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
              Text('Accept Order',
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
              DeliveryOrderChild(),
              DeliveryOrderChild(),
              DeliveryOrderChild(),
            ],
          ),
        ),
      ),
    );
  }
}

class DeliveryOrderChild extends StatelessWidget {
  const DeliveryOrderChild({
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
                      'Delivery Order #112345667 ',
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
                    StrokeText(
                      text: 'Unchecked !!',
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
                      builder: (context) => DeliveryOrderDetailPopUp(),
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

class DeliveryOrderDetailPopUp extends StatelessWidget {
  DeliveryOrderDetailPopUp({
    super.key,
  });

  // controller
  final controllerPrintOrder = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        decoration: BoxDecoration(
          color: ColorPalleteLogin.PrimaryColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: ColorPalleteLogin.OrangeColor,
              offset: Offset(0, 6),
            ),
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
                    width: MediaQuery.of(context).size.width * 0.55 * 0.4,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorPalleteLogin.OrangeLightColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
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
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      onPressed: () async {
                        await controllerPrintOrder.capture().then((bytes) {
                          if (bytes != null ){
                            // panggil woe
                            saveImage(bytes);
                            saveAndShare(bytes);
                          }
                        }).catchError((onError){
                          debugPrint(onError);
                        });
                      },
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
  Future<void> saveImage(Uint8List bytes) async{
    final name = 'Screentsho_$time';
    await Permission.storage.request();
    final result = await ImageGallerySaver.saveImage(bytes, name: name);
    debugPrint('result : $result');
  }
  
  // function saveimage
  Future<void> saveAndShare(Uint8List bytes) async{

    final dir = Platform.isAndroid ? await getExternalStorageDirectory() 
    : await getApplicationDocumentsDirectory(); 

    final image = File('${dir!.path}/$time.png');
  }
}


class NoteDeliveryOrder extends StatelessWidget {
  const NoteDeliveryOrder({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      width: MediaQuery.of(context).size.width * 0.6,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // header
            Text('SURAT JALAN'),
            Divider(
              thickness: 2,
            ),

            // logo + detail (kop surat)
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Image(
                    image: AssetImage('assets/logo2.png'),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15.0, right: 25.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Gudang PT. TOSERBA XXX',
                          textAlign: TextAlign.end,
                        ),
                        Text(
                          'Jln Ahmad yani No 8, Kec Tegalsari, Surabaya, Jawa timur, 60171',
                          textAlign: TextAlign.end,
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'No.   ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('12345678900'),
                        ],
                      ),
                      Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tgl   ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('24 Jan 2024'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Divider(
              thickness: 2,
            ),
            // SizedBox(height: 10,),

            // content
            Text(
              'Penerima',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('TOKO TOSERBA XXXXX JAKARTA'),
            Text(
                'Jln Ahmad yani No 8-12, Kedungdoro Kec Tegalsari, Jakarta, DKI Jakarta, 60171'),
            SizedBox(
              height: 10,
            ),

            // table
            TableDeliveryOrder(),
            Divider(
              thickness: 2,
            ),
            SizedBox(
              height: 10,
            ),

            // tanda tangan
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Center(
                        child: Text(
                      'Penerima:',
                    )),
                    SizedBox(
                      height: 75,
                    ),
                    Text('(......................................)'),
                  ],
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6 * 0.1,
                ),
                Column(
                  children: [
                    Center(
                        child: Text(
                      'Pengirim:',
                    )),
                    SizedBox(
                      height: 75,
                    ),
                    Text('(......................................)'),
                  ],
                ),
              ],
            ),

            // kasih spasi
            SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }
}

class TableDeliveryOrder extends StatelessWidget {
  const TableDeliveryOrder({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DataTable(
      border: TableBorder.all(
        color: Colors.black,
      ),
      columns: [
        DataColumn(label: Text('NO')),
        DataColumn(label: Text('Nama produk')),
        DataColumn(label: Text('Jumlah')),
        DataColumn(label: Text('Satuan')),
        DataColumn(label: Text('Nomor batch')),
        DataColumn(label: Text('Expire date')),
      ],
      rows: [
        DataRow(
          cells: [
            DataCell(Text('1')),
            DataCell(Text('Gelas kaca')),
            DataCell(Text('1')),
            DataCell(Text('unit')),
            DataCell(Text('132980')),
            DataCell(Text('')),
          ],
        ),
        DataRow(
          cells: [
            DataCell(Text('2')),
            DataCell(Text('Beras Pandan Wang')),
            DataCell(Text('10000')),
            DataCell(Text('gram')),
            DataCell(Text('809213')),
            DataCell(Text('01/01/2025')),
          ],
        ),
        DataRow(
          cells: [
            DataCell(Text('3')),
            DataCell(Text('Beras Pandan Wang 5 KG')),
            DataCell(Text('1')),
            DataCell(Text('unit')),
            DataCell(Text('52894')),
            DataCell(Text('02/01/2025')),
          ],
        ),
        DataRow(
          cells: [
            DataCell(Text('4')),
            DataCell(Text('Sapu')),
            DataCell(Text('1')),
            DataCell(Text('unit')),
            DataCell(Text('52942')),
            DataCell(Text('')),
          ],
        ),
        DataRow(
          cells: [
            DataCell(Text('5')),
            DataCell(Text('Botol minum')),
            DataCell(Text('1')),
            DataCell(Text('unit')),
            DataCell(Text('234906')),
            DataCell(Text('')),
          ],
        ),
        DataRow(
          cells: [
            DataCell(Text('6')),
            DataCell(Text('Cangkir')),
            DataCell(Text('1')),
            DataCell(Text('unit')),
            DataCell(Text('43298')),
            DataCell(Text('')),
          ],
        ),
        DataRow(
          cells: [
            DataCell(Text('7')),
            DataCell(Text('Mangkok')),
            DataCell(Text('1')),
            DataCell(Text('unit')),
            DataCell(Text('64983')),
            DataCell(Text('')),
          ],
        ),
        DataRow(
          cells: [
            DataCell(Text('8')),
            DataCell(Text('Piring')),
            DataCell(Text('1')),
            DataCell(Text('unit')),
            DataCell(Text('534798')),
            DataCell(Text('')),
          ],
        ),
      ],
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

class SuratJalan extends StatelessWidget {
  const SuratJalan({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Text(
              'Delivery Order ID: #219031203913',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text('Date: 01 July 2024'),
            SizedBox(height: 20),
            Text(
              'SURAT JALAN',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Image.asset(
                'assets/logo.png'), // Replace with your actual logo asset
            SizedBox(height: 20),
            Text(
              'Penerima',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text('TOKO TOSERBA XXXX JAKARTA'),
            SizedBox(height: 10),
            Text(
                'Jl. Jenderal Basuki Rachmat No.8-12, Kedungdoro, Kec. Tegalsari, Surabaya, Jawa Timur 60261'),
            SizedBox(height: 20),
            DataTable(
              columns: [
                DataColumn(label: Text('NO')),
                DataColumn(label: Text('Nama produk')),
                DataColumn(label: Text('Jumlah')),
                DataColumn(label: Text('Satuan')),
                DataColumn(label: Text('Nomor batch')),
                DataColumn(label: Text('Expire date')),
              ],
              rows: [
                DataRow(
                  cells: [
                    DataCell(Text('1')),
                    DataCell(Text('Gelas kaca')),
                    DataCell(Text('1')),
                    DataCell(Text('unit')),
                    DataCell(Text('132980')),
                    DataCell(Text('')),
                  ],
                ),
                DataRow(
                  cells: [
                    DataCell(Text('2')),
                    DataCell(Text('Beras Pandan Wang')),
                    DataCell(Text('10000')),
                    DataCell(Text('gram')),
                    DataCell(Text('809213')),
                    DataCell(Text('01/01/2025')),
                  ],
                ),
                DataRow(
                  cells: [
                    DataCell(Text('3')),
                    DataCell(Text('Beras Pandan Wang 5 KG')),
                    DataCell(Text('1')),
                    DataCell(Text('unit')),
                    DataCell(Text('52894')),
                    DataCell(Text('02/01/2025')),
                  ],
                ),
                DataRow(
                  cells: [
                    DataCell(Text('4')),
                    DataCell(Text('Sapu')),
                    DataCell(Text('1')),
                    DataCell(Text('unit')),
                    DataCell(Text('52942')),
                    DataCell(Text('')),
                  ],
                ),
                DataRow(
                  cells: [
                    DataCell(Text('5')),
                    DataCell(Text('Botol minum')),
                    DataCell(Text('1')),
                    DataCell(Text('unit')),
                    DataCell(Text('234906')),
                    DataCell(Text('')),
                  ],
                ),
                DataRow(
                  cells: [
                    DataCell(Text('6')),
                    DataCell(Text('Cangkir')),
                    DataCell(Text('1')),
                    DataCell(Text('unit')),
                    DataCell(Text('43298')),
                    DataCell(Text('')),
                  ],
                ),
                DataRow(
                  cells: [
                    DataCell(Text('7')),
                    DataCell(Text('Mangkok')),
                    DataCell(Text('1')),
                    DataCell(Text('unit')),
                    DataCell(Text('64983')),
                    DataCell(Text('')),
                  ],
                ),
                DataRow(
                  cells: [
                    DataCell(Text('8')),
                    DataCell(Text('Piring')),
                    DataCell(Text('1')),
                    DataCell(Text('unit')),
                    DataCell(Text('534798')),
                    DataCell(Text('')),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'GUDANG PT. TOSERBA XXXX',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Jl. Jenderal Basuki Rachmat No.8-12, Kedungdoro, Kec. Tegalsari, Surabaya, Jawa Timur 60261',
            ),
            SizedBox(height: 10),
            Text(
              'No: 3218318231',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text('Tgl: 24 Jan 2024'),
            SizedBox(height: 20),
            Text(
              'Penerima:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Pengirim:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              child: Text('Print Delivery Order'),
            ),
          ],
        ),
      ),
    );
  }
}
