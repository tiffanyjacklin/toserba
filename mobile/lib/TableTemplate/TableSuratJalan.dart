import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_all/Model/DeliveryTransferDetail.dart' as deliveryDetail;
import 'package:intl/intl.dart';

class NoteDeliveryOrder extends StatelessWidget {
  List<deliveryDetail.Data> listItemDelivery = [];
  // buat kop jalan juga belum
  // var DataWarehousePenerima;
  // var DataWarehousePengirim;
  NoteDeliveryOrder({
    this.listItemDelivery = const [],
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      width: MediaQuery.of(context).size.width * 0.7,
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
            Text(
              'TOKO TOSERBA XXXXX JAKARTA',
            ),
            Text(
                'Jln Ahmad yani No 8-12, Kedungdoro Kec Tegalsari, Jakarta, DKI Jakarta, 60171'),
            SizedBox(
              height: 10,
            ),

            // table
            TableDeliveryOrderNew(listItemDelivery: this.listItemDelivery,),

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


class TableDeliveryOrderNew extends StatelessWidget {
  List<deliveryDetail.Data> listItemDelivery = [];
  TableDeliveryOrderNew({
    required this.listItemDelivery,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(color: Colors.black),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(6),
        2: FlexColumnWidth(3),
        3: FlexColumnWidth(2),
        4: FlexColumnWidth(3),
        5: FlexColumnWidth(3),
      },
      children: [
        // making the judul
        const TableRow(
          children: [
            TableCell(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'No',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            TableCell(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Nama Produk',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            ),
            TableCell(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Jumlah',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            TableCell(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Satuan',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            ),
            TableCell(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Nomor Batch',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            ),
            TableCell(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Expire Date',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),

        // making the content
        ...List.generate(
          listItemDelivery!.length,
          (index) => TableRow(
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
                  child: Text('${listItemDelivery![index].productName}',
                      style: TextStyle(
                        fontSize: 14,
                      )),
                ),
              ),
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    '${listItemDelivery![index].quantity}',
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('${listItemDelivery![index].unitType}',
                      style: TextStyle(
                        fontSize: 14,
                      )),
                ),
              ),
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('${listItemDelivery![index].batch}',
                      style: TextStyle(
                        fontSize: 14,
                      )),
                ),
              ),
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('${DateFormat('dd/MM/yyyy').format(DateTime.parse(listItemDelivery![index].expiredDate!))}',
                      style: TextStyle(
                        fontSize: 14,
                      )),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}