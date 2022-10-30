import 'package:flutter/material.dart';
import 'package:shelf_life_prototype/HomeWidgets.dart';
import 'package:shelf_life_prototype/FoodManager.dart';
import 'constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Home extends StatefulWidget {
  Home({required this.foodManager});


  FoodManager foodManager;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String getNoOfItemsCloseToExpiration(AsyncSnapshot<QuerySnapshot> streamSnapshot){
    int num = 0;
    for(var document in streamSnapshot.data!.docs){
      if(document['state'] == 'warning'&& document['on_shelf'] == true){
        num++;
      }
    }
    return num.toString();
  }

  String getNoOfItemsExpired(AsyncSnapshot<QuerySnapshot> streamSnapshot){
    int num = 0;
    for(var document in streamSnapshot.data!.docs){
      if(document['state'] == 'expired' && document['on_shelf'] == true){
        num++;
      }
    }
    return num.toString();
  }


  FoodState getFoodState(DocumentSnapshot streamSnapshot){
    if(streamSnapshot['state'] == 'warning'){
      return FoodState.closeToExpiration;
    } else if(streamSnapshot['state'] == 'ok'){
      return FoodState.fine;
    } else {
      return FoodState.expired;
    }

  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('food')
          .snapshots(), //build connection
      builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
        if (streamSnapshot.hasData) {
          return
            Column(
              children: [
                Expanded(
                flex: 2,
                child: IconCard(
                    color: kOrange,
                    backgroundColor: kLightOrange,
                    icon: Icons.lightbulb,
                    labelText: getNoOfItemsCloseToExpiration(streamSnapshot) +
                        ' item' + ((getNoOfItemsExpired(streamSnapshot)!=1) ? 's' : '') + ' on your shelf are close to their expiration date!')),
                Expanded(
                    flex: 2,
                    child: IconCard(
                        color: kRed,
                        backgroundColor: kLightRed,
                        icon: Icons.dangerous_outlined,
                        labelText: getNoOfItemsExpired(streamSnapshot) +
                            ' item' + ((getNoOfItemsExpired(streamSnapshot)!=1) ? 's' : '') + ' on your shelf have expired!')),
                Expanded(
                  flex: 8,
                child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  itemCount: streamSnapshot.data!.docs.length, //number of rows
                  itemBuilder: (context, index) {
                    final DocumentSnapshot documentSnapshot =
                    streamSnapshot.data!.docs[index];
                    if (documentSnapshot['on_shelf'] == true) {
                      return ItemCard(
                        id: index,
                        foodState: getFoodState(documentSnapshot),
                        itemName: documentSnapshot['name'],
                        weight: documentSnapshot['weight'],
                        imageUrl: documentSnapshot['image_url'],
                        expirationDate:
                        documentSnapshot['expiration_date'].toString(),
                      );
                  }
                    return Container();
                  },
                ),
              ),
            ]);
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
