import 'package:echo_chamber/common/config.dart';
import 'package:echo_chamber/models/tag.dart';
import 'package:echo_chamber/util/util.dart';
import 'package:echo_chamber/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class TagPage extends StatefulWidget {
  const TagPage({super.key});
  static String route = '/tags';

  @override
  State<TagPage> createState() => _TagPageState();
}

class _TagPageState extends State<TagPage> {
  bool tagsInitialized = false;
  List<Tag> tags = [];
  Color pickerColor = const Color(0xff443a49);
  Color selectedColor = const Color(0xff443a49);

  initializeTags() async {
    if (!tagsInitialized) {
      tags = await Tag.getAllTags();
      setState(() {
        tagsInitialized = true;
      });
    }
  }

  List<Widget> getTags() {
    List<Widget> list = [];
    for (int i = 0; i < tags.length; i++) {
      Color bgColor = Color(int.parse(tags[i].color!));
      list.add( Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(tags[i].name!, style: TextStyle(color: bgColor.textColorFromBg())),
          tileColor: bgColor,
        ),
      ));
    }
    return list;
  }

  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }


  @override
  Widget build(BuildContext context) {
    initializeTags();
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const CustomAppBar(),
            ...getTags()
          ],
        ),
      ),
      floatingActionButton:FloatingActionButton(
          onPressed: () async {
            final TextEditingController nameController = TextEditingController();

            await showDialog(context: context, builder: (context) {
              return StatefulBuilder(
                builder: (context, _setState) {
                  return AlertDialog(
                  content: IntrinsicHeight(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: SizedBox(
                            width: 300,
                            child: TextField(
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Nombre',
                              ),
                              controller: nameController,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            MaterialButton(
                                child: const Text('Escoger color'),
                                onPressed: () async {
                                  await showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: const Text('Escoger color'),
                                          content: SingleChildScrollView(
                                            child: MaterialPicker(
                                              pickerColor: pickerColor,
                                              onColorChanged: changeColor,
                                            ),
                                          ),
                                          actions: <Widget>[
                                            ElevatedButton(
                                              child: const Text('Aceptar'),
                                              onPressed: () {
                                                _setState(() => selectedColor = pickerColor);
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      }
                                  );
                                }),
                            Icon(Icons.circle, color: selectedColor)
                          ],
                        )
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      style: TextButton.styleFrom(
                        textStyle: Theme
                            .of(context)
                            .textTheme
                            .labelLarge,
                      ),
                      child: const Text('Cancelar'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        textStyle: Theme
                            .of(context)
                            .textTheme
                            .labelLarge,
                      ),
                      child: const Text('Aceptar'),
                      onPressed: () async {
                        dynamic ok = await Tag.create(name: nameController.text, color: selectedColor.value.toString());
                        print(ok);
                        if (ok == true) {
                          setState(() {
                            tags = [];
                            tagsInitialized = false;
                          });
                          print('Etiqueta creada correctamente');
                        }
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );}
              );
            });
          },
          child: const Icon(Icons.add)),
    );
  }
}
