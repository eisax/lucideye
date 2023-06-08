import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucideye/constants/colors.dart';
// ignore: depend_on_referenced_packages
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:lucideye/shared_components/placesinputdialog.dart';
import 'package:lucideye/shared_components/searchbar.dart';
import 'package:open_route_service/open_route_service.dart';
import 'package:location/location.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:geocoder/geocoder.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final apiKey = "5b3ce3597851110001cf62482ba1a7913a98486e919d38677db5c78f";
  late LatLng startPoint = LatLng(-17.8250, 31.0488);
  late LatLng endPoint = LatLng(-17.3594, 30.1815);
  late LatLng centerLatLng;
  final Location _locationService = Location();
  late final MapController _mapController;
  TextEditingController _searchcontroller = TextEditingController();
  LocationData? _currentLocation;
  late LatLng currentLatLng;
  List<LatLng> routePoints = [];
  List<Address> _addresses = [];
  bool _liveUpdate = false;
  bool _permission = false;
  String? _serviceError = '';
  bool mapLoading = false;
  int interActiveFlags = InteractiveFlag.all;
  double zoomLevel = 17;
  final FitBoundsOptions options =
      const FitBoundsOptions(padding: EdgeInsets.all(0));

  void initLocationService() async {
    await _locationService.changeSettings(
      accuracy: LocationAccuracy.high,
      interval: 1000,
    );
    LocationData? location;
    bool serviceEnabled;
    bool serviceRequestResult;

    try {
      //
      serviceEnabled = await _locationService.serviceEnabled();
      if (serviceEnabled) {
        final permission = await _locationService.requestPermission();
        _permission = permission == PermissionStatus.granted;

        if (_permission) {
          location = await _locationService.getLocation();
          _currentLocation = location;
          _locationService.onLocationChanged
              .listen((LocationData result) async {
            if (mounted) {
              setState(() {
                _currentLocation = result;
                // If Live Update is enabled, move map center
                if (_liveUpdate) {
                  _mapController.move(
                      LatLng(_currentLocation!.latitude!,
                          _currentLocation!.longitude!),
                      _mapController.zoom);
                }
              });
            }
          });
        }
      } else {
        serviceRequestResult = await _locationService.requestService();
        if (serviceRequestResult) {
          initLocationService();
          return;
        }
      }

      print("=======================================LOCATION DONE");
      print(_currentLocation);
    } on PlatformException catch (e) {
      //
      debugPrint(e.toString());
      if (e.code == 'PERMISSION_DENIED') {
        _serviceError = e.message;
      } else if (e.code == 'SERVICE_STATUS_ERROR') {
        _serviceError = e.message;
      }
      location = null;
    }
  }

  void _refreshMap() {
    initLocationService();
    _getRoutePoints();
  }

  Future<void> _getRoutePoints() async {
    final OpenRouteService client = OpenRouteService(apiKey: apiKey);
    try {
      final List<ORSCoordinate> routeCoordinates =
          await client.directionsRouteCoordsGet(
        startCoordinate: ORSCoordinate(
            latitude: currentLatLng.latitude.toDouble(),
            longitude: currentLatLng.longitude.toDouble()),
        endCoordinate: ORSCoordinate(
            latitude: endPoint.latitude.toDouble(),
            longitude: endPoint.longitude.toDouble()),
      );
      routeCoordinates.forEach(print);
      routePoints = routeCoordinates
          .map(
              (coordinate) => LatLng(coordinate.latitude, coordinate.longitude))
          .toList();
      print("=======================================ROUTE POINTS DONE");
    } catch (e) {
      print("=======================================ROUTE POINTS FAILED");
    }
  }

  @override
  void initState() {
    _mapController = MapController();
    initLocationService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double displayWidth = MediaQuery.of(context).size.width;
    double displayHeight = MediaQuery.of(context).size.height;

    if (_currentLocation != null) {
      currentLatLng =
          LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!);
      setState(() {
        centerLatLng = currentLatLng;
      });
    } else {
      initLocationService();
      // currentLatLng = LatLng(0, 0);
    }
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await _getRoutePoints();
        },
        child: SingleChildScrollView(
          child: Container(
              width: displayWidth,
              height: displayHeight,
              color: Colors.white,
              child: Stack(
                children: [
                  //MY MAP STAFF
                  Padding(
                    padding: const EdgeInsets.all(0),
                    child: Column(
                      children: [
                        Flexible(
                          child: _currentLocation != null && !mapLoading
                              ? FlutterMap(
                                  options: MapOptions(
                                    center: currentLatLng,
                                    zoom: zoomLevel,
                                    onTap: (tapPosition, point) {
                                      setState(() {
                                        debugPrint('onTap');
                                        _getRoutePoints();
                                      });
                                    },
                                  ),
                                  children: [
                                    TileLayer(
                                      urlTemplate:
                                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                      userAgentPackageName:
                                          'dev.fleaflet.flutter_map.example',
                                      subdomains: ['a', 'b', 'c'],
                                    ),
                                    PolylineLayer(
                                      polylines: [
                                        Polyline(
                                            points: routePoints,
                                            strokeWidth: 5,
                                            color: mainColor),
                                      ],
                                    ),
                                    MarkerLayer(
                                      markers: [
                                        Marker(
                                          width: displayHeight * 0.12,
                                          height: displayHeight * 0.12,
                                          point: centerLatLng,
                                          builder: (ctx) => Container(
                                            width: displayHeight * 0.12,
                                            height: displayHeight * 0.12,
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.green.withOpacity(0.5),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      displayHeight * 0.1),
                                            ),
                                            child: Center(
                                              child: Stack(
                                                children: [
                                                  Container(
                                                    width:
                                                        displayHeight * 0.025,
                                                    height:
                                                        displayHeight * 0.025,
                                                    decoration: BoxDecoration(
                                                        color: Colors.green,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                displayHeight *
                                                                    0.05),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: greyd
                                                                .withOpacity(
                                                                    0.5),
                                                            spreadRadius: 2,
                                                            blurRadius: 4,
                                                            offset:
                                                                const Offset(
                                                                    0, 3),
                                                          ),
                                                        ],
                                                        border: Border.all(
                                                          color: Colors.white,
                                                          width: 1,
                                                        )),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Marker(
                                          width: displayHeight * 0.12,
                                          height: displayHeight * 0.12,
                                          point: endPoint,
                                          builder: (ctx) => locationPoint(
                                              displayHeight: displayHeight),
                                        ),
                                      ],
                                    )
                                  ],
                                )
                              : Center(
                                  child: Container(
                                      width: 50,
                                      height: 50,
                                      child: const CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  greyd))),
                                ),
                        ),
                      ],
                    ),
                  ),
                  //==============BUTTONS, SEARCH BAR, MAP DETAILS AND ALL STAFF
                  Positioned(
                    child: SafeArea(
                      child: Container(
                        width: displayWidth,
                        height: displayHeight,
                        child: Column(
                          children: [
                            Container(
                              width: displayWidth,
                              padding:
                                  const EdgeInsets.only(left: 20, right: 20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    onPressed: () {},
                                    icon: const Icon(
                                      Icons.menu,
                                      size: 30,
                                    ),
                                  ),
                                  Container(
                                    width: 35,
                                    height: 35,
                                    decoration: BoxDecoration(
                                        color: mainColor,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            spreadRadius: 2,
                                            blurRadius: 5,
                                            offset: const Offset(0, 3),
                                          ),
                                        ]),
                                    child: IconButton(
                                        onPressed: () {
                                          _refreshMap();
                                        },
                                        icon: const Icon(
                                          Icons.refresh,
                                          size: 15,
                                          color: primaryColor,
                                        )),
                                  )
                                ],
                              ),
                            ),
                            //SEARCH BAR
                            Container(
                              width: displayWidth,
                              height: displayHeight * 0.4,
                              padding: EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  CustomTextInput(
                                      startIcon: Icons.location_on,
                                      endIcon: Icons.mic,
                                      controller: _searchcontroller,
                                      onChanged: (value) async {
                                        if (value.isNotEmpty) {
                                          print('Searching for: $value');
                                          String query = _searchcontroller.text;
                                          List<Address> addresses =
                                              await Geocoder.local
                                                  .findAddressesFromQuery(
                                                      query);
                                          setState(() {
                                            _addresses = addresses;
                                          });
                                          print(_addresses);
                                        }
                                      }),
                                  _searchcontroller.text.isNotEmpty
                                      ? Container(
                                          margin: EdgeInsets.only(top: 1),
                                          width: displayWidth * 0.75,
                                          height: displayHeight * 0.2,
                                          decoration: BoxDecoration(
                                              color: white.withOpacity(0.75),
                                              borderRadius:
                                                  const BorderRadius.only(
                                                      bottomLeft:
                                                          Radius.circular(5),
                                                      bottomRight:
                                                          Radius.circular(5)),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.5),
                                                  spreadRadius: 2,
                                                  blurRadius: 5,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ]),
                                          child:
                                              _searchcontroller.text.isNotEmpty
                                                  ? _buildResults()
                                                  : Container(),
                                        )
                                      : Container(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  //==============BUTTONS, SEARCH BAR, MAP DETAILS AND ALL STAFF
                ],
              )),
        ),
      ),
    );
  }

  Widget _buildResults() {
    if (_addresses.isEmpty) {
      return const Center(
        child: Text(
          'searching',
          style: TextStyle(
              fontSize: 10, color: greyc, fontWeight: FontWeight.bold),
        ),
      );
    } else {
      return ListView.builder(
        itemCount: 1,
        itemBuilder: (BuildContext context, int index) {
          final address = _addresses[index];
          return ListTile(
            title: Text(
              address.addressLine,
              style: const TextStyle(color: mainColor, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${address.locality}, ${address.adminArea} ${address.postalCode}, ${address.countryName}',
            ),
            onTap: () {
              setState(() {
                endPoint = LatLng(address.coordinates.latitude,
                    address.coordinates.longitude);
              });
              if (_currentLocation != null) {
                _getRoutePoints();
              }
            },
          );
        },
      );
    }
  }

  Widget locationPoint({required double displayHeight}) {
    return Container(
      width: displayHeight * 0.12,
      height: displayHeight * 0.12,
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.5),
        borderRadius: BorderRadius.circular(displayHeight * 0.1),
      ),
      child: Center(
        child: Stack(
          children: [
            Container(
              width: displayHeight * 0.025,
              height: displayHeight * 0.025,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(displayHeight * 0.05),
                boxShadow: [
                  BoxShadow(
                    color: greyd.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 4,
                    offset: const Offset(0, 3),
                  ),
                ],
                border: Border.all(
                  color: Colors.white,
                  width: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
