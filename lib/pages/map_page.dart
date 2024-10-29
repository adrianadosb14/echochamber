import 'package:dio/dio.dart';
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
  LocationData? currentLocation;

  void initCurrentLocation() async {
    if (!locationInitialized) {
      final Location location = Location();
      LocationData locationData = await location.getLocation();
      currentLocation = locationData;
      setState(() {
        locationInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    initCurrentLocation();

    return locationInitialized ? Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const CustomAppBar(),
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(currentLocation?.latitude??40.416775, currentLocation?.longitude??-3.703790), // Center the map over London
                initialZoom: 9.2,
                onTap: (post, coords) async {

                  http.Response res = await http.get(Uri.parse('https://nominatim.openstreetmap.org/reverse?lat=${coords.latitude}&lon=${coords.longitude}'));
                  final document =  XmlDocument.parse(res.body);

                   XmlElement? closestAddress = document.findAllElements('result').first;

                  await showDialog<void>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Elegir dirección'),
                        content: Text(
                          'Coordenadas\n'
                              'Longitud: ${coords.longitude}\n'
                              'Latitud: ${coords.latitude}\n'
                              'Dirección: ${closestAddress.innerText}'
                        ),
                        actions: <Widget>[
                          TextButton(
                            style: TextButton.styleFrom(
                              textStyle: Theme.of(context).textTheme.labelLarge,
                            ),
                            child: const Text('Cancelar'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              textStyle: Theme.of(context).textTheme.labelLarge,
                            ),
                            child: const Text('Aceptar'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
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
                const RichAttributionWidget( // Include a stylish prebuilt attribution widget that meets all requirments
                  attributions: [
                    TextSourceAttribution(
                      'OpenStreetMap contributors',
                     // onTap: () => launchUrl(Uri.parse('https://openstreetmap.org/copyright')), // (external)
                    ),
                    // Also add images...
                  ],
                ),
              ],
            )
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
            onPressed: () async {

        }),
    ) : const CircularProgressIndicator();
  }
}
