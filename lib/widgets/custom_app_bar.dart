import 'package:echo_chamber/common/config.dart';
import 'package:echo_chamber/pages/home_page.dart';
import 'package:echo_chamber/pages/login_page.dart';
import 'package:echo_chamber/pages/map_page.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatefulWidget {
  final Widget? leading;
  const CustomAppBar({this.leading, super.key});

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 65,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (widget.leading != null) widget.leading!,
          Padding(padding: const EdgeInsets.only(left: 20),
            child: TextButton(
              onPressed: () async {
                await Navigator.pushNamed(context, HomePage.route);
              },
              child: const Text('Inicio'),
            ),
          ),
          Padding(padding: const EdgeInsets.only(left: 20),
            child: TextButton(
              onPressed: () async {
                await Navigator.pushNamed(context, MapPage.route);
              },
              child: const Text('Mapa'),
            ),
          ),
          const Padding(padding: EdgeInsets.only(left: 20),
              child: Text('Descubrir')
          ),
          const Padding(padding: EdgeInsets.only(left: 20),
              child: Text('Buscar')
          ),
          Config.loginUser == null ? OutlinedButton(
            onPressed: () async {
              dynamic loginOk = await Navigator.pushNamed(context, LoginPage.route);
              if (loginOk == true) {
                setState(() {

                });
              }
            },
            child: const Text('Iniciar sesión'),
          ) : Text('Sesión iniciada como ${Config.loginUser?.username}')
        ],
      ),
    );
  }
}
