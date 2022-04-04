import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';

class NavigationProvider extends ChangeNotifier {
  PolylinePoints polylinePoints = PolylinePoints();
  Map<PolylineId, Polyline> polylines = {};
  Set<Polyline> polyline = {};
  Set<Marker> marker = {};
  String startAddress = "";
  String destinationAddress = "";
  LatLng? destinationLatLong;
  double? distance;
  late bool _isLocationServiceEnabled;
  LatLng? currentLocation;
  final LatLng tempLocation =
      const LatLng(13.005373971005495, 80.25747371531631);

  Future getCurrentLocation({required BuildContext context}) async {
    LocationPermission permission;

    _isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!_isLocationServiceEnabled) {
      if (!Platform.isIOS) {
        Location location = Location();
        _isLocationServiceEnabled = await location.requestService();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Turn on GPS for assessing your location")));
      }
    }
    if (!_isLocationServiceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Location permissions are denied")));
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              "Location permissions are permanently denied, we cannot request permissions.")));
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition();
    currentLocation = LatLng(position.latitude, position.longitude);
    marker.add(Marker(
        markerId: const MarkerId("currentLatLong"),
        position: currentLocation!));

    await reverseGeocodingForGettingAddress(
        longitude: currentLocation!.longitude,
        latitude: currentLocation!.latitude);

    notifyListeners();
  }

  Future reverseGeocodingForGettingAddress(
      {required double latitude, required double longitude}) async {
    final data = await http.get(Uri.parse(
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=AIzaSyB0Pd6TkW7Ip2rIDZsXgPhyfLprulvDn7U"));
    startAddress = jsonDecode(data.body)["results"][0]["formatted_address"];
    return startAddress;
  }

  Future reverseGeocodingForGettingLatLong({required String address}) async {
    final data = await http.get(Uri.parse(
        "https://maps.googleapis.com/maps/api/geocode/json?address=$address&key=AIzaSyB0Pd6TkW7Ip2rIDZsXgPhyfLprulvDn7U"));
    var value = jsonDecode(data.body)["results"];
    destinationLatLong = LatLng(value[0]["geometry"]["location"]["lat"],
        value[0]["geometry"]["location"]["lng"]);
    return destinationLatLong;
  }

  Future distanceCalculation(
      {required String start, required String destination}) async {
    final data = await http.get(Uri.parse(
        "https://maps.googleapis.com/maps/api/distancematrix/json?origins=$start&destinations=$destination&key=AIzaSyB0Pd6TkW7Ip2rIDZsXgPhyfLprulvDn7U"));
    distance = double.parse(jsonDecode(data.body)["rows"][0]["elements"][0]
            ["distance"]["text"]
        .toString()
        .split(" ")
        .first);
    marker.add(Marker(
        markerId: const MarkerId("destination"),
        position: destinationLatLong!));
    await getDirections();
    notifyListeners();
    return distance;
  }

  Future getDirections() async {
    List<LatLng> polylineCoordinates = [];

    // var params = {
    //   "origin": "${currentLocation!.latitude},${currentLocation!.longitude}",
    //   "destination": "${destinationLatLong!.latitude},${destinationLatLong!.longitude}",
    //   "mode": "driving",
    //   "key": "AIzaSyB0Pd6TkW7Ip2rIDZsXgPhyfLprulvDn7U"
    // };
    // Uri uri = Uri.https("maps.googleapis.com", "maps/api/directions/json", params);
    // var response = await http.get(uri);

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      "AIzaSyB0Pd6TkW7Ip2rIDZsXgPhyfLprulvDn7U",
      PointLatLng(currentLocation!.latitude, currentLocation!.longitude),
      PointLatLng(destinationLatLong!.latitude, destinationLatLong!.longitude),
      travelMode: TravelMode.driving,
    );

    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }
    addPolyLine(polylineCoordinates);
    return;
  }

  addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId("route");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.redAccent,
      points: polylineCoordinates,
      width: 8,
    );
    polylines[id] = polyline;
  }
}

