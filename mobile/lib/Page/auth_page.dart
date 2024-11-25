import 'package:flutter/cupertino.dart';
import 'package:Toserba_App/Page/Login/choose_role.dart';
import 'package:Toserba_App/Page/Login/login_tablet.dart';
import 'package:Toserba_App/Tambahan/Provider/LoginProvider.dart';
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