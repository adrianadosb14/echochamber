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
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool registerMode = false;
  bool type = false;

  void disposeControllers() {
    emailController.dispose();
    passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    emailController.text = 'adrianadosb14@gmail.com';
    passwordController.text = 'raccoon123';
    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
              child: Container(
            color: Theme.of(context).colorScheme.primary,
            child: const Center(
              child: Text(
                'Echo\nChamber',
                style: TextStyle(fontSize: 70, color: Colors.white),
              ),
            ),
          )),
          registerMode
              ? Form(
                  child: Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width / 2,
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
                          padding: const EdgeInsets.all(10),
                          child: SizedBox(
                            width: 500,
                            child: TextField(
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Nombre de usuario',
                              ),
                              controller: usernameController,
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
                                labelText: 'Contraseña',
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: SizedBox(
                            width: 500,
                            child: IntrinsicWidth(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('Usuario'),
                                  Switch(
                                    value: type,
                                    onChanged: (bool value) {
                                      // This is called when the user toggles the switch.
                                      setState(() {
                                        type = value;
                                      });
                                    },
                                  ),
                                  const Text('Organizador'),
                                ],
                              ),
                            ),
                          ),
                        ),
                        TextButton(
                            onPressed: () async {
                              dynamic response = await User.createUser(
                                  type: type ? 2 : 1,
                                  email: emailController.text,
                                  username: usernameController.text,
                                  password: passwordController.text);
                              if (response['o_user_id'] != null) {
                                Config.loginUser = User()
                                  ..userId = response['o_user_id']
                                  ..username = usernameController.text
                                  ..type = type ? 2 : 1;
                                Navigator.pop(context, true);
                              }
                            },
                            child: const Text('Crear cuenta')),
                        TextButton(
                            onPressed: () {
                              setState(() {
                                registerMode = !registerMode;
                              });
                            },
                            child: Center(child: Text(registerMode ? '¿Ya tienes una cuenta?' : '¿No tienes una cuenta?'))),
                      ],
                    ),
                  ),
                ))
              : Form(
                  child: Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width / 2,
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
                                labelText: 'Contraseña',
                              ),
                            ),
                          ),
                        ),
                        TextButton(
                            onPressed: () async {
                              dynamic response = await User.loginUser(
                                  email: emailController.text,
                                  password: passwordController.text);
                              if (response[0]['o_last_access'] != null) {
                                Config.loginUser = User()
                                  ..userId = response[0]['o_user_id']
                                  ..username = response[0]['o_username']
                                  ..type = response[0]['o_type'];
                                Navigator.pop(context, true);
                              }
                            },
                            child: const Text('Acceder')),
                        TextButton(
                            onPressed: () {
                              setState(() {
                                registerMode = !registerMode;
                              });
                            },
                            child: Center(
                              child: Text(
                                  registerMode ? '¿Ya tienes una cuenta?' : '¿No tienes una cuenta?',
                              ),
                            )),
                      ],
                    ),
                  ),
                )),
        ],
      ),
    );
  }
}
