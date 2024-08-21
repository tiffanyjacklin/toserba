import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_all/ColorPallete.dart';

class ProductPage extends StatelessWidget {
  const ProductPage({super.key});

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

                    // trailing: Icon(Icons.abc),
                    ),
              ),
              SizedBox(
                height: 10,
              ),

              // template listview
              ProductTile(),
              ProductTile(),
              ProductTile(),
              ProductTile(),
              // ProductTile(),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductTile extends StatelessWidget {
  const ProductTile({
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
          '#432521421',
          style: TextStyle(
            color: ColorPalleteLogin.OrangeDarkColor,
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          'Gelas Kaca Cangkir Saringan Teh Kopi Ramuan Cup Mug Infuser Rempah - Gelas 300ml ',
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
                'Stock: 50',
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
                    builder: (context) => ProductDetailsPopup(),
                  );
                },
                // child: Row(
                //   children: [
                //     Expanded(
                //         child: Text('View', style: TextStyle(color: Colors.white),),),
                //   ],
                // ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// product detail popup
class ProductDetailsPopup extends StatelessWidget {
  const ProductDetailsPopup({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.55,
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
                  ProductDetailsChild(
                    judul: 'Product ID',
                    data: '#4444',
                  ),
                  ProductDetailsChild(
                    judul: 'Product Name',
                    data: 'Apapun Ini jadi apa',
                  ),
                  ProductDetailsChild(
                    judul: 'Product Brand',
                    data: 'Product Brand',
                  ),
                  ProductDetailsChild(
                    judul: 'Product Type',
                    data: 'PolyMorph',
                  ),
                  ProductDetailsChild(
                    judul: 'Date Added',
                    data: '10/10/2022',
                  ),
                  ProductDetailsChild(
                    judul: 'Expiration Date',
                    data: '10/10/2022',
                  ),
                  ProductDetailsChild(
                    judul: 'Current Stock',
                    data: 'COLLAPSE',
                  ),
                  ProductDetailsChild(
                    judul: 'Last Inventory Taking',
                    data: '01/07/2024',
                  ),
                  ProductDetailsChild(judul: 'Stok Card'),

                  // button save
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
                              'Save',
                              style: TextStyle(
                                  color: ColorPalleteLogin.PrimaryColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        onPressed: () {},
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
