import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:satvat/utils/progress_utils.dart';

import '../../provider/navigation_provider.dart';

class GoogleMapWidget extends StatefulWidget {
  const GoogleMapWidget({Key? key}) : super(key: key);

  @override
  _GoogleMapWidgetState createState() => _GoogleMapWidgetState();
}

class _GoogleMapWidgetState extends State<GoogleMapWidget> {
  late GoogleMapController _controller;

  @override
  void initState() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      AndroidGoogleMapsFlutter.useAndroidViewSurface = true;
    }
    Provider.of<NavigationProvider>(context, listen: false).getCurrentLocation(context: context);

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void _onMapCreated(GoogleMapController controller) {
      _controller = controller;
    }

    return Consumer<NavigationProvider>(
      builder: (BuildContext context, navigationProvider, Widget? child) {

        if (navigationProvider.currentLocation != null) {

          CameraUpdate currentLocation =
              CameraUpdate.newLatLng(navigationProvider.currentLocation!);
          _controller.animateCamera(currentLocation);
        }
        return GoogleMap(
          initialCameraPosition: CameraPosition(
              target: navigationProvider.currentLocation ??
                  navigationProvider.tempLocation,
              zoom: 15),
        //  polylines: navigationProvider.polyline,
          polylines: Set<Polyline>.of(navigationProvider.polylines.values),
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
          mapType: MapType.normal,
          onMapCreated: _onMapCreated,
          markers: navigationProvider.marker,
          onTap: (latLong) {},
        );
      },
    );
  }
}
