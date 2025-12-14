import 'package:chat_app_provider/services/auth/authentication.dart';
import 'package:chat_app_provider/components/My_button.dart';
import 'package:chat_app_provider/components/My_text_feilds.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatelessWidget {
  final TextEditingController Emailcontroller =
      TextEditingController();
  final TextEditingController passwordcontroller =
      TextEditingController();
  final TextEditingController conformedpasswordcontroller =
      TextEditingController();
  final TextEditingController userNamecontroller =
      TextEditingController();
  final void Function()? ontap;

  void register(BuildContext context) async {
    final auth = Authentication();
    if (conformedpasswordcontroller.text == passwordcontroller.text) {
      try {
        auth.createdAccount(
          userNamecontroller.text,
          Emailcontroller.text,
          passwordcontroller.text,
          context,
        );
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) =>
              AlertDialog(title: Text(e.toString())),
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(title: Text('Password do not Match!')),
      );
    }
  }

  RegisterPage({super.key, required this.ontap});
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
                'Lets`s create account for you',
                style: TextStyle(
                  fontSize: 17,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(height: 30),

              MyTextFeilds(
                hinttext: 'Name',
                obsecurtext: false,
                controller: userNamecontroller,
              ),
              SizedBox(height: 10),
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
              SizedBox(height: 10),
              MyTextFeilds(
                hinttext: 'Confirm password',
                obsecurtext: false,
                controller: conformedpasswordcontroller,
              ),

              SizedBox(height: 30),
              MyButton(
                text: 'Register',
                ontap: () => register(context),
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Allready have an account? ',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  GestureDetector(
                    onTap: ontap,
                    child: Text(
                      'Login now',
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
