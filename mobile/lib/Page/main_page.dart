import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app_all/Tambahan/Provider/Auth.dart';
import 'package:flutter_app_all/Tambahan/Provider/RouteProvider.dart';
import 'package:flutter_app_all/Template.dart';
import 'package:provider/provider.dart';

class MainPage extends StatelessWidget {
  // final Data dataUser;
  // final List<DataPrivileges> listPrivileges;
  // const MainPage(this.dataUser, this.listPrivileges);
  const MainPage();

  // cek layar tablet atau hp
  bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 767;
  bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 767;

  @override
  Widget build(BuildContext context) {
    final routeProvider = Provider.of<RouteProvider>(context);
    final authProvider = Provider.of<AuthState>(context);
    routeProvider.buildPriviledges(
        authProvider.userData.userId!, authProvider.userData.roleId!);
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          bottomOpacity: 0.3,
          backgroundColor: ColorPalleteLogin.OrangeLightColor,
          actions: [
            Container(
              decoration: BoxDecoration(
                color: ColorPalleteLogin.OrangeLightColor,
                // border: Border(
                //   bottom: BorderSide(width: 1, color: Colors.black),
                // ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: Row(
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Icon(Icons.help_outline_outlined),
                              ),
                              Text(
                                'Help',
                                style: TextStyle(
                                    color: ColorPalleteLogin.PrimaryColor,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          GestureDetector(
                              child: Icon(Icons.notifications_outlined)),
                          SizedBox(
                            width: 20,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
        drawer: Drawer(
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
              padding: const EdgeInsets.all(15.0),
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
                              // making the profile picture
                              Expanded(
                                flex: 2,
                                child: Container(
                                  decoration: BoxDecoration(),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        child: Column(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    color: ColorPalleteLogin
                                                        .OrangeLightColor),
                                              ),
                                            ),
                                            Expanded(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    color: ColorPalleteLogin
                                                        .OrangeDarkColor),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Divider(
                                        thickness: 2,
                                        color:
                                            ColorPalleteLogin.PrimaryColor,
                                      ),
                                      CircleAvatar(
                                        radius: 24.0,
                                        backgroundImage: NetworkImage(
                                            'https://picsum.photos/id/237/300/300'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                  flex: 1,
                                  child: Text(
                                    '${authProvider.userData.userFullname}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  )),
                              Expanded(
                                  flex: 1,
                                  child: Text(
                                    '${authProvider.userData.rolesName}',
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
                      child: routeProvider.isLoading
                          ? Center(
                              child: CircularProgressIndicator(),
                            )
                          : Column(
                              children: List.generate(
                                  routeProvider.sidebarMenu.length,
                                  (index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      Provider.of<RouteProvider>(context,
                                              listen: false)
                                          .selectMenu = index;
                                      Navigator.of(context).pop();
                                    },
                                    child: Container(
                                      color: routeProvider
                                                  .selectedMenuIndex ==
                                              index
                                          ? Colors.white
                                          : ColorPalleteLogin.PrimaryColor,
                                      child: Center(
                                        child: Text(
                                          '${routeProvider.sidebarMenu[index].privilegesName!.toCapitalized()}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: routeProvider
                                                        .selectedMenuIndex ==
                                                    index
                                                ? ColorPalleteLogin
                                                    .PrimaryColor
                                                : Colors.white,
                                            fontSize: fontSizeBody,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            )),
                  Expanded(
                    flex: 1,
                    child: GestureDetector(
                      onTap: () {
                        // logout
                        authProvider.logout();
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
          ),
        ),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MenuPage(),
          ],
        ),
      ),
    );
  }

  // SIDEBAR
  Widget headerSideBar(BuildContext context) => Container();
}

// SIDE MENU
class MenuPage extends StatefulWidget {
  const MenuPage({
    super.key,
  });

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  @override
  Widget build(BuildContext context) {
    RouteProvider providerRoute = Provider.of<RouteProvider>(context);
    AuthState providerAuth = Provider.of<AuthState>(context);
    return Expanded(
      flex: 8,
      child: Container(
        decoration: BoxDecoration(color: Colors.grey[100]),
        child: providerRoute.isLoading || providerRoute.sidebarMenu.isEmpty
            ? Center(
                child: Text('Please Wait , Still Loading Page'),
              )
            : providerRoute.getPage(),
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
void _logout() {}
