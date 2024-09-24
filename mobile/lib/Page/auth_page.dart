import 'package:flutter/cupertino.dart';
import 'package:flutter_app_all/Page/Login/choose_role.dart';
import 'package:flutter_app_all/Page/Login/login_tablet.dart';
import 'package:flutter_app_all/Tambahan/Provider/Auth.dart';
import 'package:flutter_app_all/Tambahan/Provider/LoginProvider.dart';
import 'package:provider/provider.dart';

class AuthenticationPage extends StatefulWidget {
  const AuthenticationPage({super.key});

  @override
  State<AuthenticationPage> createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {
  @override
  Widget build(BuildContext context) {
    var providerLogin = Provider.of<LoginProvider>(context);
    // var providerAuth = Provider.of<AuthState>(context);
    return !providerLogin.isChooseRole 
    ? LoginTablet()
    : ChooseRolePage(); 
  }
}