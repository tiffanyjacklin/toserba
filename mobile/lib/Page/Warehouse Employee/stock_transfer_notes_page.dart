import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Toserba_App/FetchApi/TransferNote+Delivery.dart';
import 'package:Toserba_App/Model/DeliveryTransferDetail.dart'
    as deliveryDetail;
import 'package:Toserba_App/Model/DeliveryTransferNote.dart'
    as deliveryTrasnfer;
import 'package:Toserba_App/Model/StockTransferNotesWarehouse.dart'
    as transfer;
import 'package:Toserba_App/TableTemplate/TableSuratJalan.dart';
import 'package:Toserba_App/Tambahan/Provider/Auth.dart';
import 'package:Toserba_App/Tambahan/Provider/ProductTruckCart.dart';
import 'package:Toserba_App/Tambahan/Provider/TransferNotesProvider.dart';
import 'package:Toserba_App/Template.dart';
import 'package:intl/intl.dart';
import 'package:number_paginator/number_paginator.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:stroke_text/stroke_text.dart';
import 'package:Toserba_App/Model/StockCardProductStoreWarehouse.dart'
    as stock;

class TransferNotesPage extends StatelessWidget {
  const TransferNotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TransferNotesProvider(
          context.read<AuthState>().userData.storeWarehouseId!),
      child: StockTransferNotesPage(),
    );
  }
}

class StockTransferNotesPage extends StatefulWidget {
  StockTransferNotesPage({super.key});

  @override
  State<StockTransferNotesPage> createState() => _StockTransferNotesPageState();
}

class _StockTransferNotesPageState extends State<StockTransferNotesPage> {
  TextEditingController controllerSearch = TextEditingController();

  @override
  Widget build(BuildContext context) {
    TransferNotesProvider provider =
        Provider.of<TransferNotesProvider>(context);
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
              Text('Stock Transfer Notes',
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
                width: MediaQuery.of(context).size.width * 0.8,
                child: TextField(
                  style: TextStyle(
                    fontSize: fontSizeBody,
                  ),
                  controller: controllerSearch,
                  onSubmitted: (value) {
                    provider.fetchTransferNotes(
                        context.read<AuthState>().userData.storeWarehouseId!,
                        search: controllerSearch.text,
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
                          provider.clickFilter(
                              context
                                  .read<AuthState>()
                                  .userData
                                  .storeWarehouseId!,
                              controllerSearch.text);
                        },
                        icon: Icon(Icons.filter_list)),
                  ),
                ),
              ),

              SizedBox(
                height: 20,
              ),

              // paginate
              provider.isFiltering
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
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),

                                      // order
                                      Text(
                                        'Status Verified',
                                        style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Wrap(
                                        children: List.generate(
                                            provider.listStatusVerify.length,
                                            (index) {
                                          return Container(
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 2),
                                            child: provider.listStatusVerify[
                                                        index] ==
                                                    provider.statusVerify
                                                ? OutlinedButton(
                                                    onPressed: () {
                                                      provider.statusVerify =
                                                          '';
                                                    },
                                                    child: Text(
                                                      provider.listStatusVerify[
                                                          index],
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
                                                      provider
                                                          .statusVerify = provider
                                                              .listStatusVerify[
                                                          index];
                                                    },
                                                    child: Text(
                                                      provider.listStatusVerify[
                                                          index],
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
                                        'Status Send',
                                        style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Wrap(
                                        children: List.generate(
                                            provider.listStatusSend.length,
                                            (index) {
                                          return Container(
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 2),
                                            child: provider.listStatusSend[
                                                        index] ==
                                                    provider.statusSend
                                                ? OutlinedButton(
                                                    onPressed: () {
                                                      provider.statusSend = '';
                                                    },
                                                    child: Text(
                                                      provider.listStatusSend[
                                                          index],
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
                                                      provider
                                                          .statusSend = provider
                                                              .listStatusSend[
                                                          index];
                                                    },
                                                    child: Text(
                                                      provider.listStatusSend[
                                                          index],
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
                                                  initialDate:
                                                      provider.rangeDate.first,
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
                                                            8.0),
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
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            GestureDetector(
                                              onTap: () async {
                                                final DateTime? dateTime =
                                                    await showDatePicker(
                                                  context: context,
                                                  initialDate:
                                                      provider.rangeDate.last,
                                                  firstDate:
                                                      provider.rangeDate.first,
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
                  : provider.getItemPerPage().isEmpty
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
                              width: MediaQuery.of(context).size.width * 0.70,
                              child: NumberPaginator(
                                config: NumberPaginatorUIConfig(
                                  buttonUnselectedForegroundColor: Colors.black,
                                  buttonSelectedBackgroundColor: Colors.black,
                                  buttonSelectedForegroundColor: Colors.white,
                                ),
                                // by default, the paginator shows numbers as center content
                                numberPages: provider.getMaxPage(),
                                onPageChange: (int index) {},
                                controller: provider.paginatorController,

                                // show/hide the prev/next buttons
                                showPrevButton: true,
                                showNextButton: true, // defaults to true
                                // custom content of the prev/next buttons, maintains their behavior
                                nextButtonBuilder: (context) => TextButton(
                                  onPressed: provider
                                              .paginatorController.currentPage <
                                          provider.getMaxPage() - 1
                                      ? () =>
                                          {
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
                                prevButtonBuilder: (context) => TextButton(
                                  onPressed: provider
                                              .paginatorController.currentPage >
                                          0
                                      ? () =>
                                          provider.paginatorController.prev()
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

                            // data
                            ListView.builder(
                              shrinkWrap: true,
                              itemCount: provider.getItemPerPage().length,
                              itemBuilder: (BuildContext context, int index) {
                                return StockTransferNotesChild(
                                  dataStockTransfer:
                                      provider.getItemPerPage()[index],
                                );
                              },
                            ),
                          ],
                        ),

              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StockTransferNotesChild extends StatelessWidget {
  final transfer.Data dataStockTransfer;
  StockTransferNotesChild({
    required this.dataStockTransfer,
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
                      'Stock Trasfer Note ${dataStockTransfer.transferNoteId}',
                      style: TextStyle(
                        color: ColorPalleteLogin.PrimaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: fontSizeBody,
                      ),
                    ),
                    Text(
                      getDateWithTime(dataStockTransfer.createdAt!),
                      style: TextStyle(
                        color: ColorPalleteLogin.PrimaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: fontSizeBody,
                      ),
                    ),

                    // NOTE : Perbaiki ini
                    dataStockTransfer.statusVerify == 0
                        ? Text(
                            'Not Verified',
                            style: TextStyle(
                              color: ColorPalleteLogin.PrimaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: fontSizeBody,
                            ),
                          )
                        : Row(
                            children: [
                              Text(
                            'Verified, ',
                            style: TextStyle(
                              color: ColorPalleteLogin.OrangeDarkColor,
                              fontWeight: FontWeight.bold,
                              fontSize: fontSizeBody,
                            ),
                          ),
                          
                              dataStockTransfer.statusSend == 0
                                  ?  Text(
                            'Not Sent. ',
                            style: TextStyle(
                              color: ColorPalleteLogin.PrimaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: fontSizeBody,
                            ),
                          )
                                  :  Text(
                            'Sent. ',
                            style: TextStyle(
                              color: ColorPalleteLogin.OrangeDarkColor,
                              fontWeight: FontWeight.bold,
                              fontSize: fontSizeBody,
                            ),
                          )
                            ],
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
                      builder: (context) => StockTransferNotePopup(
                        userData: context.read<AuthState>().userData,
                        dataTransferNote: dataStockTransfer,
                      ),
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

class CreateDeliveryOrderPopup extends StatefulWidget {
  final int noteId;
  final controllerAdditional = TextEditingController();

  // list buat simpan table yg ada
  // List<transferDetail.Data> listProductTruck = [];

  CreateDeliveryOrderPopup({required this.noteId, super.key});

  @override
  State<CreateDeliveryOrderPopup> createState() =>
      _CreateDeliveryOrderPopupState();
}

class _CreateDeliveryOrderPopupState extends State<CreateDeliveryOrderPopup> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final productTruckCartProvider =
        Provider.of<ProductTruckCartProvider>(context);

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.75,
        decoration: BoxDecoration(
          color: ColorPalleteLogin.PrimaryColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [],
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
                  Center(child: TableTitlePage(name: 'Create Delivery Order')),
                  SizedBox(
                    height: 20,
                  ),
                  SubTitleText(
                    judul: 'Products Loaded on Truck',
                    isColumn: false,
                  ),
                  TableInputProductLoaded(),
                  SizedBox(
                    height: 10,
                  ),
                  SubTitleText(
                    judul: 'Additional Note',
                    isColumn: false,
                  ),
                  TextField(
                    keyboardType: TextInputType.multiline,
                    controller: widget.controllerAdditional,
                    minLines: 3,
                    maxLines: 3,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontSize: 16,
                        color: ColorPalleteLogin.PrimaryColor,
                        fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(10.0),
                      isDense: true,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(15.0),
                        ),
                        borderSide: new BorderSide(
                          color: Colors.black,
                          width: 1.0,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    // height: 50,
                    width: MediaQuery.of(context).size.width * 0.55 * 0.25,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorPalleteLogin.OrangeLightColor,
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
                              Icons.repeat,
                              color: ColorPalleteLogin.PrimaryColor,
                            ),
                            Text(
                              'Reset',
                              style: TextStyle(
                                color: ColorPalleteLogin.PrimaryColor,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      onPressed: () {
                        productTruckCartProvider
                            .resetCartDefault(widget.noteId);
                      },
                    ),
                  ),
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
                                      color:
                                          ColorPalleteLogin.OrangeLightColor)),
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
                        width: 30,
                      ),
                      !productTruckCartProvider.isEmptyCart
                          ? Center(
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
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                  ),
                                  child: Wrap(
                                    spacing: 12,
                                    children: [
                                      Text(
                                        'Confirm',
                                        style: TextStyle(
                                          color: ColorPalleteLogin.PrimaryColor,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  onPressed: () {
                                    // Note: GANTI (UDAH)
                                    // cek misal semua udah di isi maka next
                                    if (!productTruckCartProvider
                                        .isThereEmptyField()) {
                                      // jalankan cart submit
                                      productTruckCartProvider
                                          .submit(
                                              widget.controllerAdditional.text)
                                          .then((onValue) {
                                        Navigator.pop(context);
                                      });
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          backgroundColor: Colors.red[400],
                                          content: Text(
                                            'Terdapat Input Barang yang belum terisi',
                                            style: TableContentTextStyle
                                                .textStyleBody,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                            )
                          : Container(),
                    ],
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

class TableInputProductLoaded extends StatefulWidget {
  // List<transferDetail.Data> listItem;
  TableInputProductLoaded({
    // required this.listItem,
    super.key,
  });

  @override
  State<TableInputProductLoaded> createState() =>
      _TableInputProductLoadedState();
}

class _TableInputProductLoadedState extends State<TableInputProductLoaded> {
  @override
  Widget build(BuildContext context) {
    final listItem = context.select((ProductTruckCartProvider i) => i.items);
    final listController =
        context.select((ProductTruckCartProvider i) => i.listControllerInput);

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
            2: FlexColumnWidth(2),
            3: FlexColumnWidth(3),
            4: FlexColumnWidth(2),
            5: FlexColumnWidth(3),
            6: FlexColumnWidth(4),
            7: FlexColumnWidth(2),
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
                    child: Text('NO', style: TableContentTextStyle.textStyle),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Product name',
                        style: TableContentTextStyle.textStyle),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Requested',
                        style: TableContentTextStyle.textStyle),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Loaded',
                      style: TableContentTextStyle.textStyle,
                    ),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Unit Type',
                        style: TableContentTextStyle.textStyle),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child:
                        Text('Batch', style: TableContentTextStyle.textStyle),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Expire Date',
                        style: TableContentTextStyle.textStyle),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Action',
                      style: TableContentTextStyle.textStyle,
                    ),
                  ),
                ),
              ],
            ),

            // making the content
            ...List.generate(
              listItem.length,
              (index) {
                var tableRow = TableRow(
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
                          '${index + 1}',
                          style: TableContentTextStyle.textStyleBody,
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('${listItem[index].productName}',
                            style: TableContentTextStyle.textStyleBody),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('${listItem[index].remainingQuantity}',
                            style: TableContentTextStyle.textStyleBody),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                          padding: EdgeInsets.all(8.0),
                          // >> note : BELUM DI LIMIT
                          child: TextField(
                            controller: listController[index],
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
                                  const Radius.circular(18.0),
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
                        child: Text('${listItem[index].unitType}',
                            style: TableContentTextStyle.textStyleBody),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('${listItem[index].batch}',
                            style: TableContentTextStyle.textStyleBody),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(getOnlyDate(listItem[index].expiredDate!),
                            style: TableContentTextStyle.textStyleBody),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () => {
                            // NOTE : HAPUS INI DARI TABLE
                            context
                                .read<ProductTruckCartProvider>()
                                .remove(index)
                          },
                          child: Icon(Icons.delete),
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

class StockTransferNotePopup extends StatefulWidget {
  final transfer.Data dataTransferNote;
  final userData;

  StockTransferNotePopup({
    required this.dataTransferNote,
    required this.userData,
    super.key,
  });

  @override
  State<StockTransferNotePopup> createState() => _StockTransferNotePopupState();
}

class _StockTransferNotePopupState extends State<StockTransferNotePopup> {
  // var _customTileExpanded = false;
  var isFormNotCreated = true;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.75,
        decoration: BoxDecoration(
          color: ColorPalleteLogin.PrimaryColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            // BoxShadow(
            //   color: ColorPalleteLogin.OrangeColor,
            //   offset: Offset(0, 6),
            // ),
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
                      child:
                          TableTitlePage(name: 'Stock Transfer Note Detail')),
                  SizedBox(
                    height: 20,
                  ),

                  SubTitleText(
                    judul: 'Stock Transfer Note ID',
                    data: '${widget.dataTransferNote.transferNoteId}',
                  ),
                  SubTitleText(
                    judul: 'Created at',
                    data: getTimeWithDate(widget.dataTransferNote
                        .createdAt!), // '07:31 PM, 01 July 2024',
                  ),

                  SizedBox(
                    height: 20,
                  ),

                  // if di klik createnya (perlu set function buat dia jadi true)

                  // NOTE : perlu check misal dia ada delivery order yg sudah dikirim
                  // delivery order
                  widget.dataTransferNote.statusVerify != 0
                      ? SubTitleText(
                          judul: 'Delivery Order',
                          isColumn: false,
                        )
                      : Container(),

                  // NOTE : pisah
                  // Misal sudah ada delivery order sebelumnya
                  // buat format 1
                  // DeliveryOrderView(dataDelivery: dataDelivery),
                  widget.dataTransferNote.statusVerify != 0
                      ? FutureBuilder<List<deliveryTrasnfer.Data>>(
                          future: fetchDeliveryTransferNotes(
                              widget.dataTransferNote.transferNoteId!),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              // get error
                              if (snapshot.hasError) {
                                return Center(
                                  child: Text('error fetch'),
                                );
                              } else {
                                return Column(
                                  children: List.generate(
                                      snapshot.data!.length,
                                      (index) => DeliveryOrderView(
                                            dataDelivery: snapshot.data![index],
                                            total: widget.dataTransferNote
                                                .quantityTotal!,
                                          )),
                                );
                              }
                            } else {
                              return CircularProgressIndicator();
                            }
                          })
                      : Container(),

                  // product loaded on truck
                  widget.dataTransferNote.statusVerify != 0
                      ? Column(
                          children: [
                            widget.dataTransferNote.statusSend == 0
                                ? Container(
                                    // height: 50,
                                    width: MediaQuery.of(context).size.width *
                                        0.55 *
                                        0.45,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            ColorPalleteLogin.OrangeLightColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                      ),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Wrap(
                                          spacing: 6,
                                          children: [
                                            Text(
                                              '+ Create Delivery Order',
                                              style: TextStyle(
                                                color: ColorPalleteLogin
                                                    .PrimaryColor,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      onPressed: () {
                                        // new popup
                                        showDialog(
                                          context: context,
                                          builder: (context) =>
                                              ChangeNotifierProvider(
                                            create: (context) =>
                                                ProductTruckCartProvider(
                                                    widget.dataTransferNote
                                                        .transferNoteId!,
                                                    widget.userData),
                                            child: Scaffold(
                                              backgroundColor:
                                                  Colors.transparent,
                                              body: CreateDeliveryOrderPopup(
                                                  noteId: widget
                                                      .dataTransferNote!
                                                      .transferNoteId!),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                : Container(),
                            SizedBox(
                              height: 20,
                            ),
                          ],
                        )
                      : Column(),

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
                                      color:
                                          ColorPalleteLogin.OrangeLightColor)),
                            ),
                            child: Wrap(
                              spacing: 12,
                              children: [
                                Text(
                                  'Close',
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
                        width: 30,
                      ),
                    ],
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

class DeliveryOrderView extends StatefulWidget {
  final deliveryTrasnfer.Data dataDelivery;
  final int total;
  DeliveryOrderView({
    required this.dataDelivery,
    required this.total,
    super.key,
  });

  final ScreenshotController controllerPrintOrder = ScreenshotController();
  var isOpen = false;

  @override
  State<DeliveryOrderView> createState() => _DeliveryOrderViewState();
}

class _DeliveryOrderViewState extends State<DeliveryOrderView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 70,
          width: MediaQuery.of(context).size.width * 0.7,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BodyPage(name: '${widget.dataDelivery.deliveryOrderId}'),
                BodyPage(name: '${widget.dataDelivery.orderTimestamp}'),
                BodyPage(
                    name:
                        '${widget.dataDelivery.quantityTotal} loaded'),
                Container(
                    decoration: BoxDecoration(
                      color: ColorPalleteLogin.OrangeLightColor,
                      borderRadius: BorderRadius.circular(15.0),
                      border: Border.all(),
                    ),
                    child: IconButton(
                        onPressed: () {
                          setState(() {
                            widget.isOpen = !widget.isOpen;
                          });
                        },
                        icon: Icon(
                          Icons.remove_red_eye_outlined,
                        ))),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),

        // munculin surat jalan yang ada hehe
        // nota delivery nya
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: !widget.isOpen
              ? []
              : [
                  Screenshot(
                    controller: widget.controllerPrintOrder,
                    child: FutureBuilder<List<deliveryDetail.Data>>(
                        future: fetchDeliveryTransferNotesDetail(
                            widget.dataDelivery.deliveryOrderId!),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            // get error
                            if (snapshot.hasError) {
                              return Center(
                                child: Text('error fetch'),
                              );
                            } else {
                              return NoteDeliveryOrder(
                                listItemDelivery: snapshot.data!,
                                additionalNote: widget.dataDelivery.notes!,
                              );
                            }
                          } else {
                            return CircularProgressIndicator();
                          }
                        }),
                  ),

                  SizedBox(
                    height: 10,
                  ),

                  // button print table
                  Container(
                    // height: 50,
                    width: MediaQuery.of(context).size.width * 0.55 * 0.45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorPalleteLogin.OrangeLightColor,
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
                              'Print delivery order',
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
                        await widget.controllerPrintOrder
                            .capture()
                            .then((bytes) {
                          if (bytes != null) {
                            // panggil woe
                            saveImage(bytes, 'DeliveryOrder');
                            // saveAndShare(bytes, 'DeliveryOrder');
                          }
                        }).catchError((onError) {
                          debugPrint(onError);
                        });
                      },
                    ),
                  ),
                ],
        ),
        SizedBox(
          height: 20,
        )
      ],
    );
  }
}

// List<TableRow> ListRowTableInputProductLoaded {
//   int count;
//   // var listdata

//   ListRowTableInputProductLoaded({required count});

// }

class TableStockCardTransferNotes extends StatelessWidget {
  List<stock.Data> listStockCard = List.empty();
  TableStockCardTransferNotes({
    required this.listStockCard,
    super.key,
  });

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
            4: FlexColumnWidth(2),
            5: FlexColumnWidth(3),
            6: FlexColumnWidth(4),
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
                    child: Text('Product name',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'In',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Out',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Unit Type',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Batch Number',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Expire Date',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),

            // making the content
            ...List.generate(
              10,
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
                      child: Text('Nama Produk',
                          style: TextStyle(
                            fontSize: 14,
                          )),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        '-',
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
                        '10000',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Unit',
                          style: TextStyle(
                            fontSize: 14,
                          )),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('123456789',
                          style: TextStyle(
                            fontSize: 14,
                          )),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('10/10/2024',
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
