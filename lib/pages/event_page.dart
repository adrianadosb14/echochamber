import 'package:echo_chamber/common/config.dart';
import 'package:echo_chamber/models/event.dart';
import 'package:echo_chamber/models/event_like.dart';
import 'package:echo_chamber/models/post.dart';
import 'package:echo_chamber/models/tag.dart';
import 'package:echo_chamber/util/util.dart';
import 'package:echo_chamber/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

class EventPage extends StatefulWidget {
  static String route = '/event';

  const EventPage({super.key});

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  late Event event;
  bool postsInitialized = false;
  bool tagsInitialized = false;
  bool likesInitialized = false;

  List<Post> posts = [];
  List<Tag> tags = [];
  List<EventLike> likes = [];

  void initPosts() async {
    if (!postsInitialized) {
      posts = [];
      posts = await Post.getPosts(event.eventId!);

      setState(() {
        postsInitialized = true;
      });
    }
  }

  void initTags() async {
    if (!tagsInitialized) {
      tags = [];
      tags = await Tag.getEventTags(event.eventId!);

      setState(() {
        tagsInitialized = true;
      });
    }
  }

  void initLikes() async {
    if (!likesInitialized) {
      likes = [];
      likes = await EventLike.getEventLikes(event.eventId!);

      setState(() {
        likesInitialized = true;
      });
    }
  }

  List<Widget> getTags() {
    List<Widget> list = [];
    for (int i = 0; i < tags.length; i++) {
      Color bgColor = Color(int.parse(tags[i].color!));
      list.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Chip(label: Text(tags[i].name!, style: TextStyle(color: bgColor.textColorFromBg())), backgroundColor: bgColor),
      ));
    }
    list.add(
        InkWell(
          child: const Chip(
              label: Text('Añadir nueva etiqueta'),
              avatar: Icon(Icons.add)
          ),
          onTap: () async {
            List<Tag> tagList = [];
            tagList = await Tag.getAllTags();
            await showDialog(context: context, builder: (context) {
              return AlertDialog(
                content: Wrap(
                  children: tagList.map((Tag tag) {
                    Color bgColor = Color(int.parse(tag.color!));
                    return InkWell(
                      child: Chip(label: Text(tag.name!, style: TextStyle(color: bgColor.textColorFromBg())), backgroundColor: bgColor),
                      onTap:  () async {
                        dynamic ok = await tag.addToEvent(eventId: event.eventId!);
                        if (ok == true) {
                          setState(() {
                            tags = [];
                            tagsInitialized = false;
                          });
                        }
                      },
                    );
                  }).toList()
                ),
              );
            });
          },));
    return list;
  }

  List<Widget> getCommentList() {
    List<Widget> list = [];
    list.add(ListTile(
      leading: const Icon(Icons.add),
      onTap: () async {
        await showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            final TextEditingController commentController = TextEditingController();

            return AlertDialog(
              title: const Text('Añadir nuevo comentario'),
              content: IntrinsicHeight(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: SizedBox(
                        width: 300,
                        child: TextField(
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Comentario',
                          ),
                          controller: commentController,
                        ),
                      ),
                    ),
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
                    bool ok = await Post.create(
                        userId: Config.loginUser!.userId!,
                        eventId: event.eventId!,
                        content: commentController.text
                    );
                    if (ok == true) {
                      setState(() {
                        postsInitialized = false;
                      });
                      print('post añadido correctamente');
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
      title: const Text('Añadir nuevo comentario'),
    ));
    for (int i = 0; i < posts.length; i++) {
      list.add(Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: posts[i].username,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)
                      ),
                      TextSpan(
                          text: '\n${posts[i].content}',
                          style: const TextStyle(fontSize: 12.0)
                      )
                    ]
                  ),
                )
              ),
            ),
          )
        ],
      ));
      list.add(const Divider());
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    event = ModalRoute.of(context)!.settings.arguments as Event;

    initPosts();
    initTags();
    initLikes();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              CustomAppBar(leading: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.primary,))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                child: Text(
                  event.title??'',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
                ),
              ),
              Wrap(
                children:[ ...getTags()],
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Inicio: ${Util.dateTimeToString(event.startDate!)}\n'
                      'Final: ${Util.dateTimeToString(event.endDate!)}',
                  style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12.0, bottom: 12.0, left: 70.0, right: 70.0),
                child: Text(event.description??''),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Image.network(
                  'https://images.unsplash.com/photo-1459749411175-04bf5292ceea?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                  height: MediaQuery.of(context).size.height / 1.8,
                  fit: BoxFit.fill,
                ),
              ),
              InkWell(
                onTap: () async {
                  if (Config.loginUser != null) {
                  print(event.eventId!);
                  if (likes.where((like) => like.userId == Config.loginUser?.userId!).toList().isEmpty) {
                    await EventLike.create(userId: Config.loginUser!.userId!, eventId: event.eventId!);
                  } else {
                    await likes.where((like) => like.userId == Config.loginUser?.userId!).toList().first.remove();
                  }
                  setState(() {
                    likes = [];
                    likesInitialized = false;
                  });
                  } else {
                    print('NO ESTÁS LOGUEADO');
                  }
                },
                child: Chip(
                    label: Text('Likes: ${likes.length}'),
                    avatar: const Icon(Icons.thumb_up)
                ),
              ),
              FractionallySizedBox(
                widthFactor: .8,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ...getCommentList()
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
