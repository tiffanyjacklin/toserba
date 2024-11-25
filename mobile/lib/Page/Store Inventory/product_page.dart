import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Toserba_App/Model/StockOpname.dart' as opname;
import 'package:Toserba_App/Tambahan/Provider/Auth.dart';
import 'package:Toserba_App/Tambahan/Provider/ProductProvider.dart';
// import 'package:flutter_app_all/Page/Login/login_tablet.dart';
import 'package:Toserba_App/Template.dart';
import 'package:Toserba_App/Model/AllProduct.dart';
import 'package:Toserba_App/Model/StockCardProductStoreWarehouse.dart'
    as stock;
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:number_paginator/number_paginator.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

Future<List<opname.Data>> _fetchProductStockOpname(
    int productId, int storeWarehouseId) async {
  // link api http://leap.crossnet.co.id:8888/products/stock/opname/data/store_warehouse/:product_id/:sw_id
  // link localhost -> http://localhost:8888/user/

  final link =
      'http://leap.crossnet.co.id:8888/products/stock/opname/data/store_warehouse/$productId/$storeWarehouseId/0/0';

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
      'http://leap.crossnet.co.id:8888/products/stock/card/product/store_warehouse/$productId/$storeWarehouseId/0/0';

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

Future<String> scanBarcodeNormal() async{
  String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode("#ff6666", "Cancel", false, ScanMode.BARCODE);
  debugPrint(barcodeScanRes);

  return barcodeScanRes;
}

class ProductPages extends StatelessWidget {
  const ProductPages({super.key});

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AuthState>(context);
    return ChangeNotifierProvider(
      create: (context) => ProductProvider(provider.userData.userId!,
          provider.userData.roleId!, provider.userData.storeWarehouseId!),
      child: ProductPage(),
    );
  }
}

class ProductPage extends StatefulWidget {
  ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  TextEditingController controllerSearch = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var providerProduct = Provider.of<ProductProvider>(context);
    var providerAuth = Provider.of<AuthState>(context);

    List<Data> searchedList = providerProduct.getItemPerPage();
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
                width: MediaQuery.of(context).size.width * 0.8,
                child: Row(
                  children: [
                    Expanded(
                      flex: 8,
                      child: TextField(
                        style: TextStyle(
                          fontSize: fontSizeBody,
                        ),
                        controller: controllerSearch,
                        onSubmitted: (value) {
                          providerProduct.clickFilter2(
                              providerAuth.userData.userId!,
                              providerAuth.userData.roleId!,
                              providerAuth.userData.storeWarehouseId!,
                              controllerSearch.text);
                        },
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          focusColor: ColorPalleteLogin.OrangeColor,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide: const BorderSide(
                              color: Colors.grey,
                              width: 2.0,
                            ),
                          ),
                          suffixIcon: IconButton(
                              onPressed: () {
                                providerProduct.clickFilter(
                                    providerAuth.userData.userId!,
                                    providerAuth.userData.roleId!,
                                    providerAuth.userData.storeWarehouseId!,
                                    controllerSearch.text);
                              },
                              icon: Icon(Icons.filter_list)),
                        ),
                      ),
                    ),
                    SizedBox(width: 5,),
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () {
                          scanBarcodeNormal().then((onValue) => {
                            controllerSearch.text = onValue,

                            providerProduct.resetFilter(),
                           providerProduct.clickFilter2(
                              providerAuth.userData.userId!,
                              providerAuth.userData.roleId!,
                              providerAuth.userData.storeWarehouseId!,
                              controllerSearch.text),
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.0),
                            color: ColorPalleteLogin.OrangeLightColor,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(Icons.barcode_reader),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(
                height: 10,
              ),

              // template listview
              providerProduct.isLoading
                  ? CircularProgressIndicator()
                  : providerProduct.isFiltering
                      ? Container(
                          height: 350,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Center(
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                              blurRadius: 4,
                                              color: Colors.grey,
                                              offset: Offset(0, 1)),
                                        ]),
                                    width: MediaQuery.of(context).size.width *
                                        0.8 *
                                        0.98,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: GestureDetector(
                                              onTap: () {
                                                providerProduct.resetFilter();
                                              },
                                              child: Text(
                                                'Reset',
                                                style: TextStyle(
                                                    color: ColorPalleteLogin
                                                        .OrangeDarkColor,
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),

                                          // order
                                          Text(
                                            'Sort By',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Wrap(
                                            spacing: 10,
                                            children: List.generate(
                                                providerProduct.productOrder
                                                    .length, (index) {
                                              return Container(
                                                margin: EdgeInsets.symmetric(
                                                    horizontal: 2),
                                                child: providerProduct
                                                            .filterProduct ==
                                                        providerProduct
                                                            .productOrder[index]
                                                            .sortType
                                                    ? OutlinedButton(
                                                        onPressed: () {
                                                          providerProduct
                                                              .filterProduct = '';
                                                        },
                                                        child: Text(
                                                          providerProduct
                                                              .productOrder[
                                                                  index]
                                                              .sortType!,
                                                          style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: ColorPalleteLogin
                                                                  .OrangeDarkColor),
                                                        ),
                                                        style: OutlinedButton.styleFrom(
                                                            side: BorderSide(
                                                                strokeAlign: 2,
                                                                color: ColorPalleteLogin
                                                                    .OrangeDarkColor),
                                                            overlayColor:
                                                                ColorPalleteLogin
                                                                    .OrangeDarkColor),
                                                      )
                                                    : OutlinedButton(
                                                        onPressed: () {
                                                          providerProduct
                                                                  .filterProduct =
                                                              providerProduct
                                                                  .productOrder[
                                                                      index]
                                                                  .sortType!;
                                                        },
                                                        child: Text(
                                                          providerProduct
                                                              .productOrder[
                                                                  index]
                                                              .sortType!,
                                                          style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                        style: OutlinedButton.styleFrom(
                                                            side: BorderSide(
                                                                strokeAlign: 2,
                                                                color:
                                                                    Colors.grey[
                                                                        300]!),
                                                            overlayColor:
                                                                ColorPalleteLogin
                                                                    .OrangeDarkColor,
                                                            backgroundColor:
                                                                Colors
                                                                    .grey[300]),
                                                      ),
                                              );
                                            }),
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),

                                          // sorting
                                          Text(
                                            'Sorting Order',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Wrap(
                                            spacing: 10,
                                            children: List.generate(
                                                providerProduct.ascDec.length,
                                                (index) {
                                              return Container(
                                                margin: EdgeInsets.symmetric(
                                                    horizontal: 2),
                                                child: providerProduct
                                                            .ascDec[index] ==
                                                        providerProduct
                                                            .ascDecNow
                                                    ? OutlinedButton(
                                                        onPressed: () {},
                                                        child: Text(
                                                          providerProduct
                                                              .ascDec[index],
                                                          style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: ColorPalleteLogin
                                                                  .OrangeDarkColor),
                                                        ),
                                                        style: OutlinedButton.styleFrom(
                                                            side: BorderSide(
                                                                strokeAlign: 2,
                                                                color: ColorPalleteLogin
                                                                    .OrangeDarkColor),
                                                            overlayColor:
                                                                ColorPalleteLogin
                                                                    .OrangeDarkColor),
                                                      )
                                                    : OutlinedButton(
                                                        onPressed: () {
                                                          providerProduct
                                                                  .ascDecNow =
                                                              providerProduct
                                                                      .ascDec[
                                                                  index];
                                                        },
                                                        child: Text(
                                                          providerProduct
                                                              .ascDec[index],
                                                          style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                        style: OutlinedButton.styleFrom(
                                                            side: BorderSide(
                                                                strokeAlign: 2,
                                                                color:
                                                                    Colors.grey[
                                                                        300]!),
                                                            overlayColor:
                                                                ColorPalleteLogin
                                                                    .OrangeDarkColor,
                                                            backgroundColor:
                                                                Colors
                                                                    .grey[300]),
                                                      ),
                                              );
                                            }),
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),

                                          // sorting
                                          Text(
                                            'Unit Type',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Wrap(
                                            spacing: 10,
                                            children: List.generate(
                                                providerProduct.unitType.length,
                                                (index) {
                                              return Container(
                                                margin: EdgeInsets.symmetric(
                                                    horizontal: 2),
                                                child: providerProduct
                                                            .unitType[index] ==
                                                        providerProduct.unitNow
                                                    ? OutlinedButton(
                                                        onPressed: () {
                                                          providerProduct
                                                              .unitNow = '';
                                                        },
                                                        child: Text(
                                                          providerProduct
                                                              .unitType[index],
                                                          style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: ColorPalleteLogin
                                                                  .OrangeDarkColor),
                                                        ),
                                                        style: OutlinedButton.styleFrom(
                                                            side: BorderSide(
                                                                strokeAlign: 2,
                                                                color: ColorPalleteLogin
                                                                    .OrangeDarkColor),
                                                            overlayColor:
                                                                ColorPalleteLogin
                                                                    .OrangeDarkColor),
                                                      )
                                                    : OutlinedButton(
                                                        onPressed: () {
                                                          providerProduct
                                                                  .unitNow =
                                                              providerProduct
                                                                      .unitType[
                                                                  index];
                                                        },
                                                        child: Text(
                                                          providerProduct
                                                              .unitType[index],
                                                          style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                        style: OutlinedButton.styleFrom(
                                                            side: BorderSide(
                                                                strokeAlign: 2,
                                                                color:
                                                                    Colors.grey[
                                                                        300]!),
                                                            overlayColor:
                                                                ColorPalleteLogin
                                                                    .OrangeDarkColor,
                                                            backgroundColor:
                                                                Colors
                                                                    .grey[300]),
                                                      ),
                                              );
                                            }),
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),

                                          // Product Type
                                          Text(
                                            'Product Type',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Wrap(
                                            spacing: 10,
                                            children: List.generate(
                                                providerProduct.productType
                                                    .length, (index) {
                                              return Container(
                                                margin: EdgeInsets.symmetric(
                                                    horizontal: 2),
                                                child: providerProduct
                                                            .productType[index]
                                                            .productCategoryName ==
                                                        providerProduct.typeNow
                                                    ? OutlinedButton(
                                                        onPressed: () {
                                                          providerProduct
                                                              .typeNow = '';
                                                        },
                                                        child: Text(
                                                          providerProduct
                                                              .productType[
                                                                  index]
                                                              .productCategoryName!,
                                                          style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: ColorPalleteLogin
                                                                  .OrangeDarkColor),
                                                        ),
                                                        style: OutlinedButton.styleFrom(
                                                            side: BorderSide(
                                                                strokeAlign: 2,
                                                                color: ColorPalleteLogin
                                                                    .OrangeDarkColor),
                                                            overlayColor:
                                                                ColorPalleteLogin
                                                                    .OrangeDarkColor),
                                                      )
                                                    : OutlinedButton(
                                                        onPressed: () {
                                                          providerProduct
                                                                  .typeNow =
                                                              providerProduct
                                                                  .productType[
                                                                      index]
                                                                  .productCategoryName!;
                                                        },
                                                        child: Text(
                                                          providerProduct
                                                              .productType[
                                                                  index]
                                                              .productCategoryName!,
                                                          style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                        style: OutlinedButton.styleFrom(
                                                            side: BorderSide(
                                                                strokeAlign: 2,
                                                                color:
                                                                    Colors.grey[
                                                                        300]!),
                                                            overlayColor:
                                                                ColorPalleteLogin
                                                                    .OrangeDarkColor,
                                                            backgroundColor:
                                                                Colors
                                                                    .grey[300]),
                                                      ),
                                              );
                                            }),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),

                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: Container(
                                              height: 50,
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      ColorPalleteLogin
                                                          .OrangeLightColor,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20.0),
                                                  ),
                                                ),
                                                child: Wrap(
                                                  
                                                  children: [
                                                    Text(
                                                      'Apply',
                                                      style: TextStyle(
                                                        color: ColorPalleteLogin
                                                            .PrimaryColor,
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                onPressed: () {
                                                  providerProduct.clickFilter(
                                                      providerAuth
                                                          .userData.userId!,
                                                      providerAuth
                                                          .userData.roleId!,
                                                      providerAuth.userData
                                                          .storeWarehouseId!,
                                                      controllerSearch.text);
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                          ),
                        )
                      : providerProduct.getItemPerPage().isEmpty
                          ? Center(
                              child: Text(
                                'Data Tidak Ditemukan',
                                style: TextStyle(fontSize: fontSizeBody),
                              ),
                            )
                          : Column(
                              children: [
                                // paginator
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.70,
                                  child: NumberPaginator(
                                    config: NumberPaginatorUIConfig(
                                      buttonUnselectedForegroundColor:
                                          Colors.black,
                                      buttonSelectedBackgroundColor:
                                          Colors.black,
                                      buttonSelectedForegroundColor:
                                          Colors.white,
                                    ),
                                    // by default, the paginator shows numbers as center content
                                    numberPages: providerProduct.getMaxPage(),
                                    onPageChange: (int index) {},
                                    controller:
                                        providerProduct.paginatorController,

                                    // show/hide the prev/next buttons
                                    showPrevButton: true,
                                    showNextButton: true, // defaults to true
                                    // custom content of the prev/next buttons, maintains their behavior
                                    nextButtonBuilder: (context) => TextButton(
                                      onPressed: providerProduct
                                                  .paginatorController
                                                  .currentPage <
                                              providerProduct.getMaxPage() - 1
                                          ? () => {
                                                providerProduct
                                                    .paginatorController
                                                    .next()
                                              }
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
                                      onPressed: providerProduct
                                                  .paginatorController
                                                  .currentPage >
                                              0
                                          ? () => providerProduct
                                              .paginatorController
                                              .prev()
                                          : null, // _controller must be passed to NumberPaginator
                                      child: const Row(
                                        children: [
                                          Icon(Icons.chevron_left),
                                          Text("Previous"),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),

                                // this data
                                ...List.generate(
                                  (searchedList.length),
                                  (index) => ProductTile(
                                      dataProduct: searchedList[index]),
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

class ProductTile extends StatelessWidget {
  final ScreenshotController controllerPrintOrder = ScreenshotController();
  final Data dataProduct;
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
          imageUrl: dataProduct.productDetails!.productPhoto == '-'
              ? 'https://user-images.githubusercontent.com/24848110/33519396-7e56363c-d79d-11e7-969b-09782f5ccbab.png'
              : 'http://leap.crossnet.co.id:8888/file/${dataProduct.productDetails!.productPhoto!}',
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
            fontSize: fontSizeBody,
          ),
        ),
        subtitle: Text(
          '${this.dataProduct.productDetails!.productName}',
          style: TextStyle(
            color: ColorPalleteLogin.PrimaryColor,
            fontWeight: FontWeight.bold,
            fontSize: fontSizeBody,
          ),
        ),
        trailing: Column(
          children: [
            Expanded(
              child: Text(
                'Stock : ${this.dataProduct.productDetails!.productStock}',
                style: TextStyle(
                    color: ColorPalleteLogin.PrimaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: fontSizeBody),
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
                      size: 24,
                      color: ColorPalleteLogin.OrangeColor,
                    ),
                    Text(
                      'View',
                      style: TextStyle(
                          color: Colors.white, fontSize: fontSizeBody),
                    ),
                  ],
                ),
                onPressed: () {
                  // buat alert dialog
                  showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) => ProductDetailsPopup(
                      storeId: Provider.of<AuthState>(context)
                          .userData
                          .storeWarehouseId!,
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
  final Data productData;
  final int storeId;
  ProductDetailsPopup(
      {super.key, required this.storeId, required this.productData});

  @override
  State<ProductDetailsPopup> createState() => _ProductDetailsPopupState();
}

class _ProductDetailsPopupState extends State<ProductDetailsPopup> {
  var _customTileExpanded = false;
  final ScreenshotController controllerPrintOrder = ScreenshotController();
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
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
                        '${getOnlyDate(widget.productData.productDetails!.productTimestamp!)}', // harusnya pakai dd/mm/yyyy
                  ),
                  SubTitleText(
                    judul: 'Expiration Date',
                    data: '${widget.productData.productDetails!.expiryDate}',
                  ),

                  SubTitleText(
                    judul: 'Last Inventory Taking',
                    data: '${widget.productData.stockOpname!.timestamp!}',
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
                            future: _fetchProductStockOpname(
                                widget.productData.productDetails!
                                    .productDetailId!,
                                widget.storeId),
                            builder: (context, snapshot) {
                              // do something
                              if (snapshot.hasData) {
                                // jika sudah ada data
                                return Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.5,
                                    child: TableCurrentStockCardProducts(
                                        listStockCard: snapshot.data!),
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
                        Screenshot(
                          controller: controllerPrintOrder,
                          child: FutureBuilder(
                              future: _fetchProductStockCard(
                                  widget.productData.productDetails!
                                      .productDetailId!,
                                  widget.storeId),
                              builder: (context, snapshot) {
                                // do something
                                if (snapshot.hasData) {
                                  // TableStockCardProducts(listStockCard: stock.FetchStockCardProductStoreWarehouse.fromJson(jsonSpinachStockCard).data!);

                                  // jika sudah ada data
                                  return TableStockCardProducts(
                                      listStockCard: snapshot.data);
                                } else {
                                  // loading
                                  return Center(
                                      child: CircularProgressIndicator());
                                }
                              }),
                        ),
                        SizedBox(
                          height: 10,
                        ),

                        // button print table
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
                              await controllerPrintOrder
                                  .capture()
                                  .then((bytes) {
                                if (bytes != null) {
                                  // panggil woe
                                  saveImage(bytes,
                                      'StockCard-${widget.productData.productDetails!.productName}');
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
                      child: Text('${listStockCard[index].expectedStock}',
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
  final String judul;
  final String data;

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
