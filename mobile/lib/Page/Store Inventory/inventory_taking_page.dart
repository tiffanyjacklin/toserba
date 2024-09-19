import 'dart:convert';
// import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_all/Model/StockOpname.dart';
import 'package:flutter_app_all/Tambahan/Provider/InventoryTakingProvider.dart';
import 'package:flutter_app_all/Template.dart';
import 'package:intl/intl.dart';
import 'package:number_paginator/number_paginator.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class InventoryTakingPageWithProvider extends StatefulWidget {
  const InventoryTakingPageWithProvider({super.key});

  @override
  State<InventoryTakingPageWithProvider> createState() =>
      _InventoryTakingPageWithProviderState();
}

class _InventoryTakingPageWithProviderState
    extends State<InventoryTakingPageWithProvider> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => InventoryTakingProvider(),
      child: InventoryTakingPage(),
    );
  }
}

class InventoryTakingPage extends StatefulWidget {
  InventoryTakingPage({super.key});

  @override
  State<InventoryTakingPage> createState() => _InventoryTakingPageState();
}

class _InventoryTakingPageState extends State<InventoryTakingPage> {
  // final NumberPaginatorController _controller = NumberPaginatorController();
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final providerInventory = Provider.of<InventoryTakingProvider>(context);

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
              left: 20.0, right: 20.0, top: 16.0, bottom: 8.0),
          child: Column(
            children: [
              TitlePage(name: 'Inventory Taking'),
              SizedBox(
                height: 10,
              ),

              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: TextField(
                  style: TextStyle(
                    fontSize: 18,
                  ),
                  controller: _searchController,
                  onSubmitted: (value) {
                    providerInventory
                        .searchItemWithFilter(_searchController.text, search: true);
                    providerInventory.changeControllerQtyValue();
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
                          providerInventory.clickFilter(_searchController.text);
                        },
                        icon: Icon(Icons.filter_list)),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
      
              providerInventory.isFiltering ?  
              Container(
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
                                    offset: Offset(0,1)
                                  ),
                                ]
                              ),
                              width: MediaQuery.of(context).size.width * 0.8 * 0.98,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: GestureDetector(
                                        onTap: () {
                                          providerInventory.resetFilter();
                                        },
                                        child: Text(
                                          'Reset',
                                          style: TextStyle(
                                              color:
                                                  ColorPalleteLogin.OrangeDarkColor,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
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
                                          providerInventory.productOrder.length, (index) {
                                        return Container(
                                          margin:
                                              EdgeInsets.symmetric(horizontal: 2),
                                          child: providerInventory.filterProduct == providerInventory.productOrder[index].sortType
                                              ? OutlinedButton(
                                                  onPressed: () {
                                                    providerInventory.setFilterProduct('');
                                                  },
                                                  child: Text(
                                                    providerInventory.productOrder[index].sortType!,
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.bold,
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
                                                    providerInventory.setFilterProduct(
                                                        providerInventory
                                                            .productOrder[index].sortType!);
                                                  },
                                                  child: Text(
                                                    providerInventory.productOrder[index].sortType!,
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.black),
                                                  ),
                                                  style: OutlinedButton.styleFrom(
                                                      side: BorderSide(
                                                          strokeAlign: 2,
                                                          color: Colors.grey[300]!),
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
                                          providerInventory.ascDec.length, (index) {
                                        return Container(
                                          margin:
                                              EdgeInsets.symmetric(horizontal: 2),
                                          child: providerInventory.ascDec[index] ==
                                                  providerInventory.ascDecNow
                                              ? OutlinedButton(
                                                  onPressed: () {},
                                                  child: Text(
                                                    providerInventory.ascDec[index],
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.bold,
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
                                                    providerInventory.setAcs(
                                                        providerInventory.ascDec[index]);
                                                  },
                                                  child: Text(
                                                    providerInventory.ascDec[index],
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.black),
                                                  ),
                                                  style: OutlinedButton.styleFrom(
                                                      side: BorderSide(
                                                          strokeAlign: 2,
                                                          color: Colors.grey[300]!),
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
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Wrap(
                                      spacing: 10,
                                      children: List.generate(
                                          providerInventory.unitType.length, (index) {
                                        return Container(
                                          margin:
                                              EdgeInsets.symmetric(horizontal: 2),
                                          child: providerInventory.unitType[index] ==
                                                  providerInventory.unitNow
                                              ? OutlinedButton(
                                                  onPressed: () {
                                                    providerInventory.setUnitType('');
                                                  },
                                                  child: Text(
                                                    providerInventory.unitType[index],
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.bold,
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
                                                    providerInventory.setUnitType(
                                                        providerInventory.unitType[index]);
                                                  },
                                                  child: Text(
                                                    providerInventory.unitType[index],
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.black),
                                                  ),
                                                  style: OutlinedButton.styleFrom(
                                                      side: BorderSide(
                                                          strokeAlign: 2,
                                                          color: Colors.grey[300]!),
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
                                          providerInventory.productType.length, (index) {
                                        return Container(
                                          margin:
                                              EdgeInsets.symmetric(horizontal: 2),
                                          child: providerInventory.productType[index].productCategoryName == providerInventory.typeNow
                                              ? OutlinedButton(
                                                  onPressed: () {
                                                    providerInventory.setProductType('');
                                                  },
                                                  child: Text(
                                                    providerInventory.productType[index].productCategoryName!,
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.bold,
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
                                                    providerInventory.setProductType(
                                                        providerInventory.productType[index].productCategoryName!);
                                                  },
                                                  child: Text(
                                                    providerInventory.productType[index].productCategoryName!,
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.black),
                                                  ),
                                                  style: OutlinedButton.styleFrom(
                                                      side: BorderSide(
                                                          strokeAlign: 2,
                                                          color: Colors.grey[300]!),
                                                      overlayColor:
                                                          ColorPalleteLogin
                                                              .OrangeDarkColor,
                                                      backgroundColor:
                                                          Colors.grey[300]),
                                                ),
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10,),
                        ],
                      ),
                ),
              )
              
              // for submited form
              : providerInventory.isLoading
                  ? CircularProgressIndicator()
                  : providerInventory.resultSearched.isEmpty
                      ? Text(
                          'Data Tidak Ditemukan',
                          style: notFoundData,
                        )
                      : Column(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.7,
                              child: NumberPaginator(
                                controller:
                                    providerInventory.paginatorController,
                                // by default, the paginator shows numbers as center content
                                numberPages: providerInventory.getMaxPage(),
                                onPageChange: (int index) {
                                  // providerInventory.currentPage = index;
                                  providerInventory
                                      .checkControllerPageChanges(_searchController.text); // BUG / POTENTIAL ERROR (maybe)
                                },

                                showPrevButton: true,
                                showNextButton: true, // defaults to true
                                nextButtonBuilder: (context) => TextButton(
                                  onPressed: providerInventory.currentPage <
                                          providerInventory.getMaxPage() - 1
                                      ? () => providerInventory.currentPage++
                                      : null,
                                  child: const Row(
                                    children: [
                                      Text("Next"),
                                      Icon(Icons.chevron_right),
                                    ],
                                  ),
                                ),
                                // custom prev/next buttons using builder (ignored if showPrevButton/showNextButton is false)
                                prevButtonBuilder: (context) => TextButton(
                                  onPressed: providerInventory.currentPage > 0
                                      ? () => providerInventory.currentPage--
                                      : null,
                                  child: const Row(
                                    children: [
                                      Icon(Icons.chevron_left),
                                      Text("Previous"),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            TableInventoryTaking(
                              startIndex: providerInventory.getStartIndex(),
                              contentTable: providerInventory.listPerPage,
                            ),
                          ],
                        ),

              SizedBox(
                height: 20,
              ),

              // Action Button
              providerInventory.isFiltering ? Row() : Row(
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
                          ),
                        ),
                        child: Wrap(
                          spacing: 12,
                          children: [
                            Text(
                              'Discard',
                              style: TextStyle(
                                color: ColorPalleteLogin.OrangeColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        onPressed: () async {
                          // BELUM COBA
                          // keluarin popup discard
                          var data = await showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (context) => DiscardPopup(),
                          );

                          // BELUM COBA
                          if(data == true){
                            providerInventory.resetAll();
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  Center(
                    child: Container(
                      height: 50,
                      width: MediaQuery.of(context).size.width * 0.55 * 0.3,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorPalleteLogin.OrangeDarkColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        child: Wrap(
                          spacing: 12,
                          children: [
                            Text(
                              'Save',
                              style: TextStyle(
                                color: ColorPalleteLogin.PrimaryColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        onPressed: () async {
                          // BELUM COBA
                          // masuk ke popup lanjutan untuk buat stok card
                          var data = await showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (context) => InventoryTakingFormPopUp(
                                listItem: providerInventory.listItemSubmit),
                          );

                          if(data == true){
                            providerInventory.SubmitInventoryTaking();
                          }
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

class DetailProductInventoryTakingPopup extends StatefulWidget {
  Data data;
  String notesPrev;
  DetailProductInventoryTakingPopup({
    required this.data,
    required this.notesPrev,
    super.key,
  });

  @override
  State<DetailProductInventoryTakingPopup> createState() => _DetailProductInventoryTakingPopupState();
}

class _DetailProductInventoryTakingPopupState extends State<DetailProductInventoryTakingPopup> {
  // controller
  var informationController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    informationController.text = widget.notesPrev;
  }
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.55,
        // height: MediaQuery.of(context).size.height * 0.3,
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
                'Product Detail',
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
                judul: 'Location',
                data: widget.data.sectionPlacement!,
              ),

              SizedBox(
                height: 15,
              ),

              // Information
              Text(
                'Information',
                style: TextStyle(
                    fontSize: 16,
                    color: ColorPalleteLogin.OrangeLightColor,
                    fontWeight: FontWeight.bold),
              ),

              Padding(
                  padding: EdgeInsets.all(8.0),
                  // >> note : BELUM DI LIMIT CHARACTER
                  child: TextField(
                    onChanged: (value) {
                      
                    },
                    keyboardType: TextInputType.multiline,
                    controller: informationController,
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
                  )),

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
                              'Save',
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
                          Navigator.pop(context, informationController.text);
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

class InventoryTakingFormPopUp extends StatefulWidget {
  final List<itemSubmit> listItem;
  const InventoryTakingFormPopUp({
    super.key,
    required this.listItem,
  });

  @override
  State<InventoryTakingFormPopUp> createState() =>
      _InventoryTakingFormPopUpState();
}

class _InventoryTakingFormPopUpState extends State<InventoryTakingFormPopUp> {
  var _customTileExpanded = false;
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.7,
        decoration: BoxDecoration(
          color: ColorPalleteLogin.PrimaryColor,
          borderRadius: BorderRadius.circular(20),
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
                    'Inventory Taking',
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

                  // detail inventory taking
                  InventoryTakingDetailsChild(
                    judul: 'Responsible Person',
                    data: 'Budi Setiawan', // NOTE : GANTI
                  ),
                  InventoryTakingDetailsChild(
                    judul: 'Date',
                    data: DateFormat('hh:mm aaa, MM/dd/yyyy')
                        .format(DateTime.now()),
                  ),

                  // changes untuk yg udah di input actual stock (buat tabel)
                  Theme(
                    data: Theme.of(context)
                        .copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: EdgeInsets.only(left: 8.0),
                      trailing: Icon(
                        _customTileExpanded
                            ? Icons.arrow_drop_down_circle
                            : Icons.arrow_drop_down,
                        color: ColorPalleteLogin.OrangeColor,
                      ),
                      title: Text(
                        'Changes',
                        style: TextStyle(
                            fontSize: 16,
                            color: ColorPalleteLogin.OrangeLightColor,
                            fontWeight: FontWeight.bold),
                      ),
                      children: [
                        TableInventoryTakingPopUp(
                          contentTable: widget.listItem,
                        ),
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
                        width: 20,
                      ),
                      Center(
                        child: Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width * 0.55 * 0.3,
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
                              Navigator.pop(context, true);
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
        ),
      ),
    );
  }
}

class DiscardPopup extends StatelessWidget {
  const DiscardPopup({
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
                'Discard',
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
                      'Are you sure you want to discard the changes you\'ve made?',
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
                              'Discard',
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
                          Navigator.pop(context,true);
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

class TableInventoryTaking extends StatelessWidget {
  int startIndex;
  List<Data> contentTable;
  TableInventoryTaking({
    super.key,
    required this.contentTable,
    required this.startIndex,
  });

  @override
  Widget build(BuildContext context) {
    final providerInventory = Provider.of<InventoryTakingProvider>(context);
    List<TextEditingController> controllerQty =
        providerInventory.resultController;

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
            5: FlexColumnWidth(3),
            6: FlexColumnWidth(2),
            7: FlexColumnWidth(2),
            8: FlexColumnWidth(2),
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
                      child: Text('NO', style: TableContentTextStyle.textStyle),
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
                    child: Text('EXPECTED STOCK',
                        style: TableContentTextStyle.textStyle),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('ACTUAL STOCK',
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
                    child: Text('FILL', style: TableContentTextStyle.textStyle),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(6.0),
                    child:
                        Text('DETAIL', style: TableContentTextStyle.textStyle),
                  ),
                ),
              ],
            ),

            // making the content
            ...List.generate(
              contentTable.length,
              (index) {
                // TextEditingController controllerFill = TextEditingController();
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
                          child: Text('${(startIndex + index + 1)}',
                              style: TableContentTextStyle.textStyleBody),
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
                        child: Text('${contentTable[index].expiredDate}',
                            style: TableContentTextStyle.textStyleBody),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text('${contentTable[index].expectedStock}',
                              style: TableContentTextStyle.textStyleBody),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                          padding: EdgeInsets.all(8.0),
                          // >> note : BELUM DI LIMIT
                          child: TextField(
                            onChanged: (value) {
                              if(value != null || value != ''){
                              providerInventory.addToCart(startIndex + index,
                                  quantity:
                                      int.parse(controllerQty[index].text));
                              }
                              else{
                                providerInventory.removeFromCart(startIndex+index);
                              }
                            },
                            controller: controllerQty[index],
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

                    // action button
                    TableCell(
                      child: Padding(
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
                            // ubah input value di expected stock
                            controllerQty[index].text =
                                contentTable[index].expectedStock.toString();
                            providerInventory.addToCart(startIndex + index,
                                quantity: int.parse(controllerQty[index].text));
                          },
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 8.0, right: 8.0, top: 2, bottom: 2),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.all(0),
                            backgroundColor: ColorPalleteLogin.PrimaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                          ),
                          child: Icon(
                            Icons.remove_red_eye_outlined,
                            color: ColorPalleteLogin.OrangeColor,
                          ),
                          onPressed: () async {
                            // keluarin popup detail
                            var data = await showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (context) =>
                                  DetailProductInventoryTakingPopup(
                                data: contentTable[index],
                                notesPrev: providerInventory.getNotes(contentTable[index]),
                              ),
                            );
                            if(data != null){
                              providerInventory.addToCart(startIndex+index, notes: data.toString());
                            }
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

class TableInventoryTakingPopUp extends StatelessWidget {
  final List<itemSubmit> contentTable;

  const TableInventoryTakingPopUp({
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
            1: FlexColumnWidth(7),
            2: FlexColumnWidth(3),
            3: FlexColumnWidth(3),
            4: FlexColumnWidth(3),
            5: FlexColumnWidth(3),
            6: FlexColumnWidth(2),
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
                    child: Center(
                      child: Text('NO',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'PRODUCT NAME',
                      style: TableContentTextStyle.textStyle,
                    ),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'BATCH',
                      style: TableContentTextStyle.textStyle,
                    ),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'EXPIRY DATE',
                      style: TableContentTextStyle.textStyle,
                    ),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'EXPECTED STOCK',
                      style: TableContentTextStyle.textStyle,
                    ),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'ACTUAL STOCK',
                      style: TableContentTextStyle.textStyle,
                    ),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'UNIT TYPE',
                      style: TableContentTextStyle.textStyle,
                    ),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('INFORMATION',
                        style: TableContentTextStyle.textStyle),
                  ),
                ),
              ],
            ),

            // making the content
            ...List.generate(
              contentTable.length,
              (index) => TableRow(
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
                        child: Text('${index + 1}',
                            style: TableContentTextStyle.textStyleBody),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                          '${contentTable[index].stockData.productName}',
                          style: TableContentTextStyle.textStyleBody),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('${contentTable[index].stockData.batch}',
                          style: TableContentTextStyle.textStyleBody),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                          getOnlyDate(
                              contentTable[index].stockData.expiredDate!),
                          style: TableContentTextStyle.textStyleBody),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                            '${contentTable[index].stockData.expectedStock}',
                            style: TableContentTextStyle.textStyleBody),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text('${contentTable[index].quantity}',
                            style: TableContentTextStyle.textStyleBody),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Unit',
                          style: TableContentTextStyle.textStyleBody),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('${contentTable[index].notes}',
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

class InventoryTakingDetailsChild extends StatelessWidget {
  String judul;
  String data;

  InventoryTakingDetailsChild({
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

// // Menambah stock opname
// e.POST("/products/stock/opname/add", controller.InsertStockOpname)
// [
//     {
//         "product_detail_id": 4,
//         "batch": "1",
//         "expired_date": "2025-08-25",
//         "actual_stock": 15,
//         "unit_type": "gram",
//         "store_warehouse_id": 2
//     }
// ]

class InputStockOpname {
  Data data;
  late int actualStock;
  late String additional_information;

  InputStockOpname({
    required this.data,
  });
}

var jsonStockOpname = {
  "status": 200,
  "message": "Berhasil",
  "data": [
    {
      "stock_opname_id": 0,
      "product_detail_id": 14,
      "product_name": "Tomato",
      "batch": "1",
      "expired_date": "2024-08-23",
      "expected_stock": 1000,
      "actual_stock": 0,
      "unit_type": "gram",
      "timestamp": "",
      "store_warehouse_id": 2
    },
    {
      "stock_opname_id": 0,
      "product_detail_id": 3,
      "product_name": "Spinach",
      "batch": "1",
      "expired_date": "2025-08-16",
      "expected_stock": 0,
      "actual_stock": 0,
      "unit_type": "gram",
      "timestamp": "",
      "store_warehouse_id": 2
    },
    {
      "stock_opname_id": 0,
      "product_detail_id": 4,
      "product_name": "Pepper",
      "batch": "1",
      "expired_date": "2025-08-20",
      "expected_stock": 20,
      "actual_stock": 0,
      "unit_type": "gram",
      "timestamp": "",
      "store_warehouse_id": 2
    },
    {
      "stock_opname_id": 0,
      "product_detail_id": 4,
      "product_name": "Pepper",
      "batch": "1",
      "expired_date": "2025-08-25",
      "expected_stock": 15,
      "actual_stock": 0,
      "unit_type": "gram",
      "timestamp": "",
      "store_warehouse_id": 2
    },
    {
      "stock_opname_id": 0,
      "product_detail_id": 3,
      "product_name": "Spinach",
      "batch": "2",
      "expired_date": "2025-08-20",
      "expected_stock": 25,
      "actual_stock": 0,
      "unit_type": "gram",
      "timestamp": "",
      "store_warehouse_id": 2
    },
    {
      "stock_opname_id": 0,
      "product_detail_id": 4,
      "product_name": "Pepper",
      "batch": "2",
      "expired_date": "2025-08-25",
      "expected_stock": 10,
      "actual_stock": 0,
      "unit_type": "gram",
      "timestamp": "",
      "store_warehouse_id": 2
    },
    {
      "stock_opname_id": 0,
      "product_detail_id": 4,
      "product_name": "Pepper",
      "batch": "3",
      "expired_date": "2025-08-25",
      "expected_stock": 5,
      "actual_stock": 0,
      "unit_type": "gram",
      "timestamp": "",
      "store_warehouse_id": 2
    },
    {
      "stock_opname_id": 0,
      "product_detail_id": 4,
      "product_name": "Pepper",
      "batch": "4",
      "expired_date": "2025-08-25",
      "expected_stock": 5,
      "actual_stock": 0,
      "unit_type": "gram",
      "timestamp": "",
      "store_warehouse_id": 2
    },
    {
      "stock_opname_id": 0,
      "product_detail_id": 4,
      "product_name": "Pepper",
      "batch": "5",
      "expired_date": "2025-08-25",
      "expected_stock": 0,
      "actual_stock": 0,
      "unit_type": "gram",
      "timestamp": "",
      "store_warehouse_id": 2
    }
  ]
};
