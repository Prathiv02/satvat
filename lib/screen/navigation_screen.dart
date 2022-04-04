import 'package:flutter/material.dart';
import 'package:satvat/screen/widget/address_selection_widget.dart';
import 'package:satvat/screen/widget/google_map_widget.dart';

class NavigationScreen extends StatefulWidget {
  static const routeName = "/NavigationScreen";

  const NavigationScreen({Key? key}) : super(key: key);

  @override
  _NavigationScreenState createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(
            top: mediaQueryData.viewPadding.top,
            bottom: mediaQueryData.viewPadding.bottom),
        child: Stack(
          children: const [
            GoogleMapWidget(),
            Positioned(
                bottom: 0, left: 0, right: 0, child: AddressSelectionWidget()),
          ],
        ),
      ),
    );
  }
}
