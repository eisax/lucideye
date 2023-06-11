import 'dart:convert';
import 'dart:math' as math;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:clay_containers/clay_containers.dart';
import 'package:lucideye/features/view/assistantscreen.dart';
import '../../constants/colors.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:open_route_service/open_route_service.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:http/http.dart' as http;

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  final apiKey = "5b3ce3597851110001cf62482ba1a7913a98486e919d38677db5c78f";
  late LatLng startPoint = LatLng(-17.8250, 31.0488);
  final LatLng endPoint = LatLng(-17.3594, 30.1815);
  final Location _locationService = Location();
  late final MapController _mapController;
  LocationData? _currentLocation;
  late LatLng currentLatLng;
  List<LatLng> routePoints = [];
  bool _liveUpdate = false;
  bool _permission = false;
  String? _serviceError = '';
  int interActiveFlags = InteractiveFlag.all;
  double zoomLevel = 15;
  List<Marker> assistantMarkers = [];
  double smallestDistance = double.infinity;
  String closestAssistantEmail = '';
  
  late LatLng chosenLocationPointCoodinates;
  String blindUserKey = "";
  late List<Map<String, dynamic>> availableAssistants = [];
  double degrees2Radians = 0.017453292519943295;
  double radians(double degrees) => degrees * degrees2Radians;

  String generateRandomKey() {
    var random = Random();
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return String.fromCharCodes(
      Iterable.generate(
        10,
        (_) => chars.codeUnitAt(
          random.nextInt(chars.length),
        ),
      ),
    );
  }

  void showAlert(BuildContext context, double displayWidth) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              content: Container(
                width: displayWidth * 0.5,
                height: displayWidth * 0.4,
                decoration: BoxDecoration(
                    color: white, borderRadius: BorderRadius.circular(15)),
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        width: displayWidth * 0.55,
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: mainColor,
                            width: 1.0,
                            style: BorderStyle.solid,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              "My Helpline ID",
                              style: TextStyle(
                                  color: greyc,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                            Center(
                              child: Text(
                                blindUserKey != ""
                                    ? blindUserKey
                                    : "- - - - - - - - -",
                                style: TextStyle(
                                    color: mainColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shadowColor: greyd,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            minimumSize: Size(displayWidth * 0.25, 40),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              blindUserKey = generateRandomKey();
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shadowColor: greyd,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            minimumSize: Size(displayWidth * 0.25, 40),
                          ),
                          child: const Text(
                            'Generate',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  double haversine(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371; // radius of the Earth in kilometers
    final phi1 = radians(lat1);
    final phi2 = radians(lat2);
    final delta_phi = radians(lat2 - lat1);
    final delta_lambda = radians(lon2 - lon1);
    final a = math.pow(math.sin(delta_phi / 2), 2) +
        math.cos(phi1) *
            math.cos(phi2) *
            math.pow(math.sin(delta_lambda / 2), 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    final d = R * c;
    return d;
  }

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

  Future<void> _getRoutePoints() async {
    final OpenRouteService client = OpenRouteService(apiKey: apiKey);
    try {
      final List<ORSCoordinate> routeCoordinates =
          await client.directionsRouteCoordsGet(
        startCoordinate: ORSCoordinate(
            latitude: currentLatLng.latitude.toDouble(),
            longitude: currentLatLng.longitude.toDouble()),
        endCoordinate: ORSCoordinate(
            latitude: chosenLocationPointCoodinates.latitude.toDouble(),
            longitude: chosenLocationPointCoodinates.longitude.toDouble()),
      );
      // routeCoordinates.forEach(print);
      routePoints = routeCoordinates
          .map(
              (coordinate) => LatLng(coordinate.latitude, coordinate.longitude))
          .toList();
    } catch (e) {
      print("=======================================ROUTE POINTS FAILED");
    }
  }

  Future<void> _sendRequesttoAssistantOnline(String assistantid,String blindUserId) async {
    final requestData = {
      "emailid": blindUserId.toString(),
      "latitude": _currentLocation!.latitude!,
      "longitude": _currentLocation!.longitude!,
      "usertype": "blind",
      "pairid": assistantid.toString(),
      "active": true
    };
    try {
      final response = await http.post(
        Uri.parse('http://192.168.100.21:5000/updatepairid'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print("========HERE PASS");
        print(jsonResponse);
      } else {
        print(
            "Failed to get available assistants. Error code: ${response.statusCode}");
      }
    } catch (e) {}
  }

  Future<void> _sendMyLocationOnline() async {
    final requestData = {
      "emailid": blindUserKey.toString(),
      "latitude": _currentLocation!.latitude!,
      "longitude": _currentLocation!.longitude!,
      "usertype": "blind",
      "pairid": "",
      "active": true
    };

    try {
      final response = await http.post(
        Uri.parse('http://192.168.100.21:5000/updatelocationdata'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print("========HERE PASS");
        print(jsonResponse);
      } else {
        print(
            "Failed to get available assistants. Error code: ${response.statusCode}");
      }
    } catch (e) {
      print("Failed to connect to endpoint for updatelocationdata ${e}");
    }
  }

  Future<void> _requestAvailableAssistants(
      double displayHeight, double displayWidth) async {
    final requestData = {
      "emailid": blindUserKey,
      "latitude": _currentLocation!.latitude!,
      "longitude": _currentLocation!.longitude!,
      "usertype": "assistant",
      "pairid": "NULL",
      "active": true
    };

    if (blindUserKey != "") {
      try {
        _sendMyLocationOnline();
        final response = await http.post(
          Uri.parse('http://192.168.100.21:5000/assistantsavailable'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestData),
        );

        if (response.statusCode == 200) {
          final jsonResponse = jsonDecode(response.body);
          availableAssistants = [];
          for (var i = 0; i < jsonResponse.length; i++) {
            availableAssistants.add({
              'emailid': jsonResponse[i]['emailid'],
              'latitude': jsonResponse[i]['latitude'],
              'longitude': jsonResponse[i]['longitude'],
              'usertype': jsonResponse[i]['usertype'],
              'pairid': jsonResponse[i]['pairid'],
              'active': jsonResponse[i]['active'],
            });
          }
          assistantMarkers = [];

          Marker mylocationMarker = Marker(
            width: displayHeight * 0.12,
            height: displayHeight * 0.12,
            point: currentLatLng,
            builder: (ctx) => Container(
              width: displayHeight * 0.12,
              height: displayHeight * 0.12,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.5),
                borderRadius: BorderRadius.circular(displayHeight * 0.1),
              ),
              child: Center(
                child: Stack(
                  children: [
                    Container(
                      width: displayHeight * 0.025,
                      height: displayHeight * 0.025,
                      decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius:
                              BorderRadius.circular(displayHeight * 0.05),
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
                          )),
                    ),
                  ],
                ),
              ),
            ),
          );

          setState(() {
            assistantMarkers.add(mylocationMarker);
          });
          for (var assistant in availableAssistants) {
            double latitude = assistant['latitude'];
            double longitude = assistant['longitude'];
            LatLng assistantMarkersCoodinates = LatLng(latitude, longitude);
            Marker marker = Marker(
              width: displayHeight * 0.12,
              height: displayHeight * 0.12,
              point: assistantMarkersCoodinates,
              builder: (ctx) => locationPoint(displayHeight: displayHeight),
            );
            setState(() {
              assistantMarkers.add(marker);
            });
          }

          for (final coord in availableAssistants) {
            final lat = coord['latitude'] as double;
            final lon = coord['longitude'] as double;
            final distance = haversine(
                currentLatLng.latitude, currentLatLng.longitude, lat, lon);
            if (distance < smallestDistance) {
              smallestDistance = distance;
              closestAssistantEmail = coord['emailid'] as String;
            }
          }

          print(
              'The shortest distance is $smallestDistance km with $closestAssistantEmail');

          for (var i = availableAssistants.length - 1; i >= 0; i--) {
            if (availableAssistants[i]['emailid'] == closestAssistantEmail) {
              setState(() {
                assistantMarkers.removeAt(i + 1);
              });

              chosenLocationPointCoodinates = LatLng(
                  availableAssistants[i]['latitude'] as double,
                  availableAssistants[i]['longitude'] as double);

              Marker chosenLocationPoint = Marker(
                width: displayHeight * 0.12,
                height: displayHeight * 0.12,
                point: chosenLocationPointCoodinates,
                builder: (ctx) => Container(
                  width: displayHeight * 0.12,
                  height: displayHeight * 0.12,
                  decoration: BoxDecoration(
                    color: mainColor.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(displayHeight * 0.1),
                  ),
                  child: Center(
                    child: Stack(
                      children: [
                        Container(
                          width: displayHeight * 0.025,
                          height: displayHeight * 0.025,
                          decoration: BoxDecoration(
                              color: mainColor,
                              borderRadius:
                                  BorderRadius.circular(displayHeight * 0.05),
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
                              )),
                        ),
                      ],
                    ),
                  ),
                ),
              );
              setState(() {
                assistantMarkers.add(chosenLocationPoint);
              });

              //getting route points
              if (chosenLocationPointCoodinates != null) {
                _getRoutePoints();
                _sendRequesttoAssistantOnline(closestAssistantEmail,blindUserKey);
              }
            }
          }
        } else {
          print(
              "Failed to get available assistants. Error code: ${response.statusCode}");
        }
      } catch (e) {
        print("Failed to Connect to the endpoint");
      }
    } else {
      showAlert(context, displayWidth);
    }
  }

  @override
  void initState() {
    _mapController = MapController();
    initLocationService();
    _getRoutePoints();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double displayWidth = MediaQuery.of(context).size.width;
    double displayHeight = MediaQuery.of(context).size.height;
    if (_currentLocation != null) {
      currentLatLng =
          LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!);
    } else {
      initLocationService();
      // currentLatLng = LatLng(0, 0);
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: mainColor,
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.menu,
            size: 20,
            color: primaryColor,
          ),
        ),
        title: Center(
          child: Text(
            'Emergency',
            style: TextStyle(
                fontSize: 10, color: primaryColor, fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              initLocationService();
            },
            icon: const Icon(
              Icons.refresh,
              size: 20,
              color: primaryColor,
            ),
          ),
          IconButton(
            onPressed: () {
              showAlert(context, displayWidth);
            },
            icon: const Icon(
              Icons.info_outline,
              size: 20,
              color: primaryColor,
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AssistantScreen()),
              );
            },
            icon: const Icon(
              Icons.logout,
              size: 20,
              color: primaryColor,
            ),
          ),
        ],
      ),
      body: Container(
        width: displayWidth,
        height: displayHeight,
        color: white,
        child: Stack(
          children: [
            //MAP SCREEN
            //MY MAP STAFF
            Padding(
              padding: const EdgeInsets.all(0),
              child: Column(
                children: [
                  Flexible(
                    child: _currentLocation != null
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
                              ),
                              PolylineLayer(
                                polylines: [
                                  Polyline(
                                      points: routePoints,
                                      strokeWidth: 5,
                                      color: mainColor),
                                ],
                              ),
                              MarkerLayer(markers: assistantMarkers)
                            ],
                          )
                        : Center(
                            child: Container(
                                width: 50,
                                height: 50,
                                child: const CircularProgressIndicator(
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(greyd))),
                          ),
                  ),
                ],
              ),
            ),

            //BUTTON SCREEN
            Positioned(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  //this is the third bar with start button
                  Container(
                    width: displayWidth,
                    height: displayHeight * 0.45,
                    child: Stack(
                      children: [
                        Center(
                          child: ClayContainer(
                            color: white,
                            height: displayHeight * 0.28 * 0.6,
                            width: displayHeight * 0.28 * 0.6,
                            borderRadius: displayHeight * 0.28 * 0.5 * 0.5,
                            curveType: CurveType.concave,
                            child: Stack(
                              children: [
                                Center(
                                  child: Container(
                                    height: displayHeight * 0.24 * 0.6,
                                    width: displayHeight * 0.24 * 0.6,
                                    decoration: BoxDecoration(
                                        color: red,
                                        borderRadius: BorderRadius.circular(
                                            displayHeight * 0.24 * 0.5 * 0.6)),
                                    child: Stack(
                                      children: [
                                        Center(
                                          child: ClayContainer(
                                            color: red,
                                            height: displayHeight * 0.21 * 0.6,
                                            width: displayHeight * 0.21 * 0.6,
                                            borderRadius:
                                                displayHeight * 0.24 * 0.5,
                                            curveType: CurveType.convex,
                                            child: IconButton(
                                              onPressed: () {
                                                _requestAvailableAssistants(
                                                    displayHeight,
                                                    displayWidth);
                                              },
                                              icon: Icon(
                                                Icons.sos_sharp,
                                                size:
                                                    displayHeight * 0.05 * 0.5,
                                                color: white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                  //this is the fourth bar with someone coming to save the day
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
