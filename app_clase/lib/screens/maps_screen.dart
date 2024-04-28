import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:circular_menu/circular_menu.dart';
import 'package:geolocator/geolocator.dart';

class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  StreamSubscription<Position>? _positionStreamSubscription;
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  LatLng? myPosition;
  Future<Position> determinePosition() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('error');
      }
    }
    return await Geolocator.getCurrentPosition();
  }

  void getCurrentLocation() async {
    Position position = await determinePosition();
    setState(() {
      myPosition = LatLng(position.latitude, position.longitude);
      print(myPosition);
    });
  }

  void _listenToLocationUpdates() {
    _positionStreamSubscription = Geolocator.getPositionStream(
            //desiredAccuracy: LocationAccuracy.high,
            //distanceFilter: 10, // Actualiza la ubicación cada 10 metros
            )
        .listen((Position position) {
      setState(() {
        myPosition = LatLng(position.latitude, position.longitude);
        print(myPosition);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    getPolyPoints();
    _listenToLocationUpdates();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  static const CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);
  static const LatLng sourceLocation = LatLng(20.573260, -101.189490);
  static const LatLng destination = LatLng(20.694501, -101.350667);

  List<LatLng> polylineCoordinates = [];
  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        "AIzaSyAYkXFVBrXgQcaiRNwwqUFivhz9VlfS9Is",
        PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
        PointLatLng(destination.latitude, destination.longitude));
    if (result.points.isNotEmpty) {
      result.points.forEach(
        (PointLatLng point) => polylineCoordinates.add(
          LatLng(point.latitude, point.longitude),
        ),
      );
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Map'),
          backgroundColor: Colors.blueAccent,
        ),
        body: myPosition == null
            ? const Center(child: CircularProgressIndicator())
            : CircularMenu(
                alignment: Alignment.center,
                radius: 50,
                startingAngleInRadian: 0,
                endingAngleInRadian: 3.14,
                items: [
                  CircularMenuItem(
                    onTap: () {},
                    icon: Icons.map,
                    color: Colors.green,
                  ),
                  CircularMenuItem(
                    onTap: () {},
                    icon: Icons.access_time,
                    color: Colors.blue,
                  ),
                  CircularMenuItem(
                    onTap: () {},
                    icon: Icons.account_box,
                    color: Colors.grey,
                  ),
                  CircularMenuItem(
                    onTap: () {},
                    icon: Icons.agriculture_rounded,
                    color: Colors.red,
                  ),
                ],
                backgroundWidget: GoogleMap(
                  mapType: MapType.hybrid,
                  initialCameraPosition:
                      CameraPosition(target: myPosition!, zoom: 14.5),
                  markers: {
                    Marker(
                      markerId: MarkerId("source"),
                      position: sourceLocation,
                    ),
                    Marker(
                      markerId: MarkerId("destination"),
                      position: destination,
                    ),
                    Marker(
                      position: myPosition!,
                      markerId: MarkerId("Position"),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueAzure),
                    ),
                  },
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                  polylines: {
                    Polyline(
                      polylineId: const PolylineId("route"),
                      points: polylineCoordinates,
                      color: const Color(0xFF7B61FF),
                      width: 6,
                    ),
                  },
                ),
              ));
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }
}
