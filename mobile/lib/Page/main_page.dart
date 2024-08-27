import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app_all/Page/Warehouse%20Employee/history_all_stock_product_page.dart';
import 'package:flutter_app_all/Template.dart';
import 'package:flutter_app_all/Model/PrivilegesData.dart';
import 'package:flutter_app_all/Model/UserData.dart';
import 'package:flutter_app_all/Page/Login/login_tablet.dart';
import 'package:flutter_app_all/Page/Store%20Inventory/accept_order_page.dart';
import 'package:flutter_app_all/Page/Store%20Inventory/inventory_taking_page.dart';
import 'package:flutter_app_all/Page/Store%20Inventory/product_page.dart';
import 'package:flutter_app_all/Page/Umum/notification_page.dart';
import 'package:flutter_app_all/Page/Warehouse%20Employee/stock_transfer_notes_page.dart';

class MainPage extends StatelessWidget {
  final Data dataUser;
  final List<DataPrivileges> listPrivileges;
  const MainPage(this.dataUser, this.listPrivileges);

  // cek layar tablet atau hp
  bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 767;
  bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 767;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        drawer: isMobile(context ) ? Drawer(
          child: // SIDEBAR
                SidebarMainPage(dataUser: dataUser, listPrivileges: listPrivileges),
        ) : null,
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!isMobile(context))
              SidebarMainPage(dataUser: dataUser, listPrivileges: listPrivileges),
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
                                          child:
                                              Icon(Icons.help_outline_outlined),
                                        ),
                                        Text(
                                          'Help',
                                          style: TextStyle(
                                              color:
                                                  ColorPalleteLogin.PrimaryColor,
                                              fontWeight: FontWeight.bold),
                                        ),
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
      
                  // buat pindah page
                  MenuPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // SIDEBAR
  Widget headerSideBar(BuildContext context) => Container();
}

class SidebarMainPage extends StatelessWidget {
  const SidebarMainPage({
    super.key,
    required this.dataUser,
    required this.listPrivileges,
  });

  final Data dataUser;
  final List<DataPrivileges> listPrivileges;

  @override
  Widget build(BuildContext context) {
    return Expanded(
        flex: 2,
        child: Container(
          decoration: BoxDecoration(
              color: ColorPalleteLogin.PrimaryColor,
              boxShadow: [
                BoxShadow(
                  color: ColorPalleteLogin.OrangeDarkColor,
                  offset: Offset(6, 0),
                ),
              ]),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                    flex: 3,
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
                                    color:
                                        ColorPalleteLogin.OrangeColor),
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
                                  '${dataUser.userFullname}',
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
              Expanded(
                  flex: 7,
                  child: menuSideBar(context, listPrivileges)),
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: () {
                    // logout
                    // keluar dari page ini pindah ke login
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (BuildContext context) => LoginTablet()));
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.logout_outlined,
                        color: Colors.white54,
                      ),
                      Text(
                        'Logout',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white54),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ));
  }
}

// SIDE MENU
class MenuPage extends StatelessWidget {
  const MenuPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
        flex: 8,
        child: Container(
          decoration: BoxDecoration(color: Colors.grey[100]),
          child: HistoryAllStockProductPage(),
        ));
  }
}



// pisah aja buat widget item sidebar
Column menuSideBar(BuildContext context, List<DataPrivileges> list) {
  List<Widget> children = [];
  for (var privileges in list) {
    if (privileges.navbar == 1) {
      children.add(
        Expanded(
          flex: 2,
          child: ChildMenu(privileges: privileges),
        ),
      );
    }
  }
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: children,
  );
}

class ChildMenu extends StatefulWidget {
  ChildMenu({
    super.key,
    required this.privileges,
  });

  final DataPrivileges privileges;

  @override
  State<ChildMenu> createState() => _ChildMenuState();
}

class _ChildMenuState extends State<ChildMenu> {
  bool isHover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) {
        setState(() {
          isHover = true;
        });
      },
      onExit: (event) => {
        setState(() {
          isHover = false;
        })
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4.0),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          color: isHover
              ? Color.fromARGB(93, 242, 171, 126)
              : ColorPalleteLogin.PrimaryColor,
          child: Center(
            child: Text(
              '${widget.privileges.privilegesName.toString().toCapitalized()}',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}

// Extension
extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
  String toTitleCase() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toCapitalized())
      .join(' ');
}


// Function logout
void _logout(){

}
