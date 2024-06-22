import 'package:flutter/material.dart';

class Utils {
  static void showErrorMessage(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          title: Text("Error"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  static bool isValidEmail(String email) {
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return regex.hasMatch(email);
  }

  static void showDialogGeneric({
    required BuildContext context,
    required String title,
    required List<Widget> fields,
    required VoidCallback onConfirm, 
    String? errorMessage,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          contentPadding: EdgeInsets.all(16.0),
          content: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 24.0),
                      child: Center(
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headline6?.copyWith(fontSize: 18),
                        ),
                      ),
                    ),
                    ...fields,
                  ],
                ),
              ),
              Positioned(
                right: 0.0,
                top: 0.0,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.black),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: onConfirm,
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
}
