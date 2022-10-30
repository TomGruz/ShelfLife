import 'package:flutter/material.dart';
import 'package:shelf_life_prototype/Popups.dart';
import 'constants.dart';
import 'package:shelf_life_prototype/FoodManager.dart';
import 'package:shelf_life_prototype/HomeWidgets.dart';
import 'package:shelf_life_prototype/HeroDialogRoute.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class RecIngredient{
  RecIngredient({required this.name, required this.image_url, required this.barcode});
  String name;
  String image_url;
  String barcode;
}
class Recipe{
  Recipe({required this.name, required this.ingredients});
  String name;
  List <RecIngredient> ingredients;
}

Future sendRecipeToCould({required Recipe recipe}) async {
  //Trick to only send recipe to cloud one the current context has been popped back to Recipe section with a stream listener
  final recipeDoc = await FirebaseFirestore.instance.collection('recipes').doc();

  await recipeDoc.set({
    'name': recipe.name,
    'state': 'available',
  });

  //Create new collection of ingredients within the recipe document
  final ingredientCollection = await recipeDoc.collection('ingredients');

  for(var ingredient in recipe.ingredients){
    await ingredientCollection.doc(ingredient.barcode).set({
      'name': ingredient.name,
      'image_url': ingredient.image_url,
    });
  }

}


class Recipes extends StatefulWidget {
  Recipes({required this.foodManager});

  FoodManager foodManager;

  @override
  State<Recipes> createState() => _RecipesState();
}



class _RecipesState extends State<Recipes> {

  @override
  void initState() {
    super.initState();
  }

  Future sendRecipeState(DocumentSnapshot recipeSnapshot, AsyncSnapshot<QuerySnapshot> foodSnapshot) async {

    String state = 'available';


    var recipeIngredients = await recipeSnapshot.reference.collection('ingredients').get().then( (querySnapshot) {
      querySnapshot.docs.forEach((element) {
        String itemState = 'available';
        bool hasItem = false;
        for(var foodDocument in foodSnapshot.data!.docs){
          print("Recipe item id: " + element.id);
          print("Food item id: " + foodDocument.id);
          if(element.id == foodDocument.id && foodDocument['on_shelf'] == true){
            print("Found match");
            hasItem = true;
            if(foodDocument['state'] == 'warning'){
              itemState = 'warning';
              if(state != 'unavailable') {
                state = 'warning';
              }
            }
            break;
          }
        }
        print("Bool: " + hasItem.toString());
        print("------------------");
        if(hasItem == false){
          itemState = 'unavailable';
          state = 'unavailable';
        }

        FirebaseFirestore.instance.collection('recipes').doc(recipeSnapshot.id).collection('ingredients').doc(element.id).update({
          'state': itemState,
        });

      });
    }
    );

    await FirebaseFirestore.instance.collection('recipes').doc(recipeSnapshot.id).update({
      'state': state,
    });

    return;
  }

  RecipeState getRecipeState(DocumentSnapshot streamSnapshot){
    if(streamSnapshot['state'] == 'unavailable'){
      return RecipeState.unavailable;
    } else if(streamSnapshot['state'] == 'available'){
      return RecipeState.available;
    } else {
      return RecipeState.urgent;
    }
  }

  int getNoAlertRecipes(AsyncSnapshot<QuerySnapshot> streamSnapshot){
    int num = 0;
    for(var document in streamSnapshot.data!.docs){
      if(document['state'] == 'warning'){
        num++;
      }
    }
    return num;
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(
        flex: 8,
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('recipes').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
            return StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('food')
                .snapshots(), //build connection
            builder: (context, AsyncSnapshot<QuerySnapshot> foodSnapshot) {

              if (streamSnapshot.hasData) {
                        int noAlert = getNoAlertRecipes(streamSnapshot);
                        return Column(
                          children:[
                            Expanded(
                              flex: 2,
                              child: IconCard(
                                icon: Icons.lightbulb,
                                color: kOrange,
                                backgroundColor: kLightOrange,
                                labelText: (noAlert > 1 ? (noAlert.toString() + " urgent recipes available!") : (noAlert.toString() + " urgent recipe available!")),
                              ),
                            ),
                            Expanded(
                              flex: 7,
                              child: ListView.builder(
                              physics: BouncingScrollPhysics(),
                              itemCount: streamSnapshot.data!.docs.length, //number of rows
                              itemBuilder: (context, index) {
                                final DocumentSnapshot documentSnapshot =
                                streamSnapshot.data!.docs[index];
                                sendRecipeState(documentSnapshot, foodSnapshot);
                                return RecipeCard(name: documentSnapshot['name'], recipeState: getRecipeState(documentSnapshot), recipeDocId: documentSnapshot.id, localId: index,);
                              },
                          ),
                            ),
              ],
                        );
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          );
            },
        ),
      ),
      Expanded(
        flex: 2,
        child: FloatingActionButton(
          heroTag: recipePopupId,
          elevation: 2,
          child: Icon(Icons.add),
          backgroundColor: kOrange,
          onPressed: () async {
            Navigator.of(context)
                .push(HeroDialogRoute(builder: (context) {
              return recipeAddPopup();
            }));
          },
        ),
      ),
    ]);
  }
}

class CustomActionButton extends StatelessWidget {
  const CustomActionButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(HeroDialogRoute(builder: (context) {
            return recipeAddPopup();
          }));
        },
        child: Hero(
          tag: recipePopupId,
          child: Material(
            color: kOrange,
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            child: const Icon(
              Icons.add_rounded,
              size: 56,
            ),
          ),
        ),
      ),
    );
  }
}
