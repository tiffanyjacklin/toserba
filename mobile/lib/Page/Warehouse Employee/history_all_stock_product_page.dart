import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_all/Template.dart';
import 'package:number_paginator/number_paginator.dart';
import 'package:flutter_app_all/Model/StockCardProductStoreWarehouse.dart' as stock;
import 'package:http/http.dart' as http;

var jsonProduct = {
"status": 200,
"message": "Berhasil",
"data": [
{
"stock_card_id": 1,
"product_detail_id": 3,
"stock_date": "2024-08-20",
"stock_description": "First Stock",
"product_name": "Spinach",
"product_batch": "1",
"product_stock": 20,
"product_unit": "gram",
"expired_date": "2025-08-16",
"stock_in": 20,
"stock_out": 0,
"store_warehouse_id": 2
},
{
"stock_card_id": 2,
"product_detail_id": 3,
"stock_date": "2024-08-20",
"stock_description": "Purchased",
"product_name": "Spinach",
"product_batch": "1",
"product_stock": 15,
"product_unit": "gram",
"expired_date": "2025-08-16",
"stock_in": 0,
"stock_out": 5,
"store_warehouse_id": 2
},
{
"stock_card_id": 3,
"product_detail_id": 3,
"stock_date": "2024-08-20",
"stock_description": "Purchase",
"product_name": "Spinach",
"product_batch": "1",
"product_stock": 13,
"product_unit": "gram",
"expired_date": "2025-08-16",
"stock_in": 0,
"stock_out": 2,
"store_warehouse_id": 2
},
{
"stock_card_id": 4,
"product_detail_id": 3,
"stock_date": "2024-08-20",
"stock_description": "Purchase",
"product_name": "Spinach",
"product_batch": "1",
"product_stock": 10,
"product_unit": "gram",
"expired_date": "2025-08-16",
"stock_in": 0,
"stock_out": 3,
"store_warehouse_id": 2
},
{
"stock_card_id": 5,
"product_detail_id": 3,
"stock_date": "2024-08-20",
"stock_description": "Purchase",
"product_name": "Spinach",
"product_batch": "2",
"product_stock": 40,
"product_unit": "gram",
"expired_date": "2025-08-20",
"stock_in": 30,
"stock_out": 0,
"store_warehouse_id": 2
},
{
"stock_card_id": 15,
"product_detail_id": 3,
"stock_date": "0000-00-00",
"stock_description": "Stock Out",
"product_name": "Spinach",
"product_batch": "1",
"product_stock": 30,
"product_unit": "gram",
"expired_date": "2025-08-16",
"stock_in": 0,
"stock_out": 10,
"store_warehouse_id": 2
},
{
"stock_card_id": 16,
"product_detail_id": 3,
"stock_date": "0000-00-00",
"stock_description": "Stock Out",
"product_name": "Spinach",
"product_batch": "2",
"product_stock": 25,
"product_unit": "gram",
"expired_date": "2025-08-20",
"stock_in": 0,
"stock_out": 5,
"store_warehouse_id": 2
},
{
"stock_card_id": 6,
"product_detail_id": 4,
"stock_date": "2024-08-20",
"stock_description": "Purchase",
"product_name": "Pepper",
"product_batch": "1",
"product_stock": 40,
"product_unit": "gram",
"expired_date": "2025-08-20",
"stock_in": 40,
"stock_out": 0,
"store_warehouse_id": 2
},
{
"stock_card_id": 18,
"product_detail_id": 4,
"stock_date": "0000-00-00",
"stock_description": "Moving",
"product_name": "Pepper",
"product_batch": "1",
"product_stock": 35,
"product_unit": "gram",
"expired_date": "2025-08-20",
"stock_in": 0,
"stock_out": 5,
"store_warehouse_id": 2
},
{
"stock_card_id": 19,
"product_detail_id": 4,
"stock_date": "2024-08-21",
"stock_description": "Moving",
"product_name": "Pepper",
"product_batch": "1",
"product_stock": 30,
"product_unit": "gram",
"expired_date": "2025-08-20",
"stock_in": 0,
"stock_out": 5,
"store_warehouse_id": 2
},
{
"stock_card_id": 21,
"product_detail_id": 4,
"stock_date": "2024-08-21",
"stock_description": "Stock In",
"product_name": "Pepper",
"product_batch": "1",
"product_stock": 45,
"product_unit": "gram",
"expired_date": "2025-08-25",
"stock_in": 15,
"stock_out": 0,
"store_warehouse_id": 2
},
{
"stock_card_id": 22,
"product_detail_id": 4,
"stock_date": "2024-08-21",
"stock_description": "Stock In",
"product_name": "Pepper",
"product_batch": "2",
"product_stock": 60,
"product_unit": "gram",
"expired_date": "2025-08-25",
"stock_in": 15,
"stock_out": 0,
"store_warehouse_id": 2
},
{
"stock_card_id": 23,
"product_detail_id": 4,
"stock_date": "2024-08-21",
"stock_description": "Stock In",
"product_name": "Pepper",
"product_batch": "3",
"product_stock": 65,
"product_unit": "gram",
"expired_date": "2025-08-25",
"stock_in": 5,
"stock_out": 0,
"store_warehouse_id": 2
},
{
"stock_card_id": 24,
"product_detail_id": 4,
"stock_date": "2024-08-21",
"stock_description": "Stock In",
"product_name": "Pepper",
"product_batch": "4",
"product_stock": 70,
"product_unit": "gram",
"expired_date": "2025-08-25",
"stock_in": 5,
"stock_out": 0,
"store_warehouse_id": 2
},
{
"stock_card_id": 25,
"product_detail_id": 4,
"stock_date": "2024-08-21",
"stock_description": "Stock In",
"product_name": "Pepper",
"product_batch": "5",
"product_stock": 75,
"product_unit": "gram",
"expired_date": "2025-08-25",
"stock_in": 5,
"stock_out": 0,
"store_warehouse_id": 2
},
{
"stock_card_id": 26,
"product_detail_id": 4,
"stock_date": "2024-08-21",
"stock_description": "Moving",
"product_name": "Pepper",
"product_batch": "2",
"product_stock": 70,
"product_unit": "gram",
"expired_date": "2025-08-25",
"stock_in": 0,
"stock_out": 5,
"store_warehouse_id": 2
},
{
"stock_card_id": 31,
"product_detail_id": 4,
"stock_date": "2024-08-21",
"stock_description": "Stock Out",
"product_name": "Pepper",
"product_batch": "1",
"product_stock": 65,
"product_unit": "gram",
"expired_date": "2025-08-20",
"stock_in": 0,
"stock_out": 5,
"store_warehouse_id": 2
},
{
"stock_card_id": 32,
"product_detail_id": 4,
"stock_date": "2024-08-21",
"stock_description": "Stock Out",
"product_name": "Pepper",
"product_batch": "5",
"product_stock": 60,
"product_unit": "gram",
"expired_date": "2025-08-25",
"stock_in": 0,
"stock_out": 5,
"store_warehouse_id": 2
},
{
"stock_card_id": 33,
"product_detail_id": 4,
"stock_date": "2024-08-21",
"stock_description": "Stock Out",
"product_name": "Pepper",
"product_batch": "1",
"product_stock": 55,
"product_unit": "gram",
"expired_date": "2025-08-20",
"stock_in": 0,
"stock_out": 5,
"store_warehouse_id": 2
},
{
"stock_card_id": 7,
"product_detail_id": 14,
"stock_date": "2024-08-21",
"stock_description": "First Stock",
"product_name": "Tomato",
"product_batch": "1",
"product_stock": 1000,
"product_unit": "gram",
"expired_date": "2024-08-23",
"stock_in": 1000,
"stock_out": 0,
"store_warehouse_id": 2
}
]
};

Future _FetchAllStockProductWarehouse(int warehouseId) async {
    final link =
        'http://leap.crossnet.co.id:8888/products/stock/card/product/store_warehouse/$warehouseId';

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
        return stock.FetchStockCardProductStoreWarehouse.fromJson(temp).data!;
      }
      else{
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

class HistoryAllStockProductPage extends StatefulWidget {
  HistoryAllStockProductPage({super.key});

  @override
  State<HistoryAllStockProductPage> createState() => _HistoryAllStockProductPageState();
}

class _HistoryAllStockProductPageState extends State<HistoryAllStockProductPage> {
  final NumberPaginatorController _controller = NumberPaginatorController();
  // List<stock.Data> listAllHistoryProduct = stock.FetchStockCardProductStoreWarehouse.fromJson(jsonProduct).data!.cast<stock.Data>();
  var _currentPage = 1;

  List<stock.Data> listAllHistoryProduct = [];
  List<stock.Data> searchedHistoryProduct = [];

  // cotnroller
  TextEditingController controllerSearch = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // coba
    _FetchAllStockProductWarehouse(2).then((onValue) =>
    setState(() {
      listAllHistoryProduct = onValue;
      searchedHistoryProduct = listAllHistoryProduct;
    }));
  }

  @override
  Widget build(context) {
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
              // judul 
              TitlePage(name: 'History'),

              // search bar
              SizedBox(
                height: 15,
              ),

              Container(
                width: MediaQuery.of(context).size.width * 0.70,
                child: CupertinoSearchTextField(
                  controller: controllerSearch,
                  onChanged: (context) => {
                    _searchName(controllerSearch.text)
                  },
                ),
              ),

              // paginate
              searchedHistoryProduct.length != 0 ? Container(
                width: MediaQuery.of(context).size.width * 0.5,
                child: NumberPaginator(
                  // by default, the paginator shows numbers as center content
                  numberPages:  (searchedHistoryProduct.length/5).toInt() ,
                  onPageChange: (int index) {
                    setState(() {
                      _currentPage =
                          index; // _currentPage is a variable within State of StatefulWidget
                    });
                  },
                  nextButtonBuilder: (context) => TextButton(
                    onPressed: _controller.currentPage > 0
                        ? () => _controller.next()
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
              ) : Container(),

              // table 
              TableStockCardAllProducts(listStockCard: this.searchedHistoryProduct, startIndex: 5),
            ]
          ),
        ),
      ),
    );
  }


  // Function search by name
  void _searchName(String enterKeyword){
    List<stock.Data> results = [];

    // cek misal kosong berati bedasarkan semua
    if(enterKeyword.isEmpty){
      results = listAllHistoryProduct;
    }
    else{
      results = listAllHistoryProduct.where((data) => data.productName!.toLowerCase().contains(enterKeyword.toLowerCase())).toList();
    }

    setState(() {
      searchedHistoryProduct = results;
    });
  }
}












class TableStockCardAllProducts extends StatelessWidget {
  List<stock.Data> listStockCard = List.empty();
  var startIndex = 0;

  TableStockCardAllProducts({
    required this.listStockCard,
    required this.startIndex,
    super.key,
  });

  // how to check this changes?

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
            3: FlexColumnWidth(4),
            4: FlexColumnWidth(2),
            5: FlexColumnWidth(2),
            6: FlexColumnWidth(3),
            7: FlexColumnWidth(5),
            8: FlexColumnWidth(4),
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
                    child: Text('PRODUCT NAME',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('BATCH',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('EXPIRY DATE',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'IN',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('OUT',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('UNIT TYPE',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('REASON',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('DATE',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),

            // making the content
            ...List.generate(
              listStockCard.length <= 0 ? listStockCard.length : 5,
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
                        '${index + 1 + startIndex}',
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
                        '${listStockCard[index+startIndex].productName}',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('${listStockCard[index+startIndex].productBatch}',
                          style: TextStyle(
                            fontSize: 14,
                          )),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        '${listStockCard[index+startIndex].expiredDate}',
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
                        listStockCard[index+startIndex].stockIn != 0 ? '${listStockCard[index+startIndex].stockIn}' : '-',
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
                        listStockCard[index+startIndex].stockOut != 0 ? '${listStockCard[index+startIndex].stockOut}' : '-',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('${listStockCard[index+startIndex].productUnit}',
                          style: TextStyle(
                            fontSize: 14,
                          )),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('${listStockCard[index+startIndex].stockDescription}',
                          style: TextStyle(
                            fontSize: 14,
                          )),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('${listStockCard[index+startIndex].stockDate}',
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













