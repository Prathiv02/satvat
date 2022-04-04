
import 'package:flutter/material.dart';


class ProgressUtils {
  static Widget _buildProgress(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: const [
          SizedBox(
            width: 10,
          ),
          CircularProgressIndicator(),
          SizedBox(
            width: 10,
          ),
          Text(
            "Please wait...",
            textScaleFactor: 1,
          )
        ],
      ),
    );
  }

  static void showDialogProgress(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: _buildProgress(context),
        );
      },
    );
  }
}
