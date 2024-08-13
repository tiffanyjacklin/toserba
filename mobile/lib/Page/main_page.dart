import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app_all/ColorPallete.dart';
import 'package:flutter_app_all/Model/UserData.dart';
import 'package:flutter_app_all/Page/Cashier/sessionHistory_page.dart';
import 'package:flutter_app_all/Page/Cashier/session_page.dart';

class MainPage extends StatelessWidget {
  final Data dataUser;
  const MainPage(this.dataUser);

  // cek layar tablet atau hp
  bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 767;
  bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 767;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          // SIDEBAR
          Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: ColorPalleteLogin.PrimaryColor,
                  boxShadow: [
                    BoxShadow(
                    color: ColorPalleteLogin.OrangeDarkColor,
                    offset: Offset(6, 0),
                  ),
                  ]
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: ColorPalleteLogin.OrangeColor),
                                      child: CircleAvatar(
                                        radius: 20.0,
                                        backgroundImage: NetworkImage(
                                            'https://picsum.photos/id/237/300/300'),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                      flex: 1,
                                      child: Text(
                                        'Logged in as ${dataUser.userFullname}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      )),
                                  Expanded(
                                      flex: 1,
                                      child: Text(
                                        '${dataUser.rolesName}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white54),
                                      ))
                                ],
                              ),
                            ),
                          )),
                      // kasih divider
                      Divider(
                        thickness: 2,
                        color: Colors.white,
                      ),
                      Expanded(flex: 8, child: menuSideBar(context)),
                      Expanded(
                        flex: 1,
                        child: Row(
                          children: [
                            Icon(Icons.logout_outlined, color: Colors.white54,),
                            Text('Logout', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white54),)
                          ],
                        ),
                        ),
                    ],
                  ),
                ),
              )),


          // MENU PAGE
          Expanded(
            flex: 8,
            child: Column(
              children: [
                Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: ColorPalleteLogin.OrangeLightColor,
                        border: Border(
                          bottom: BorderSide(width: 1, color: Colors.black),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              child: Icon(Icons.ac_unit),
                            ),
                            Container(
                              child: Row(
                                children: [
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Icon(Icons.help_outline_outlined),
                                      ),
                                      Text('Help', style: TextStyle(color: ColorPalleteLogin.PrimaryColor, fontWeight: FontWeight.bold),),
                                    ],
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Icon(Icons.notifications_outlined),
                                  SizedBox(
                                    width: 20,
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    )),

                // buat page2
                Expanded(
                  flex: 8, 
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100]
                    ),
                    child: SessionHistoryPage(),
                  )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // SIDEBAR
  Widget headerSideBar(BuildContext context) => Container();

  // pisah aja buat widget item sidebar
  Widget menuSideBar(BuildContext context) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onHover: (val) {},
              child: const Text(
                'Session',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onHover: (val) {},
              child: const Text(
                'Session History',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onHover: (val) {},
              child: const Text(
                'Transaction History',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onHover: (val) {},
              child: const Text(
                'Member',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),

          // ListTile(
          //   title: const Text('Menu Name', style: TextStyle(color: Colors.white),),
          // ),
          // ListTile(
          //   title: const Text('Menu Name', style: TextStyle(color: Colors.white),),
          // ),
        ],
      );
}
