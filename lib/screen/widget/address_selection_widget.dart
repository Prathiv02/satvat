import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:satvat/provider/navigation_provider.dart';
import 'package:satvat/utils/progress_utils.dart';

class AddressSelectionWidget extends StatefulWidget {
  const AddressSelectionWidget({Key? key}) : super(key: key);

  @override
  _AddressSelectionWidgetState createState() => _AddressSelectionWidgetState();
}

class _AddressSelectionWidgetState extends State<AddressSelectionWidget> {
  TextEditingController startAddress = TextEditingController();
  String destinationAddress = "";

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 20,
          ),
        ],
      ),
      child: Consumer<NavigationProvider>(
        builder: (BuildContext context, navigationProvider, Widget? child) {
          startAddress.text = navigationProvider.startAddress;
          return Column(
            children: [
              TextField(
                controller: startAddress,
                readOnly: true,
                onTap: () {
                  if (navigationProvider.currentLocation == null) {
                    navigationProvider.getCurrentLocation(context: context);
                  }
                  Fluttertoast.showToast(msg: "Current Location");
                },
                decoration: InputDecoration(
                    suffixIcon: const Icon(Icons.my_location),
                    border: InputBorder.none,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: Colors.black26, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: Colors.black26, width: 2),
                    ),
                    labelText: "Start"),
              ),
              const SizedBox(height: 10),
              TextField(
                onChanged: (v) {
                  setState(() {
                    destinationAddress = v;
                  });
                },
                keyboardType: TextInputType.streetAddress,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: Colors.black26, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: Colors.black26, width: 2),
                    ),
                    labelText: "Destination"),
              ),
              const SizedBox(height: 10),
              if (navigationProvider.distance != null)
                Text(
                  "DISTANCE: ${navigationProvider.distance} Km",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              const SizedBox(height: 15),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22.0))),
                  onPressed: destinationAddress.toString().length < 2
                      ? null
                      : () async {
                          FocusScope.of(context).unfocus();
                          ProgressUtils.showDialogProgress(context);
                          await navigationProvider
                              .reverseGeocodingForGettingLatLong(
                                  address: destinationAddress)
                              .then((value) async {
                            if (navigationProvider.currentLocation != null) {
                              await navigationProvider
                                  .distanceCalculation(
                                      start:
                                          "${navigationProvider.currentLocation!.latitude},${navigationProvider.currentLocation!.longitude}",
                                      destination:
                                          "${navigationProvider.destinationLatLong!.latitude},${navigationProvider.destinationLatLong!.longitude}")
                                  .then((value) {
                                Navigator.of(context).pop();
                              });
                            } else {
                              await navigationProvider
                                  .getCurrentLocation(context: context)
                                  .then((value) async {
                                await navigationProvider
                                    .distanceCalculation(
                                        start:
                                            "${navigationProvider.currentLocation!.latitude},${navigationProvider.currentLocation!.longitude}",
                                        destination:
                                            "${navigationProvider.destinationLatLong!.latitude},${navigationProvider.destinationLatLong!.longitude}")
                                    .then((value) {
                                  Navigator.of(context).pop();
                                });
                              });
                            }
                          });
                        },
                  child: const Text(
                    "SHOW DIRECTION",
                    style: TextStyle(color: Colors.white, fontSize: 17),
                  )),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }
}
