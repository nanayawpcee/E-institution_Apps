import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../utils/check_permission.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final CheckPermission permissionChecker = CheckPermission();

  @override
  void initState() {
    super.initState();
    _checkAndRequestStoragePermission(); // Check and request storage permission when the page loads
  }

  Future<void> _checkAndRequestStoragePermission() async {
    bool hasStoragePermission = await permissionChecker.isStoragePermission();
    if (!hasStoragePermission) {
      // Show a dialog to inform the user about permission requirement
      // showDialog  to display a message to the user

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Storage Permission Required'),
            content: Text(
                'This app requires storage permission to function properly.'),
            actions: [
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: Text('Open Settings'),
                onPressed: () {
                  openAppSettings(); // Open the app settings so the user can grant permission
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings Page'),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      ),
      body: Center(
        child: Text('Settings Page Content'),
      ),
    );
  }
}
