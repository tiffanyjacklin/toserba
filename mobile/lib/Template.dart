import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
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

class TableBodyText extends StatelessWidget {
  String judul;
  String data;
  bool isColumn;

  TableBodyText ({
    this.judul = '',
    this.data = '',
    this.isColumn = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return isColumn ? Padding(
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
    ): Padding(
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

class TitlePage extends StatelessWidget {
  var name;
  
  TitlePage({
    required this.name,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
          '$name',
          style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: ColorPalleteLogin.PrimaryColor),
        );
  }
}



Future<void> saveImage(Uint8List bytes, String name1) async {
    final time = DateTime.now().toIso8601String().replaceAll('.', '-');
    final name = 'Screentshot_$name1$time';
    await Permission.storage.request();
    final result = await ImageGallerySaver.saveImage(bytes, name: name);
    debugPrint('result : $result');
  }

  // function saveimage
  Future<void> saveAndShare(Uint8List bytes, String name1) async {
    final dir = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();

    // final image = File('${dir!.path}/$name1$time.png');
    // image.writeAsBytes(bytes);
    // await Share.shareXFiles([XFile(image.path)]);
  }


