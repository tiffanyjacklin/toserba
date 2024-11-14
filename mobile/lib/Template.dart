import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ColorPalleteLogin {
  static const PrimaryColor = Color(0xFF3e4e50);
  static const SecondaryColor = Color(0xFFfacfad);
  static const OrangeDarkColor = Color(0xFFf2aa7e);
  static const OrangeColor = Color(0xFFf8bd7f);
  static const OrangeLightColor = Color(0xFFfacfad);
  static const TableColor = Color(0xFFfff2cc);
}

var fontSizeBody = 18.0;
var fontSizeSmall = 14.0;

class bodyText extends StatelessWidget {
  String judul;

  bodyText({
    required this.judul,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      judul,
      style: TextStyle(
          fontSize: fontSizeBody,
          fontWeight: FontWeight.bold),
    );
  }
}

class SubTitleText extends StatelessWidget {
  String judul;
  String data;
  bool isColumn;

  SubTitleText({
    this.judul = '',
    this.data = '',
    this.isColumn = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return isColumn
        ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  this.judul,
                  style: TextStyle(
                      fontSize: fontSizeBody,
                      color: ColorPalleteLogin.OrangeLightColor,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  this.data,
                  style: TextStyle(
                      fontSize: fontSizeBody,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
          )
        : Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  this.judul,
                  style: TextStyle(
                      fontSize: fontSizeBody,
                      color: ColorPalleteLogin.OrangeLightColor,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  this.data,
                  style: TextStyle(
                      fontSize: fontSizeBody,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
  }
}

class TitlePage extends StatelessWidget {
  final name;

  TitlePage({
    required this.name,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$name',
        style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: ColorPalleteLogin.PrimaryColor),
      ),
    );
  }
}

class BodyPage extends StatelessWidget {
  final name;

  BodyPage({
    required this.name,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      '$name',
      style: TextStyle(
          fontSize: fontSizeBody,
          fontWeight: FontWeight.bold,
          color: ColorPalleteLogin.PrimaryColor),
    );
  }
}

class TableTitlePage extends StatelessWidget {
  final name;

  TableTitlePage({
    required this.name,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      '$name',
      style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [
            Shadow(blurRadius: 2.0, color: Colors.black, offset: Offset(1, 1)),
          ]),
    );
  }
}

class TableContentTextStyle {
  static const TextStyle textStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle textStyleBody = TextStyle(
    fontSize: 16,
  );
}

const TextStyle notFoundData =
    TextStyle(fontSize: 20, fontWeight: FontWeight.bold);

// date formatter
String getDateWithTime(String date) {
  return DateFormat('dd-MM-yyyy, hh:mm aaa').format(DateTime.parse(date));
}

String getTimeWithDate(String date) {
  return DateFormat('hh:mm aaa, d MMMM y').format(DateTime.parse(date));
}

String getOnlyDate(String date) {
  return DateFormat('dd/MM/yyyy').format(DateTime.parse(date));
}

String getOnlyDateSQL(String date) {
  return DateFormat('yyyy-MM-dd').format(DateTime.parse(date));
}

String getOnlyTime(String date) {
  return DateFormat('hh:mm aaa').format(DateTime.parse(date));
}

String formatOnlyDateSQL(DateTime date){
  return DateFormat('yyyy-MM-dd').format(date);
}

Future<void> saveImage(Uint8List bytes, String name1) async {
  final time = getOnlyDate(DateTime.now().toString());
  final name = 'Screentshot_$name1-$time';
  await Permission.storage.request();
  final result = await ImageGallerySaver.saveImage(bytes, name: name);
  debugPrint('result : $result');
}

// function saveimage
Future<void> saveAndShare(Uint8List bytes, String name1) async {
  final dir = Platform.isAndroid
      ? await getExternalStorageDirectory()
      : await getApplicationDocumentsDirectory();
}
