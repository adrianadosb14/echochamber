import 'package:dio/dio.dart';
import 'package:echo_chamber/common/config.dart';
import 'package:echo_chamber/models/event.dart';
import 'package:echo_chamber/pages/event_page.dart';
import 'package:echo_chamber/util/util.dart';
import 'package:echo_chamber/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});
  static String route = '/map';

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  bool locationInitialized = false;
  bool eventsInitialized = false;
  LocationData? currentLocation;
  LatLng? center;
  List<Event> events = [];
  double radius = 1000;

  void initCurrentLocation() async {
    if (!locationInitialized) {
      final Location location = Location();
      LocationData locationData = await location.getLocation();
      currentLocation = locationData;
      center = LatLng(currentLocation?.latitude??40.416775, currentLocation?.longitude??-3.703790);
      setState(() {
        locationInitialized = true;
      });
    }
  }

  void initEvents() async {
    if (!eventsInitialized && locationInitialized) {
      events = [];
      events = await Event.getEvents(latitude: currentLocation?.latitude, longitude: currentLocation?.longitude, radius: radius);
      if (events.isNotEmpty) {
        setState(() {
          eventsInitialized = true;
        });
      }
    }
  }

  List<Marker> getMarkers() {
    List<Marker> list = [];
    if (eventsInitialized) {
      for (int i = 0; i < events.length; i++) {
        list.add(Marker(
          point: LatLng(events[i].latitude!, events[i].longitude!),
          child: Tooltip(
            message: 'Título: ${events[i].title}\n'
                'Descripción: ${events[i].description}\n'
                'Inicio: ${Util.dateTimeToString(events[i].startDate!)}\n'
                'Final: ${Util.dateTimeToString(events[i].endDate!)}',
            child: IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, EventPage.route, arguments: events[i]);
                },
                icon: const Icon(Icons.location_on, color: Colors.redAccent)),
          )
        ));
      }
    }
    return list;
  }


  @override
  Widget build(BuildContext context) {
    initCurrentLocation();
    initEvents();
    return locationInitialized ? Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const CustomAppBar(),
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: center!,
                initialZoom: 9.2,
                onTap: (post, coords) async {

                  http.Response res = await http.get(Uri.parse('https://nominatim.openstreetmap.org/reverse?lat=${coords.latitude}&lon=${coords.longitude}'));
                  final document =  XmlDocument.parse(res.body);

                   XmlElement? closestAddress = document.findAllElements('result').first;

                  await showDialog<void>(
                    context: context,
                    builder: (BuildContext context) {
                      DateTime? startDate = DateTime.now();
                      DateTime? endDate = DateTime.now();

                      final TextEditingController titleController = TextEditingController();
                      final TextEditingController descriptionController = TextEditingController();

                      return StatefulBuilder(
                        builder: (context, setStateDialog) {
                          return AlertDialog(
                            title: const Text('Elegir dirección'),
                            content: IntrinsicHeight(
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text(
                                        '¿Deseas crear un nuevo evento en la siguiente dirección?\n${closestAddress.innerText}'
                                    ),
                                  ),
                                  TextButton(onPressed: () async {
                                    startDate = await Util.showDateTimePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.now().add(
                                          const Duration(days: 365 * 2)),
                                    );

                                    setStateDialog(() {

                                    });
                                  },
                                      child: Text('Fecha de inicio: ${Util.dateTimeToString(startDate??DateTime.now())}')),
                                  TextButton(onPressed: () async {
                                    endDate = await Util.showDateTimePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.now().add(
                                          const Duration(days: 365 * 2)),
                                    );
                                    setStateDialog(() {

                                    });
                                  }, child:  Text('Fecha de fin: ${Util.dateTimeToString(endDate??DateTime.now())}')),
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: SizedBox(
                                      width: 300,
                                      child: TextField(
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: 'Título',
                                        ),
                                        controller: titleController,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: SizedBox(
                                      width: 300,
                                      child: TextField(
                                        controller: descriptionController,
                                        maxLines: null,
                                        keyboardType: TextInputType.multiline,
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: 'Descripción',
                                        ),
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
                                 bool ok = await Event.createEvent(
                                     userId: Config.loginUser!.userId!,
                                     title: titleController.text,
                                     description: descriptionController.text,
                                     startDate: startDate,
                                     endDate: endDate,
                                     latitude: coords.latitude,
                                     longitude: coords.longitude
                                 );
                                 if (ok == true) {
                                   setStateDialog(() {});
                                   print('evento creado correctamente');
                                 }
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        }
                      );
                    },
                  );
                }
              ),
              children: [
                TileLayer( // Display map tiles from any source
                  tileProvider: CancellableNetworkTileProvider(
                    dioClient: Dio(),
                  ),
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', // OSMF's Tile Server
                  userAgentPackageName: 'com.example.app',
                  // And many more recommended properties!
                ),
                CircleLayer(circles: [
                  CircleMarker(
                      point: LatLng(currentLocation?.latitude??40.416775, currentLocation?.longitude??-3.703790),
                      radius: radius,
                      useRadiusInMeter: true,
                      color: Colors.purple.withOpacity(.2),
                      borderColor: Colors.purple,
                      borderStrokeWidth: 2
                  )
                ]),
                MarkerLayer(markers: getMarkers()),
                const RichAttributionWidget( // Include a stylish prebuilt attribution widget that meets all requirments
                  attributions: [
                    TextSourceAttribution(
                      'OpenStreetMap contributors',
                     // onTap: () => launchUrl(Uri.parse('https://openstreetmap.org/copyright')), // (external)
                    ),
                  ],
                ),
              ],
            )
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final TextEditingController radiusController = TextEditingController();

            await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Ajustes'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: SizedBox(
                        width: 300,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          maxLines: 1,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Radio (en metros)',
                          ),
                          controller: radiusController,
                        ),
                      ),
                    ),
                  ],
                ),
                actions: <Widget>[
                  ElevatedButton(
                    child: const Text('Aceptar'),
                    onPressed: () {
                      setState(() {
                        radius = double.parse(radiusController.text);
                        events = [];
                        eventsInitialized = false;
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            }
            );
          },
        child: const Icon(Icons.settings),
      ),
    ) : const CircularProgressIndicator();
  }
}
