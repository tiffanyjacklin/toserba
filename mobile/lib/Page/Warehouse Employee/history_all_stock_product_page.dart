import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Toserba_App/Tambahan/Provider/HistoryAllProductProvider.dart';
import 'package:Toserba_App/Template.dart';
import 'package:intl/intl.dart';
import 'package:number_paginator/number_paginator.dart';
import 'package:Toserba_App/Model/StockCardProductStoreWarehouse.dart'
    as stock;
import 'package:provider/provider.dart';

class HistoryAllProductPage extends StatefulWidget {
  const HistoryAllProductPage({super.key});

  @override
  State<HistoryAllProductPage> createState() => _HistoryAllProductPageState();
}

class _HistoryAllProductPageState extends State<HistoryAllProductPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HistoryAllProductProvider(),
      child: HistoryAllStockProductPage(),
    );
  }
}

class HistoryAllStockProductPage extends StatefulWidget {
  HistoryAllStockProductPage({super.key});

  @override
  State<HistoryAllStockProductPage> createState() =>
      _HistoryAllStockProductPageState();
}

class _HistoryAllStockProductPageState
    extends State<HistoryAllStockProductPage> {
  List<stock.Data> listAllHistoryProduct = [];
  List<stock.Data> searchedHistoryProduct = [];

  // cotnroller
  // final NumberPaginatorController _controller = NumberPaginatorController();
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(context) {
    HistoryAllProductProvider provider =
        Provider.of<HistoryAllProductProvider>(context);

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
                width: MediaQuery.of(context).size.width * 0.8,
                child: TextField(
                  style: TextStyle(
                    fontSize: 18,
                  ),
                  controller: _searchController,
                  onSubmitted: (value) {
                    provider.searchItemWithFilter(_searchController.text,
                        isSearch: true);
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
                          provider.clickFilter(_searchController.text);
                        },
                        icon: Icon(Icons.filter_list)),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),

              // paginate
              provider.isFiltering
                  ? Container(
                      height: MediaQuery.of(context).size.height * 0.30,
                       width: MediaQuery.of(context).size.width *
                                    0.8 *
                                    0.98,
                      decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                          blurRadius: 4,
                                          color: Colors.grey,
                                          offset: Offset(0, 1)),
                                    ]),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(
                              height: 5,
                            ),
                            Center(
                              child: Container(
                                // height: 200
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
                                            provider.resetFilter();
                                          },
                                          child: Text(
                                            'Reset',
                                            style: TextStyle(
                                                color: ColorPalleteLogin
                                                    .OrangeDarkColor,
                                                fontSize: fontSizeBody,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),

                                      // order
                                      Text(
                                        'Reason',
                                        style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Wrap(
                                        children: List.generate(
                                            provider.descStock.length, (index) {
                                          return Container(
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 2),
                                            child: provider.descStock[index]
                                                        .stockDescription! ==
                                                    provider.descNow
                                                ? OutlinedButton(
                                                    onPressed: () {
                                                      provider.setDesc('');
                                                    },
                                                    child: Text(
                                                      provider.descStock[index]
                                                          .stockDescription!,
                                                      style: TextStyle(
                                                          fontSize:
                                                              fontSizeBody,
                                                          fontWeight:
                                                              FontWeight.bold,
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
                                                      provider.setDesc(provider
                                                          .descStock[index]
                                                          .stockDescription!);
                                                    },
                                                    child: Text(
                                                      provider.descStock[index]
                                                          .stockDescription!,
                                                      style: TextStyle(
                                                          fontSize:
                                                              fontSizeBody,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black),
                                                    ),
                                                    style: OutlinedButton.styleFrom(
                                                        side: BorderSide(
                                                            strokeAlign: 2,
                                                            color: Colors
                                                                .grey[300]!),
                                                        overlayColor:
                                                            ColorPalleteLogin
                                                                .OrangeDarkColor,
                                                        backgroundColor:
                                                            Colors.grey[300]),
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
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Wrap(
                                        children: List.generate(
                                            provider.unitType.length, (index) {
                                          return Container(
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 2),
                                            child: provider.unitType[index] ==
                                                    provider.unitNow
                                                ? OutlinedButton(
                                                    onPressed: () {
                                                      provider.setUnitType('');
                                                    },
                                                    child: Text(
                                                      provider.unitType[index],
                                                      style: TextStyle(
                                                          fontSize:
                                                              fontSizeBody,
                                                          fontWeight:
                                                              FontWeight.bold,
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
                                                      provider.setUnitType(
                                                          provider
                                                              .unitType[index]);
                                                    },
                                                    child: Text(
                                                      provider.unitType[index],
                                                      style: TextStyle(
                                                          fontSize:
                                                              fontSizeBody,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black),
                                                    ),
                                                    style: OutlinedButton.styleFrom(
                                                        side: BorderSide(
                                                            strokeAlign: 2,
                                                            color: Colors
                                                                .grey[300]!),
                                                        overlayColor:
                                                            ColorPalleteLogin
                                                                .OrangeDarkColor,
                                                        backgroundColor:
                                                            Colors.grey[300]),
                                                  ),
                                          );
                                        }),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),

                                      // time period
                                      Text(
                                        'Time Period',
                                        style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),

                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12.0),
                                        child: Wrap(
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          spacing: 10.0,
                                          children: [
                                            Text(
                                              'From',
                                              style: TextStyle(
                                                  fontSize: fontSizeBody,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            GestureDetector(
                                              onTap: () async {
                                                final DateTime? dateTime =
                                                    await showDatePicker(
                                                  context: context,
                                                  initialDate: provider
                                                      .getIsStartDate(true),
                                                  firstDate: DateTime(2000),
                                                  lastDate: DateTime.now(),
                                                );

                                                if (dateTime != null) {
                                                  provider.setRangeDate(
                                                      dateTime, true);
                                                }
                                              },
                                              child: Container(
                                                width: 160,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: Colors.black,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20.0),
                                                ),
                                                child: Center(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      children: [
                                                        Text(
                                                          '${DateFormat('dd/MM/yyyy').format(provider.getIsStartDate(true).toLocal())}',
                                                          style: TextStyle(
                                                              fontSize:
                                                                  fontSizeBody,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        Icon(
                                                          Icons
                                                              .date_range_outlined,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Text(
                                              'To',
                                              style: TextStyle(
                                                  fontSize: fontSizeBody,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            GestureDetector(
                                              onTap: () async {
                                                final DateTime? dateTime =
                                                    await showDatePicker(
                                                  context: context,
                                                  initialDate: provider
                                                      .getIsStartDate(false),
                                                  firstDate: provider
                                                      .getIsStartDate(true),
                                                  lastDate: DateTime.now(),
                                                );

                                                if (dateTime != null) {
                                                  provider.setRangeDate(
                                                      dateTime, false);
                                                }
                                              },
                                              child: Container(
                                                width: 160,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: Colors.black,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20.0),
                                                ),
                                                child: Center(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      children: [
                                                        Text(
                                                          '${DateFormat('dd/MM/yyyy').format(provider.getIsStartDate(false).toLocal())}',
                                                          style: TextStyle(
                                                              fontSize:
                                                                  fontSizeBody,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        Icon(
                                                          Icons
                                                              .date_range_outlined,
                                                        ),
                                                      ],
                                                    ),
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

                                      // Product Type
                                      Text(
                                        'Product Type',
                                        style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Wrap(
                                        children: List.generate(
                                            provider.productType.length,
                                            (index) {
                                          return Container(
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 2),
                                            child: provider.productType[index]
                                                        .productCategoryName ==
                                                    provider.typeNow
                                                ? OutlinedButton(
                                                    onPressed: () {
                                                      provider
                                                          .setProductType('');
                                                    },
                                                    child: Text(
                                                      provider
                                                          .productType[index]
                                                          .productCategoryName!,
                                                      style: TextStyle(
                                                          fontSize:
                                                              fontSizeBody,
                                                          fontWeight:
                                                              FontWeight.bold,
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
                                                      provider.setProductType(
                                                          provider
                                                              .productType[
                                                                  index]
                                                              .productCategoryName!);
                                                    },
                                                    child: Text(
                                                      provider
                                                          .productType[index]
                                                          .productCategoryName!,
                                                      style: TextStyle(
                                                          fontSize:
                                                              fontSizeBody,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black),
                                                    ),
                                                    style: OutlinedButton.styleFrom(
                                                        side: BorderSide(
                                                            strokeAlign: 2,
                                                            color: Colors
                                                                .grey[300]!),
                                                        overlayColor:
                                                            ColorPalleteLogin
                                                                .OrangeDarkColor,
                                                        backgroundColor:
                                                            Colors.grey[300]),
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
                                            // width: MediaQuery.of(context)
                                            //         .size
                                            //         .width *
                                            //     0.55 *
                                            //     0.3,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: ColorPalleteLogin
                                                    .OrangeLightColor,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20.0),
                                                ),
                                              ),
                                              child: Wrap(
                                                spacing: 12,
                                                children: [
                                                  Text(
                                                    'Apply',
                                                    style: TextStyle(
                                                      color: ColorPalleteLogin
                                                          .PrimaryColor,
                                                      fontSize: 20,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              onPressed: () {
                                                provider.clickFilter(_searchController.text);
                                              },
                                            ),
                                          ),
                                        ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                          ],
                        ),
                      ),
                    )
                  : provider.isLoading
                      ? CircularProgressIndicator()
                      : provider.resultSearched.isEmpty
                          ? Center(
                          child: Text(
                            'Data Tidak Ditemukan',
                            style: TextStyle(fontSize: fontSizeBody),
                          ),
                        )
                          : Column(
                              children: [
                                // Container(
                                //   width: MediaQuery.of(context).size.width * 0.5,
                                //   child: NumberPaginator(
                                //     controller: _controller,
                                //     initialPage: provider.currentPage,
                                //     // by default, the paginator shows numbers as center content
                                //     numberPages: (provider.totalRow.toDouble() /provider.limitPerPage.toDouble())
                                //         .ceil(),
                                //     onPageChange: (int index) {
                                //       provider.setCurrentPage(_searchController.text ,index);
                                //     },
                                //     nextButtonBuilder: (context) => TextButton(
                                //       onPressed: provider.currentPage < provider.getMaxPage()
                                //           ? () => provider.increase(_searchController.text)
                                //           : null, // _controller must be passed to NumberPaginator
                                //       child: const Row(
                                //         children: [
                                //           Text("Next"),
                                //           Icon(Icons.chevron_right),
                                //         ],
                                //       ),
                                //     ),
                                //     // custom prev/next buttons using builder (ignored if showPrevButton/showNextButton is false)
                                //     prevButtonBuilder: (context) => TextButton(
                                //       onPressed: provider.currentPage > 0
                                //           ? () => provider.decrease(_searchController.text)
                                //           : null, // _controller must be passed to NumberPaginator
                                //       child: const Row(
                                //         children: [
                                //           Icon(Icons.chevron_left),
                                //           Text("Previous"),
                                //         ],
                                //       ),
                                //     ),
                                //   ),
                                // ),

                                ListenableBuilder(
                                  listenable: provider,
                                  builder:
                                      (BuildContext context, Widget? child) {
                                    return Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.7,
                                      child: NumberPaginator(
                                        config: NumberPaginatorUIConfig(
                                          buttonSelectedForegroundColor:
                                              Colors.white,
                                          buttonUnselectedForegroundColor:
                                              Colors.black,
                                          buttonUnselectedBackgroundColor:
                                              Colors.white,
                                          buttonSelectedBackgroundColor:
                                              Colors.black,
                                          
                                        ),
                                        controller: provider.paginatorController,
                                        initialPage: provider.paginatorController.currentPage,
                                        // by default, the paginator shows numbers as center content
                                        numberPages:
                                            (provider.totalRow.toDouble() /
                                                    provider.limitPerPage
                                                        .toDouble())
                                                .ceil(),
                                        onPageChange: (int index) {},

                                        nextButtonBuilder: (context) =>
                                            TextButton(
                                          onPressed: provider.paginatorController.currentPage <
                                                  provider.getMaxPage()-1
                                              ? () => {
                                                provider.paginatorController.next()
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
                                        prevButtonBuilder: (context) =>
                                            TextButton(
                                          onPressed: provider.paginatorController.currentPage > 0
                                              ? () => {
                                                provider.paginatorController.prev()
                                                }

                                              : null, // _controller must be passed to NumberPaginator
                                          child: const Row(
                                            children: [
                                              Icon(Icons.chevron_left),
                                              Text("Previous"),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: TableStockCardAllProducts2(
                                    listStockCard: provider.listPerPage,
                                    startIndex: provider.getStartIndex(),
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

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    // _controller.dispose();
    _searchController.dispose();
  }
}

class TableStockCardAllProducts2 extends StatelessWidget {
  List<stock.Data> listStockCard = List.empty();
  final startIndex;

  TableStockCardAllProducts2({
    super.key,
    required this.listStockCard,
    required this.startIndex,
  });

  @override
  Widget build(BuildContext context) {
    return DataTable(
       border: TableBorder(
     horizontalInside: BorderSide(color: Colors.black, width: 0.7),
  ),
      columns: [
        DataColumn(
          label: Text('No.', style: TableContentTextStyle.textStyle),
        ),
        DataColumn(
          label: Text('Product Name', style: TableContentTextStyle.textStyle),
        ),
        DataColumn(
          label: Text('Batch', style: TableContentTextStyle.textStyle),
        ),
        DataColumn(
          label: Text('Expiry Date', style: TableContentTextStyle.textStyle),
        ),
        DataColumn(
          label: Text('In', style: TableContentTextStyle.textStyle),
        ),
        DataColumn(
          label: Text('Out', style: TableContentTextStyle.textStyle),
        ),
        DataColumn(
          label: Text('Unit Type', style: TableContentTextStyle.textStyle),
        ),
        DataColumn(
          label: Text('Initial Stock', style: TableContentTextStyle.textStyle),
        ),
        DataColumn(
          label: Text('Changed Stock', style: TableContentTextStyle.textStyle),
        ),
        DataColumn(
          label: Text('Current Stock', style: TableContentTextStyle.textStyle),
        ),
        DataColumn(
          label: Text('Reason', style: TableContentTextStyle.textStyle),
        ),
        DataColumn(
          label: Text('Date', style: TableContentTextStyle.textStyle),
        ),
      ],
      rows: List.generate(
        !listStockCard.isEmpty ? listStockCard.length : 0,
        (i) => DataRow(
            color: (i + 1) % 2 == 0
                ? WidgetStateColor.resolveWith(
                    (states) => ColorPalleteLogin.TableColor)
                : null,
            cells: [
              DataCell(Text(
                (startIndex + i + 1).toString(),
                style: TableContentTextStyle.textStyleBody,
              )),
              DataCell(
                Text(listStockCard[i].productName!,
                    style: TableContentTextStyle.textStyleBody),
              ),
              DataCell(
                Text(listStockCard[i].productBatch!,
                    style: TableContentTextStyle.textStyleBody),
              ),
              DataCell(
                Text(getOnlyDate(listStockCard[i].expiredDate!),
                    style: TableContentTextStyle.textStyleBody),
              ),
              DataCell(
                Text(listStockCard[i].stockIn!.toString(),
                    style: TableContentTextStyle.textStyleBody),
              ),
              DataCell(
                Text(listStockCard[i].stockOut!.toString(),
                    style: TableContentTextStyle.textStyleBody),
              ),
              DataCell(
                Text(listStockCard[i].productUnit!,
                    style: TableContentTextStyle.textStyleBody),
              ),
              DataCell(
                Center(
                    child: Text(
                        (listStockCard[i].productStock! -
                                listStockCard[i].stockIn! +
                                listStockCard[i].stockOut!)
                            .toString(),
                        style: TableContentTextStyle.textStyleBody)),
              ),
              DataCell(
                Center(
                    child: Text(listStockCard[i].productStock!.toString(),
                        style: TableContentTextStyle.textStyleBody)),
              ),
              DataCell(Center(
                child: Text(listStockCard[i].totalStock!.toString()),
              )),
              DataCell(Text(listStockCard[i].stockDescription!.toString(),
                  style: TableContentTextStyle.textStyleBody)),
              DataCell(Text(getOnlyDate(listStockCard[i].stockDate!.toString()),
                  style: TableContentTextStyle.textStyleBody)),
            ]),
      ),
    );
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
                        '${listStockCard[index + startIndex].productName}',
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
                          '${listStockCard[index + startIndex].productBatch}',
                          style: TextStyle(
                            fontSize: 14,
                          )),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        '${listStockCard[index + startIndex].expiredDate}',
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
                        listStockCard[index + startIndex].stockIn != 0
                            ? '${listStockCard[index + startIndex].stockIn}'
                            : '-',
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
                        listStockCard[index + startIndex].stockOut != 0
                            ? '${listStockCard[index + startIndex].stockOut}'
                            : '-',
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
                          '${listStockCard[index + startIndex].productUnit}',
                          style: TextStyle(
                            fontSize: 14,
                          )),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                          '${listStockCard[index + startIndex].stockDescription}',
                          style: TextStyle(
                            fontSize: 14,
                          )),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child:
                          Text('${listStockCard[index + startIndex].stockDate}',
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
