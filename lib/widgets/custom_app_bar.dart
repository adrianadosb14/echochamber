import 'package:echo_chamber/common/config.dart';
import 'package:echo_chamber/pages/home_page.dart';
import 'package:echo_chamber/pages/login_page.dart';
import 'package:echo_chamber/pages/map_page.dart';
import 'package:echo_chamber/pages/search_page.dart';
import 'package:echo_chamber/pages/tag_page.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatefulWidget {
  final Widget? leading;
  const CustomAppBar({this.leading, super.key});

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

enum ConfigButton {
  tags('Etiquetas', '/tags');

  const ConfigButton(this.label, this.route);
  final String label;
  final String route;
}

class _CustomAppBarState extends State<CustomAppBar> {
  final TextEditingController configController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 65,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (widget.leading != null) widget.leading!,
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: TextButton(
              onPressed: () async {
                await Navigator.pushNamed(context, HomePage.route);
              },
              child: const Text('Inicio'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: TextButton(
              onPressed: () async {
                await Navigator.pushNamed(context, MapPage.route);
              },
              child: const Text('Mapa'),
            ),
          ),
          Padding(
              padding: const EdgeInsets.only(left: 20),
              child: TextButton(
                  onPressed: () async {
                    await Navigator.pushNamed(context, SearchPage.route);
                  },
                  child: const Text('Buscar'))),
          if (Config.loginUser?.type == 0)
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: DropdownMenu<ConfigButton>(
                initialSelection: ConfigButton.tags,
                controller: configController,
                requestFocusOnTap: true,
                label: const Text('Configuración'),
                onSelected: (ConfigButton? button) async {
                  await Navigator.pushNamed(context, button!.route);
                },
                dropdownMenuEntries: ConfigButton.values
                    .map<DropdownMenuEntry<ConfigButton>>(
                        (ConfigButton button) {
                  return DropdownMenuEntry<ConfigButton>(
                    value: button,
                    label: button.label,
                  );
                }).toList(),
              ),
            ),
          Config.loginUser == null
              ? OutlinedButton(
                  onPressed: () async {
                    dynamic loginOk =
                        await Navigator.pushNamed(context, LoginPage.route);
                    if (loginOk == true) {
                      setState(() {});
                    }
                  },
                  child: const Text('Iniciar sesión'),
                )
              : Text('Sesión iniciada como ${Config.loginUser?.username}')
        ],
      ),
    );
  }
}
