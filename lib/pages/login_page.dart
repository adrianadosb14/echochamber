import 'package:echo_chamber/common/config.dart';
import 'package:echo_chamber/models/user.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  static String route = '/login';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void disposeControllers() {
    emailController.dispose();
    passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(child: Container(
            color: Theme.of(context).colorScheme.primary,
            child: const Center(
              child: Text('Echo\nChamber', style: TextStyle(
                fontSize: 70,
                color: Colors.white
              ),),
            ),
          )),
          Form(
            child: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width/2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: SizedBox(
                        width: 500,
                        child: TextField(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Email',
                          ),
                          controller: emailController,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SizedBox(
                        width: 500,
                        child: TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Password',
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                        onPressed: () async {
                          dynamic response = await User.loginUser(email: emailController.text, password: passwordController.text);
                          if (response[0]['o_last_access'] != null) {
                            Config.loginUser = User()
                                ..userId = response[0]['o_user_id']
                                ..username = response[0]['o_username'];
                            Navigator.pop(context);
                          }
                        },
                        child: const Text('Acceder'))
                  ],
                      ),
              ),
            )),
        ],
      ),
    );
  }
}
