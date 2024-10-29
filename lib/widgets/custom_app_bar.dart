import 'package:echo_chamber/pages/login_page.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Padding(padding: EdgeInsets.only(left: 20),
            child: Text('Inicio')
          ),
          const Padding(padding: EdgeInsets.only(left: 20),
              child: Text('Mapa')
          ),
          const Padding(padding: EdgeInsets.only(left: 20),
              child: Text('Descubrir')
          ),
          const Padding(padding: EdgeInsets.only(left: 20),
              child: Text('Buscar')
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.pushNamed(context, LoginPage.route);
            },
              child: const Text('Iniciar sesión'),
          )
        ],
      ),
    );
  }
}
