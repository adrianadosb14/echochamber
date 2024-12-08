import 'package:echo_chamber/models/event.dart';
import 'package:echo_chamber/pages/event_page.dart';
import 'package:echo_chamber/util/util.dart';
import 'package:echo_chamber/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  static String route = '/search';

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  bool eventsInitialized = false;
  List<Event> events = [];
  final TextEditingController searchController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;

  initializeEvents() async {
    if (!eventsInitialized) {
      events = await Event.getEvents(searchTerm: searchController.text, startDate: startDate, endDate: endDate);
      setState(() {
        eventsInitialized = true;
      });
    }
  }

  List<Widget> getEvents() {
    List<Widget> list = [];
    for (int i = 0; i < events.length; i++) {
      list.add(ExpansionTile(
          title: Text(events[i].title!),
        children: [
          Text(events[i].description!),
          ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, EventPage.route, arguments: events[i]);
              },
              child: const Text('Ir a página del evento'))
        ],
      ));
    }
    return list;
  }


  @override
  Widget build(BuildContext context) {
    initializeEvents();
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              const CustomAppBar(),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: SizedBox(
                        width: 300,
                        child: TextField(
                          onSubmitted: (value) {
                            eventsInitialized = false;
                            initializeEvents();
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Buscar...',
                          ),
                          controller: searchController,
                        ),
                      ),
                    ),
                    IconButton(
                        onPressed: () {
                          eventsInitialized = false;
                          initializeEvents();
                        },
                        icon: const Icon(Icons.search))
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(onPressed: () async {
                    startDate = await Util.showDateTimePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate:  DateTime.now().subtract(const Duration(days: 365 * 2)),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                    );
                    setState(() {

                    });
                  },
                      child: Text(
                          'Fecha de inicio: ${Util.dateTimeToString(startDate??DateTime.now())}')),
                  TextButton(onPressed: () async {
                    endDate = await Util.showDateTimePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now().subtract(const Duration(days: 365 * 2)),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                    );
                    setState(() {

                    });
                  }, child:  Text('Fecha de fin: ${Util.dateTimeToString(endDate??DateTime.now())}')),
                ],
              ),
              ...getEvents()
            ],
          ),
        ),
      ),
    );
  }
}
