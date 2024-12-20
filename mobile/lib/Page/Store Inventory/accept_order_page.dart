import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Toserba_App/Model/DeliveryOrderStore.dart' as deliveryStore;
import 'package:Toserba_App/Tambahan/Provider/AcceptOrderDelivery.dart';
import 'package:Toserba_App/Tambahan/Provider/AcceptOrderProvider.dart';
import 'package:Toserba_App/Tambahan/Provider/Auth.dart';
import 'package:Toserba_App/Template.dart';
import 'package:Toserba_App/Page/Store%20Inventory/accept_order_popup_page.dart';
import 'package:intl/intl.dart';
import 'package:number_paginator/number_paginator.dart';
import 'package:provider/provider.dart';
import 'package:stroke_text/stroke_text.dart';

class AcceptOrderPage2 extends StatelessWidget {
  const AcceptOrderPage2({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AcceptOrderProvider(
          context.read<AuthState>().userData.storeWarehouseId!),
      child: AcceptOrderPage(),
    );
  }
}

class AcceptOrderPage extends StatefulWidget {
  AcceptOrderPage({super.key});

  @override
  State<AcceptOrderPage> createState() => _AcceptOrderPageState();
}

class _AcceptOrderPageState extends State<AcceptOrderPage> {
  final NumberPaginatorController _controller = NumberPaginatorController();
  TextEditingController _searchController = TextEditingController();
  // var _currentPage = 1;

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AcceptOrderProvider>(context);
    // List<deliveryStore.Data> listPerPage = provider.listPerPage;
    provider.currentPage = _controller.currentPage;

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
              TitlePage(name: 'Accept Order'),
              SizedBox(
                height: 20,
              ),
              // search bar
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: TextField(
                  style: TextStyle(
                    fontSize: 18,
                  ),
                  controller: _searchController,
                  onSubmitted: (value) {
                    provider.filter(_searchController.text);
                    _controller.currentPage = 0;
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
                          provider.isFiltering = !provider.isFiltering;
                          provider.filter(_searchController.text);
                          _controller.currentPage = 0;
                        },
                        icon: Icon(Icons.filter_list)),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),

              SizedBox(
                height: 20,
              ),

              // pagination nya
              provider.isLoading
                  ? CircularProgressIndicator()
                  : provider.isFiltering
                      ? Container(
                          height: 350,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 5,
                                ),
                                Center(
                                  child: Container(
                                    // height: 200,
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
                                                provider.resetFilter();
                                              },
                                              child: Text(
                                                'Reset',
                                                style: TextStyle(
                                                    color: ColorPalleteLogin
                                                        .OrangeDarkColor,
                                                    fontSize: fontSizeBody,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),

                                          // Status
                                          Text(
                                            'Status',
                                            style: TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Wrap(
                                            children: List.generate(
                                                provider.listChecked.keys
                                                    .length, (index) {
                                              return Container(
                                                margin: EdgeInsets.symmetric(
                                                    horizontal: 2),
                                                child: provider.listChecked.keys
                                                            .toList()[index] ==
                                                        provider
                                                            .listChecked.keys
                                                            .firstWhere(
                                                                (k) =>
                                                                    provider
                                                                        .listChecked[
                                                                            k]
                                                                        .toString() ==
                                                                    provider
                                                                        .checkStatus,
                                                                orElse: () =>
                                                                    '')
                                                    ? OutlinedButton(
                                                        onPressed: () {
                                                          provider
                                                              .setCheckStatus(
                                                                  '');
                                                        },
                                                        child: Text(
                                                          provider
                                                              .listChecked.keys
                                                              .toList()[index],
                                                          style: TextStyle(
                                                              fontSize:
                                                                  fontSizeBody,
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
                                                          provider.setCheckStatus(
                                                              provider.listChecked
                                                                      .keys
                                                                      .toList()[
                                                                  index]);
                                                        },
                                                        child: Text(
                                                          provider
                                                              .listChecked.keys
                                                              .toList()[index],
                                                          style: TextStyle(
                                                              fontSize:
                                                                  fontSizeBody,
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
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                GestureDetector(
                                                  onTap: () async {
                                                    final DateTime? dateTime =
                                                        await showDatePicker(
                                                      context: context,
                                                      initialDate: provider
                                                          .rangeDate.first,
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
                                                            const EdgeInsets
                                                                .all(10.0),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceEvenly,
                                                          children: [
                                                            Text(
                                                              '${DateFormat('dd/MM/yyyy').format(provider.rangeDate.first.toLocal())}',
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
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                GestureDetector(
                                                  onTap: () async {
                                                    final DateTime? dateTime =
                                                        await showDatePicker(
                                                      context: context,
                                                      initialDate: provider
                                                          .rangeDate.last,
                                                      firstDate: provider
                                                          .rangeDate.last,
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
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceEvenly,
                                                          children: [
                                                            Text(
                                                              '${DateFormat('dd/MM/yyyy').format(provider.rangeDate.last.toLocal())}',
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
                                                  provider.isFiltering = !provider.isFiltering;
                                                  provider.filter(
                                                      _searchController.text);
                                                  _controller.currentPage = 0;
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
                      : provider.items.isEmpty
                          ? Container(
                              child: Text('No Data'),
                            )
                          : ListenableBuilder(
                              listenable: provider,
                              builder: (BuildContext context, Widget? child) {
                                return Column(children: [
                                  Container(
                                    width: MediaQuery.of(context).size.width * 0.70 > 400 ? MediaQuery.of(context).size.width * 0.70 : 400,
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
                                      numberPages: provider.getMaxPage(),
                                      onPageChange: (int index) {},
                                      controller: _controller,

                                      // show/hide the prev/next buttons
                                      showPrevButton: true,
                                      showNextButton: true, // defaults to true
                                      // custom content of the prev/next buttons, maintains their behavior
                                      nextButtonBuilder: (context) =>
                                          TextButton(
                                        onPressed: _controller.currentPage <
                                                provider.getMaxPage() - 1
                                            ? () => {_controller.next()}
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
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),

                                  // with api run
                                  Container(
                                    height: 400,
                                    width: MediaQuery.of(context).size.width * 0.70 > 400 ? MediaQuery.of(context).size.width * 0.70 : 400,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: provider.listPerPage.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return DeliveryOrderChild(
                                            data: provider.listPerPage[index]);
                                      },
                                    ),
                                  ),
                                ]);
                              }),
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
    _controller.dispose();
  }
}

class DeliveryOrderChild extends StatelessWidget {
  final deliveryStore.Data data;

  DeliveryOrderChild({
    required this.data,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AcceptOrderProvider>(context);
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.70,
          height: 88,
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
              isPhone() ? SizedBox() : Expanded(
                flex: 1,
                child: Icon(
                  Icons.insert_drive_file_outlined,
                  size: 40,
                ),
              ),
          
              // center
              Expanded(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Delivery Order ${data.deliveryOrderId}',
                        style: TextStyle(
                          color: ColorPalleteLogin.PrimaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: fontSizeBody,
                        ),
                      ),
                      Text(
                        getDateWithTime(data.orderTimestamp!),
                        style: TextStyle(
                          color: ColorPalleteLogin.PrimaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: fontSizeBody,
                        ),
                      ),
                            
                      // cek status accepted
                      data.statusAccept == 0
                          ? StrokeText(
                              text: 'Unchecked !!',
                              textStyle: TextStyle(
                                color: ColorPalleteLogin.OrangeLightColor,
                                fontWeight: FontWeight.bold,
                                fontSize: fontSizeBody,
                              ),
                            )
                          : Text(
                              'Checked',
                              style: TextStyle(
                                color: ColorPalleteLogin.PrimaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: fontSizeBody,
                              ),
                            ),
                    ],
                  ),
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
                        builder: (context) => PopScope(
                            onPopInvokedWithResult: (didPop, result) {
                              if (didPop) {
                                if (result.toString().isNotEmpty &&
                                    result.toString().toLowerCase() != 'null') {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: result.toString() == 'Berhasil' ? Colors.green[400] : Colors.red[400] ,
                                      content: Text(
                                        '${result.toString()}',
                                        style:
                                            TableContentTextStyle.textStyleBody,
                                      ),
                                    ),
                                  );
                                  provider.refresh();
                                }
                              }
                            },
                            child: MultiProvider(
                              providers: [
                                ChangeNotifierProvider(
                                  create: (context) =>
                                      AcceptOrderDeliveryProvider(
                                          data.deliveryOrderId!,
                                          data.statusAccept == 0
                                              ? false
                                              : true),
                                ),
                              ],
                              child:
                                  DeliveryOrderDetailPopUp(dataDelivery: data),
                            )));
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
