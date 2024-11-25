import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Toserba_App/Model/NotificationsByRoles.dart';
import 'package:Toserba_App/Tambahan/Provider/Auth.dart';
import 'package:Toserba_App/Tambahan/Provider/Notification.dart';
import 'package:Toserba_App/Template.dart';
import 'package:provider/provider.dart';
import 'package:Toserba_App/Model/UserData.dart' as users;

class NotificationPage2 extends StatelessWidget {
  const NotificationPage2({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthState>(context);
    return ChangeNotifierProvider(
      create: (context) => NotificationProvider(),
      child: NotificationPage(user: authProvider.userData,),
    );
  }
}

class NotificationPage extends StatefulWidget {
  final users.Data user;
  
  const NotificationPage({
    super.key,
    required this.user,
    });

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // context.read<NotificationProvider>().fetchNotificationsProvider(context.read<AuthState>().userData.roleId!);
      context.read<NotificationProvider>().fetchNotificationsProvider(widget.user.roleId!,widget.user.userId!);
    });

  }

  @override
  Widget build(BuildContext context) {
    final providerNotification = Provider.of<NotificationProvider>(context);
    return Padding(
      padding: const EdgeInsets.all(20.0),
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

          // NOTE : perbaiki ini nanti
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  'Notification',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: ColorPalleteLogin.PrimaryColor),
                ),
                SizedBox(
                  height: 10,
                ),

                // FutureBuilder<List<Data>>(
                //     future: _fetchNotifications(1), // NOTE ganti
                //     builder: (context, snapshot) {
                //       if (snapshot.connectionState == ConnectionState.done) {
                //         // get error
                //         if (snapshot.hasError) {
                //           return Center(
                //             child: Text('error fetch'),
                //           );
                //         } else {
                //           return Container(
                //             width: MediaQuery.of(context).size.width * 0.65,
                //             child: ListView.builder(
                //               shrinkWrap: true,
                //               itemCount: snapshot.data!.length,
                //               itemBuilder: (BuildContext context, int index) {
                //                 return NotificationChild(dataNotif: snapshot.data![index]);
                //               },
                //             ),
                //           );
                //         }
                //       } else {
                //         return CircularProgressIndicator();
                //       }
                //     }),

                providerNotification.isLoading
                    ? CircularProgressIndicator()
                    : providerNotification.listNotification.length == 0
                        ? Container()
                        : Container(
                          width: MediaQuery.of(context).size.width * 0.65,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: providerNotification.listNotification.length,
                            itemBuilder: (context, index) {
                              return NotificationChild(dataNotif: providerNotification.listNotification[index]);
                            },
                          ),
                        ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NotificationChild extends StatelessWidget {
  final Data dataNotif;

  NotificationChild({
    required this.dataNotif,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          // width: MediaQuery.of(context).size.width * 0.65,
          // width: 400,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: Colors.black,
            ),
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black45,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    flex: 7,
                    child: RichText(
                      text: TextSpan(
                        text: '',
                        style: DefaultTextStyle.of(context).style,
                        children: <TextSpan>[
                          // TextSpan(
                          //   text: 'WARNING',
                          //   style: TextStyle(
                          //       color: ColorPalleteLogin.PrimaryColor,
                          //       fontSize: 16,
                          //       fontWeight: FontWeight.bold),
                          // ),
                          TextSpan(
                            text: dataNotif.notifications!.description,
                            style: TextStyle(
                                color: ColorPalleteLogin.PrimaryColor,
                                fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: VerticalDivider(
                            color: Colors.black,
                            thickness: 1,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                getOnlyTime(
                                    dataNotif.notifications!.timestamp!),
                                style: TextStyle(
                                    color: ColorPalleteLogin.PrimaryColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                getOnlyDate(
                                    dataNotif.notifications!.timestamp!),
                                style: TextStyle(
                                    color: ColorPalleteLogin.PrimaryColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
      ],
    );
  }
}
