import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_all/Model/StockOpname.dart' as opname;
import 'package:flutter_app_all/Page/Login/login_tablet.dart';
import 'package:flutter_app_all/Template.dart';
import 'package:flutter_app_all/Model/AllProduct.dart';
// import 'package:flutter_app_all/Model/SessionList.dart';
import 'package:flutter_app_all/Model/StockCardProductStoreWarehouse.dart'
    as stock;
import 'package:http/http.dart' as http;

Future _fetchProduct(int userId, int roleId) async {
  // /products/store_warehouse/:user_id/:role_id"
  // link api http://leap.crossnet.co.id:8888/user/1/1
  // link localhost -> http://localhost:8888/user/
  final link =
      'http://leap.crossnet.co.id:8888/products/store_warehouse/$userId/$roleId';

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
      return FetchAllProducts.fromJson(temp).data!;
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

Future _fetchProductStockOpname(int productId, int storeWarehouseId) async {
  // link api http://leap.crossnet.co.id:8888/products/stock/opname/data/store_warehouse/:product_id/:sw_id
  // link localhost -> http://localhost:8888/user/

  final link =
      'http://leap.crossnet.co.id:8888/products/stock/opname/data/store_warehouse/$productId/$storeWarehouseId';

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
      return opname.FetchStockOpnameWarehouse.fromJson(temp).data!;
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

Future _fetchProductStockCard(int productId, int storeWarehouseId) async {
  // /products/store_warehouse/:user_id/:role_id"
  // link api http://leap.crossnet.co.id:8888/user/1/1
  // link localhost -> http://localhost:8888/user/

  final link =
      'http://leap.crossnet.co.id:8888/products/stock/card/product/store_warehouse/$productId/$storeWarehouseId';

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
      return stock.FetchStockCardProductStoreWarehouse.fromJson(temp).data!;
    } 
    else {
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

class ProductPage extends StatefulWidget {
  ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  // manual
  // List<Data> listProduct = FetchAllProduct.fromJson(jsonAllProduct).data!;
  List<Data> listProduct = [];

  // for searched list
  List<Data> searchedList = [];
  TextEditingController controllerSearch = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProduct(1, 2).then((onValue) => {
          setState(() {
            listProduct = onValue;
            searchedList = listProduct;
          })
        });
  }

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
              Text(
                'Products',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: ColorPalleteLogin.PrimaryColor),
              ),

              SizedBox(
                height: 15,
              ),

              Container(
                width: MediaQuery.of(context).size.width * 0.70,
                child: CupertinoSearchTextField(
                  controller: controllerSearch,
                  onChanged: (value) {
                    print('-->  ${controllerSearch.text} ');
                    // result 
                    var result = listProduct.where((data) => data.productDetails!.productName!.toLowerCase().contains(controllerSearch.text.toLowerCase())).toList();
                    setState(() {
                      // kerjain search logic
                      searchedList = result;
                    });
                  },
                ),
              ),

              SizedBox(
                height: 10,
              ),

              // template listview
              ...List.generate(
                (searchedList.length),
                (index) => ProductTile(dataProduct: searchedList[index]),
              ),

              // Note : Kurang Pagination + desain search
            ],
          ),
        ),
      ),
    );
  }
}

class ProductTile extends StatelessWidget {
  Data dataProduct;
  ProductTile({
    required this.dataProduct,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.black, width: 1),
          borderRadius: BorderRadius.circular(16.0),
        ),
        leading: CachedNetworkImage(
          imageUrl:
              'https://down-id.img.susercontent.com/file/id-11134201-7qul0-li5pa6watzho05',
          width: 50,
          height: 50,
          placeholder: (context, url) => CircularProgressIndicator(),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
        title: Text(
          '${this.dataProduct.productDetails!.productCode}',
          style: TextStyle(
            color: ColorPalleteLogin.OrangeDarkColor,
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          '${this.dataProduct.productDetails!.productName}',
          style: TextStyle(
            color: ColorPalleteLogin.PrimaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        trailing: Column(
          children: [
            Expanded(
              child: Text(
                'Stock :${this.dataProduct.productDetails!.productStock}',
                style: TextStyle(
                    color: ColorPalleteLogin.PrimaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorPalleteLogin.PrimaryColor,
                ),
                child: Wrap(
                  spacing: 12,
                  children: [
                    Icon(
                      Icons.remove_red_eye,
                      size: 20,
                      color: ColorPalleteLogin.OrangeColor,
                    ),
                    Text(
                      'View',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                onPressed: () {
                  // buat alert dialog
                  showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) => ProductDetailsPopup(
                      productData: dataProduct,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// product detail popup
class ProductDetailsPopup extends StatefulWidget {
  Data productData;
  ProductDetailsPopup({super.key, required this.productData});

  @override
  State<ProductDetailsPopup> createState() => _ProductDetailsPopupState();
}

class _ProductDetailsPopupState extends State<ProductDetailsPopup> {
  var _customTileExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
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
                    'Product Details',
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
                  SubTitleText(
                    judul: 'Product ID',
                    data:
                        '${widget.productData.productDetails!.productDetailId}',
                  ),
                  SubTitleText(
                    judul: 'Product Name',
                    data: '${widget.productData.productDetails!.productName}',
                  ),
                  SubTitleText(
                    judul: 'Product Brand',
                    data: '${widget.productData.suppliers!.supplierName}',
                  ),
                  SubTitleText(
                    judul: 'Product Type',
                    data:
                        '${widget.productData.productCategories!.productCategoryName}',
                  ),
                  SubTitleText(
                    judul: 'Date Added',
                    data:
                        '${widget.productData.productDetails!.productTimestamp}', // harusnya pakai dd/mm/yyyy
                  ),
                  SubTitleText(
                    judul: 'Expiration Date',
                    data: '${widget.productData.productDetails!.expiryDate}',
                  ),

                  SubTitleText(
                    judul: 'Last Inventory Taking',
                    data: '01/07/2024',
                  ),

                  SubTitleText(
                    judul: 'Buy Price',
                    data: '${widget.productData.productDetails!.buyPrice}',
                  ),

                  SubTitleText(
                    judul: 'Sell Price',
                    data: '${widget.productData.productDetails!.sellPrice}',
                  ),

                  SubTitleText(
                    judul: 'Min Stock',
                    data: '${widget.productData.productDetails!.minStock}',
                  ),

                  // table current stock
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
                        'Current Stock',
                        style: TextStyle(
                            fontSize: 16,
                            color: ColorPalleteLogin.OrangeLightColor,
                            fontWeight: FontWeight.bold),
                      ),
                      children: [
                        FutureBuilder(
                            future: _fetchProductStockOpname(widget.productData.productDetails!.productDetailId!, 1),
                            builder: (context, snapshot) {
                              // do something
                              if (snapshot.hasData) {
                                // jika sudah ada data
                                return Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    width: MediaQuery.of(context).size.width * 0.5,
                                    child: TableCurrentStockCardProducts(
                                        listStockCard: snapshot.data ),
                                  ),
                                );
                              } else {
                                // loading
                                return Center(
                                    child: CircularProgressIndicator());
                              }
                            }),
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
                        FutureBuilder(
                            future: _fetchProductStockCard(
                                widget.productData.productDetails!
                                    .productDetailId!,
                                1),
                            builder: (context, snapshot) {
                              // do something
                              if (snapshot.hasData) {
                                // TableStockCardProducts(listStockCard: stock.FetchStockCardProductStoreWarehouse.fromJson(jsonSpinachStockCard).data!);
                                
                                // jika sudah ada data
                                return TableStockCardProducts(
                                    listStockCard: snapshot.data );
                              } else {
                                // loading
                                return Center(
                                    child: CircularProgressIndicator());
                              }
                            }),
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

                  // button close
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
                              'Close',
                              style: TextStyle(
                                color: ColorPalleteLogin.PrimaryColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        onPressed: () {
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
}



class TableStockCardProducts extends StatelessWidget {
  List<stock.Data> listStockCard = List.empty();
  TableStockCardProducts({
    required this.listStockCard,
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
            1: FlexColumnWidth(3),
            2: FlexColumnWidth(4),
            3: FlexColumnWidth(3),
            4: FlexColumnWidth(3),
            5: FlexColumnWidth(3),
            6: FlexColumnWidth(5),
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
                    child: Text(
                      'NO',
                      style: TableContentTextStyle.textStyle,
                    ),
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
                    child: Text('EXPIRY DATE',
                        style: TableContentTextStyle.textStyle),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'IN',
                      style: TableContentTextStyle.textStyle,
                    ),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('OUT', style: TableContentTextStyle.textStyle),
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
                        Text('REASON', style: TableContentTextStyle.textStyle),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('DATE', style: TableContentTextStyle.textStyle),
                  ),
                ),
              ],
            ),

            // making the content
            ...List.generate(
              listStockCard.length,
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
                      child: Text('${index + 1}',
                          style: TableContentTextStyle.textStyleBody),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('${listStockCard[index].productBatch}',
                          style: TableContentTextStyle.textStyleBody),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('${listStockCard[index].expiredDate}',
                          style: TableContentTextStyle.textStyleBody),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                          listStockCard[index].stockIn != 0
                              ? '${listStockCard[index].stockIn}'
                              : '-',
                          style: TableContentTextStyle.textStyleBody),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                          listStockCard[index].stockOut != 0
                              ? '${listStockCard[index].stockOut}'
                              : '-',
                          style: TableContentTextStyle.textStyleBody),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('${listStockCard[index].productUnit}',
                          style: TableContentTextStyle.textStyleBody),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('${listStockCard[index].stockDescription}',
                          style: TableContentTextStyle.textStyleBody),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('${listStockCard[index].stockDate}',
                          style: TableContentTextStyle.textStyleBody),
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

class TableCurrentStockCardProducts extends StatelessWidget {
  List<opname.Data> listStockCard = List.empty();
  TableCurrentStockCardProducts({
    required this.listStockCard,
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
            0: FlexColumnWidth(4),
            1: FlexColumnWidth(4),
            2: FlexColumnWidth(3),
            3: FlexColumnWidth(3),

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
                    child:
                        Text('BATCH', style: TableContentTextStyle.textStyle),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('EXPIRY DATE',
                        style: TableContentTextStyle.textStyle),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'STOCK',
                      style: TableContentTextStyle.textStyle,
                    ),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('UNIT TYPE',
                        style: TableContentTextStyle.textStyle),
                  ),
                ),
              ],
            ),

            // making the content
            ...List.generate(
              listStockCard.length,
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
                      child: Text('${listStockCard[index].batch}',
                          style: TableContentTextStyle.textStyleBody),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('${listStockCard[index].expiredDate}',
                          style: TableContentTextStyle.textStyleBody),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        '${listStockCard[index].expectedStock}',
                          style: TableContentTextStyle.textStyleBody),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('${listStockCard[index].unitType}',
                          style: TableContentTextStyle.textStyleBody),
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


Map<String, dynamic> jsonSpinachStockCard = {
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
    }
  ]
};
