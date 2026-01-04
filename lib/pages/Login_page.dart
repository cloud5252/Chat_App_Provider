// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously

import 'package:chat_app_provider/services/auth/authentication.dart';
import 'package:chat_app_provider/components/My_button.dart';
import 'package:chat_app_provider/components/My_text_feilds.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  final Emailcontroller = TextEditingController();
  final passwordcontroller = TextEditingController();
  final void Function()? ontap;

  void Login(BuildContext context) async {
    final authentication = Authentication();
    try {
      await authentication.signIn(
        Emailcontroller.text,
        passwordcontroller.text,
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(title: Text(e.toString())),
      );
    }
  }

  LoginPage({super.key, required this.ontap});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.message,
                size: 60,
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(height: 50),
              Text(
                'Welcome back you`ve been missed!',
                style: TextStyle(
                  fontSize: 17,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(height: 30),
              MyTextFeilds(
                hinttext: 'Email',
                obsecurtext: false,
                controller: Emailcontroller,
              ),
              SizedBox(height: 10),
              MyTextFeilds(
                hinttext: 'Password',
                obsecurtext: false,
                controller: passwordcontroller,
              ),
              SizedBox(height: 30),
              MyButton(text: 'Login', ontap: () => Login(context)),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Not a member? ',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  GestureDetector(
                    onTap: ontap,
                    child: Text(
                      'Register now',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
