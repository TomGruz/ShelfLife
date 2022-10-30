import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/parameter/SearchTerms.dart';
import 'package:shelf_life_prototype/FoodManager.dart';
import 'package:shelf_life_prototype/Recipes.dart';
import 'package:shelf_life_prototype/constants.dart';
import 'HomeWidgets.dart';
import 'constants.dart';
import 'Home.dart';
import 'package:shelf_life_prototype/Popups.dart';
import 'package:shelf_life_prototype/Settings.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shelf_life_prototype/Popups.dart';
import 'LocalNotifications.dart';
import 'package:shelf_life_prototype/HeroDialogRoute.dart';
import 'package:openfoodfacts/openfoodfacts.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  messaging.subscribeToTopic('food');
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  return runApp(MyApp());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    print("Starting app...");
    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          elevation: 0,
          title: Text("ShelfLife", style: titleStyle),
          backgroundColor: kLightGreen,
        ),
        body: myPanel(),
      ),
    );
  }
}

class myPanel extends StatefulWidget {

  @override
  State<myPanel> createState() => _myPanelState();
}

class _myPanelState extends State<myPanel> {

  //Global variables
  LocalNotificationService localNotifications = LocalNotificationService();
  CollectionReference foodCollection = FirebaseFirestore.instance.collection('food');

  int pageIndex = 0;
  FoodManager foodManager = FoodManager();

  //List of possible bottom navigation bar screens
  List <Widget> screens = [
    Home(foodManager: FoodManager()),
    Recipes(foodManager: FoodManager()),
    Container(
      child: Text(
        'This page is empty. The icon is just for aesthetic purposes',
        style: labelStyle,
      ),),
  ];

  @override
  void initState() {

    //Initialize notification class
    localNotifications.intialize();
    listenToNotification();
    FirebaseMessaging.onMessage.listen((message) {
      print("---REMOTE MESSAGE RECEIVED---");
      if(message.notification?.title != null){
        String title = message.notification?.title ?? "";
        String body = message.notification?.body ?? "";
        localNotifications.showNotificationWithPayload(
            id: 1, title: title, body: "", payload: body);
      }
      else {
        //Do if notification is received incorrectly
        localNotifications.showNotificationWithPayload(
            id: 1, title: 'unknown', body: 'unknown', payload: 'payload');
      }
    });

    super.initState();
  }


  void listenToNotification() => localNotifications.onNotificationClick.stream.listen(notificationClickedRoutine);

  void notificationClickedRoutine(String? payload) async {
    print('notification clicked!');
    if(payload != null && payload.isNotEmpty){

      DocumentSnapshot foodDocument = await foodCollection.doc(payload).get();
      Map<String,dynamic>? value = foodDocument.data() as Map<String,dynamic>?;
      String name = value?["name"] ?? "";
      Navigator.push(context, HeroDialogRoute(builder: (context) => dateAddPopup(itemName: name, id: payload,)));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(flex: 9, child: screens[pageIndex]),
        Expanded(
          flex: 1,
          child: BottomNavigationBar(
            selectedItemColor: kOrange,
            unselectedItemColor: Colors.black54,
            currentIndex: pageIndex,
            onTap: (index) => setState(() => pageIndex = index),
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.list_alt),
                label: 'Recipes',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

