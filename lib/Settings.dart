import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shelf_life_prototype/Popups.dart';
import 'constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'LocalNotifications.dart';


class SettingsPage extends StatefulWidget {

  @override
  State<SettingsPage> createState() => _SettingsState();
}

class _SettingsState extends State<SettingsPage> {


  @override void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(25.0),
          child: Text('Settings page is currently used for experimentation...', style: labelStyle),
        ),
        Padding(
          padding: const EdgeInsets.all(25),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kOrange,
            ),
                onPressed: (){

                },
                child: Text('Get a notification!', style: labelStyle,),
              ),
        ),
      ],
    );

  }
}
