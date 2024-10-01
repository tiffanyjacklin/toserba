import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app_all/Tambahan/Provider/Auth.dart';
import 'package:flutter_app_all/Tambahan/Provider/LoginProvider.dart';
import 'package:flutter_app_all/Template.dart';
import 'package:flutter_app_all/Model/PrivilegesData.dart';
import 'package:flutter_app_all/Model/UserData.dart';
import 'package:flutter_app_all/Model/RolesPerUser.dart' as roles;
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

// // manual nama
// var roleName = [
//   'Cashier',
//   'Inventory Store Employee',
//   'Warehouse Employee',
//   'Warehouse Operational Staff',
//   'Admin',
//   'Owner'
// ];

// Future fetchProduct(int userId, int roleId, String search) async {
//   // ${$userId}/${$roleId}///${searchQuery}/${category}/${unit_type}/${sort_type}/${sorting}/${limit}/${offset}
//   final link =
//       'http://leap.crossnet.co.id:8888/products/store_warehouse/$userId/$roleId///$search/////10/0';

//   print(link);

//   // call api
//   final response = await http.get(Uri.parse(link));
//   print('---> response ' + response.statusCode.toString());

//   // cek status
//   if (response.statusCode == 200) {
//     // misal oke berati masuk
//     // json
//     Map<String, dynamic> temp = json.decode(response.body);
//     // decode?
//     print(response.body);
//     if (temp['status'] == 200) {
//       print(temp);
//       return product.FetchAllProducts.fromJson(temp).data!;
//     } else {
//       return [];
//     }
//   } else {
//     // If the server did not return a 200 OK response,
//     // then throw an exception.
//     // throw Exception('Login Failed, Try Again');
//     print('fetch failed');
//     return [];
//   }
// }

Future<List<roles.Data>> _fetchRolePerUser(int userId) async {
  final link = 'http://leap.crossnet.co.id:8888/user/roles/$userId';
  print(link);

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
      return roles.RolesPerUser.fromJson(temp).data!;
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

class ChooseRolePage extends StatefulWidget {
  const ChooseRolePage();

  @override
  State<ChooseRolePage> createState() => _ChooseRolePageState();
}

class _ChooseRolePageState extends State<ChooseRolePage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AuthState>(context);
    final providerLogin = Provider.of<LoginProvider>(context);
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () {
                providerLogin.chooseRole = false;
              },
              child: Row(
                children: [
                  Icon(Icons.arrow_back),
                  Text(
                    'Back',
                    style: TextStyle(fontSize: fontSizeBody - 2),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Column(
              children: [
                Text(
                  'Choose Role',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: ColorPalleteLogin.PrimaryColor),
                ),
                FutureBuilder(
                  future: _fetchRolePerUser(
                      int.parse(context.read<AuthState>().userId)),
                  builder: (context, snapshot) {
                    // Checking if future is resolved
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasData) {
                        // Extracting data from snapshot object
                        final listData = snapshot.data as List<roles.Data>;
                        return Container(
                          height: 400,
                          width: double.maxFinite,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithMaxCrossAxisExtent(
                                      maxCrossAxisExtent:
                                          250, // tinggal setting berapa besar kotak rolenya mau berapa
                                      childAspectRatio:
                                          (3 / 2), // rasio hasil besar child
                                      crossAxisSpacing: 10, // kiri kanan
                                      mainAxisSpacing: 10 // atas bawah
                                      ),
                              itemCount: listData.length,
                              itemBuilder: (_, index) {
                                return InkWell(
                                  onTap: () {
                                    _roleValidate(int.parse(provider.userId),
                                            listData[index].roleId!)
                                        .then((hasil) => {
                                              if (hasil != null)
                                                {
                                                  
                                                  provider
                                                      .saveToStorage(
                                                          provider.userId,
                                                          (listData[index].roleId!)
                                                              .toString(),
                                                          hasil)
                                                      .then((hasil) {
                                                    provider
                                                        .setDisplayLoginPage(
                                                            true);
                                                  }),
                                                },
                                            });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: ColorPalleteLogin.OrangeLightColor,
                                      border: Border.all(color: Colors.black),
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black26,
                                          spreadRadius: 0,
                                          blurRadius: 1,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.access_alarm_outlined,
                                          color: Colors.black,
                                        ),
                                        Wrap(
                                          crossAxisAlignment: WrapCrossAlignment.center,
                                          alignment: WrapAlignment.center,
                                          children: [
                                            Text(
                                            listData[index].rolesName!,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: fontSizeBody+2,
                                                color: ColorPalleteLogin
                                                    .PrimaryColor),
                                          )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      } else {
                        return Center(
                          child: Text(
                            '${snapshot.error} occurred',
                            style: TextStyle(fontSize: fontSizeBody),
                          ),
                        );
                      }
                    } else {
                      return CircularProgressIndicator();
                    }
                  },
                ),
                // Container(
                //   height: 400,
                //   width: double.maxFinite,
                //   child: Padding(
                //     padding: const EdgeInsets.all(8.0),
                //     child: GridView.builder(
                //       gridDelegate:
                //           const SliverGridDelegateWithMaxCrossAxisExtent(
                //               maxCrossAxisExtent:
                //                   250, // tinggal setting berapa besar kotak rolenya mau berapa
                //               childAspectRatio:
                //                   (3 / 2), // rasio hasil besar child
                //               crossAxisSpacing: 10, // kiri kanan
                //               mainAxisSpacing: 10 // atas bawah
                //               ),
                //       itemCount: 6,
                //       itemBuilder: (_, index) {
                //         return InkWell(
                //           onTap: () {
                //             _roleValidate(int.parse(provider.userId), index + 1)
                //                 .then((hasil) => {
                //                       if (hasil != null)
                //                         {
                //                           provider
                //                               .saveToStorage(provider.userId,
                //                                   (index + 1).toString(), hasil)
                //                               .then((hasil) {
                //                             provider.setDisplayLoginPage(true);
                //                           }),
                //                           //   Provider.of<AuthState>(context).saveToStorage(hasil[0], hasil[1], hasil[2]),
                //                           //   Provider.of<AuthState>(context).setDisplayLoginPage(hasil[3]),
                //                         },
                //                     });
                //           },
                //           child: Container(
                //             decoration: BoxDecoration(
                //               color: ColorPalleteLogin.OrangeLightColor,
                //               border: Border.all(color: Colors.black),
                //               borderRadius: BorderRadius.circular(10),
                //               boxShadow: [
                //                 BoxShadow(
                //                   color: Colors.black26,
                //                   spreadRadius: 0,
                //                   blurRadius: 1,
                //                   offset: Offset(0, 2),
                //                 ),
                //               ],
                //             ),
                //             child: Column(
                //               mainAxisAlignment: MainAxisAlignment.center,
                //               children: [
                //                 Icon(
                //                   Icons.access_alarm_outlined,
                //                   color: Colors.black,
                //                 ),
                //                 Center(
                //                   child: Text(
                //                     roleName[index],
                //                     style: TextStyle(
                //                         fontWeight: FontWeight.bold,
                //                         fontSize: 20,
                //                         color: ColorPalleteLogin.PrimaryColor),
                //                   ),
                //                 ),
                //               ],
                //             ),
                //           ),
                //         );
                //       },
                //     ),
                //   ),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // API Function
  Future _roleValidate(int userId, int roleId) async {
    // link api
    final link = 'http://leap.crossnet.co.id:8888/user/$userId/$roleId';

    // call api (method GET)
    final response = await http.get(Uri.parse(link));

    // cek status
    if (response.statusCode == 200) {
      // misal oke berati masuk
      Map<String, dynamic> temp = json.decode(response.body);

      // ambil data yang ada
      FetchUsers userData = FetchUsers.fromJson(temp);

      if (temp['data'].length != 0 && temp['data']['user_id'] != 0) {
        // masukin data login ke dalam sharedpreference
        return userData.data;
      }
      // kasih error kalo dia ga punya akses
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Akses ditolak'),
      ));
      return null;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      // throw Exception('Login Failed, Try Again');

      print('Error, Try Again');

      // show snackbar
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Try Again'),
      ));
      return null;
    }
  }

  Future _fetchPriviledge(int userId, int roleId) async {
    // link api
    final link =
        'http://leap.crossnet.co.id:8888/user/privileges/$userId/$roleId';

    // call api (method GET)
    final response = await http.get(Uri.parse(link));

    // cek status
    if (response.statusCode == 200) {
      // misal oke berati masuk
      Map<String, dynamic> temp = json.decode(response.body);

      // ambil data yang ada
      FetchPrivileges privilegesData = FetchPrivileges.fromJson(temp);

      if (temp['data'].length != 0) {
        // ambil list priviledges
        return privilegesData.data;
      }
      return null;
    } else {
      print('Error, Try Again');
      return null;
    }
  }
}
