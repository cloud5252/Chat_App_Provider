import 'package:chat_app_provider/pages/Login_page.dart';
import 'package:chat_app_provider/pages/Register_page.dart';
import 'package:flutter/material.dart';

class LoginRegisterPage extends StatefulWidget {
  const LoginRegisterPage({super.key});

  @override
  State<LoginRegisterPage> createState() => _LoginRegisterPageState();
}

class _LoginRegisterPageState extends State<LoginRegisterPage> {
  bool showloginpage = true;
  void toggled() {
    setState(() {
      showloginpage = !showloginpage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showloginpage) {
      return LoginPage(ontap: toggled);
    } else {
      return RegisterPage(ontap: toggled);
    }
  }
}
