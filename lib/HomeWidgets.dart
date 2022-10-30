import 'package:flutter/material.dart';
import 'constants.dart';
import 'package:shelf_life_prototype/Popups.dart';
import 'package:shelf_life_prototype/HeroDialogRoute.dart';




class ItemCardMinimal extends StatelessWidget {

  ItemCardMinimal({required this.name, required this.image_url, required this.state}) {
    if(state == RecipeState.available){
      textStyle = labelStyle;
      borderColor = Colors.black26;
    } else if (state == RecipeState.unavailable) {
      textStyle = labelStyle.copyWith(color: Colors.black12);
      borderColor = Colors.black12;
    } else if (state == RecipeState.urgent) {
      textStyle = labelStyle;
      borderColor = Colors.amber;
    }
  }

  TextStyle textStyle = labelStyle;
  Color borderColor = Colors.black26;
  final String name;
  final String image_url;
  final RecipeState state;

  @override
  Widget build(BuildContext context) {
    return  Container(
      height: 80,
      padding: EdgeInsets.all(5),
      margin: EdgeInsets.fromLTRB(15, 5, 15, 5),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Center(
              child: Image.network(image_url),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              name,
              style: textStyle,
            ),
          ),
        ],
      ),
    );
  }
}

class ItemSearchCard extends StatelessWidget {

  ItemSearchCard(
      {required this.onTap, required this.itemName, required this.image_url});

  String itemName;
  String image_url;
  void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        padding: EdgeInsets.all(5),
        margin: EdgeInsets.fromLTRB(15, 5, 15, 5),
        decoration: BoxDecoration(
          border: Border.all(color: kLightGrey),
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Center(
                child: Image.network(image_url),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                itemName,
                style: labelStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ScrollableList extends StatelessWidget {
  const ScrollableList({required this.list});

  final List <Widget> list;
  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      radius: Radius.circular(3),
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: list,
        ),
      ),
    );
  }
}


class RecipeCard extends StatelessWidget {

  RecipeCard({required this.name, required this.recipeState, required this.recipeDocId, required this.localId}) {
    if(recipeState == RecipeState.available){
      textStyle = labelStyle;
      borderColor = Colors.black26;
    } else if (recipeState == RecipeState.urgent){
      textStyle = labelStyle;
      borderColor = Colors.amber;
    } else if (recipeState == RecipeState.unavailable) {
      textStyle = labelStyle.copyWith(color: Colors.black12);
      borderColor = Colors.black12;
    }
  }

  final String name;
  final RecipeState recipeState;

  //Id of this recipe's document on the firebase
  final String recipeDocId;
  //Index of recipe in local list
  final int localId;

  TextStyle textStyle = labelStyle;
  Color borderColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Navigator.of(context).push(HeroDialogRoute(builder: (context) {
          return RecipePopup(local_id: localId, document_id: recipeDocId, recipeName: name);
        }));
      },
      child: Hero(
        tag: recipePopupShowId + localId.toString(),
        child: Container(
          padding: EdgeInsets.fromLTRB(5, 20, 5, 20),
          margin: EdgeInsets.fromLTRB(15, 7.5, 15, 7.5),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
          child: Center(
            child: Text(name, style: textStyle),
          ),
        ),
      ),
    );
  }
}



class ItemCard extends StatelessWidget {

  ItemCard({required this.imageUrl, required this.itemName, required this.expirationDate, required this.weight, required this.foodState, required this.id}){
    if(foodState == FoodState.fine) {
      borderColor = Colors.black26;
    } else if(foodState == FoodState.closeToExpiration){
      borderColor = Colors.amber;
    } else {
      borderColor = Colors.red;
    }
  }

  final int id;
  final String imageUrl;
  final String itemName;
  final String expirationDate;
  final String weight;
  final FoodState foodState;
  Color borderColor = Colors.white;




  @override
  Widget build(BuildContext context) {

      return GestureDetector(
        onTap: () {
        Navigator.of(context).push(HeroDialogRoute(builder: (context) {
        return ItemPopup(imageUrl: imageUrl, itemName: itemName, expirationDate: expirationDate, weight: weight, foodState: foodState, id: id);
        }));
        },
        child: Hero(
          tag: itemPopupId + id.toString(),
          child: Container(
            padding: EdgeInsets.all(5),
            margin: EdgeInsets.fromLTRB(15, 7.5, 15, 7.5),
            height: 90,
            decoration: BoxDecoration(
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Image.network(imageUrl),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        itemName,
                        style: labelStyle,
                      ),
                      SizedBox(height: 20),
                      Text('Best before: ' + expirationDate, style: labelStyle.copyWith(color: borderColor)),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Text(
                      weight + ' g',
                      style: labelStyleBold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }


class IconCard extends StatelessWidget {
  IconCard({required this.color, required this.icon, required this.labelText, required this.backgroundColor});

  final Color color;
  final Color backgroundColor;
  final IconData icon;
  final String labelText;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.fromLTRB(15, 7.5, 15, 7.5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Center(
              child: Icon(
                icon,
                size: 50,
                color: color,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Center(
              child: Text(
                labelText,
                style: labelStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
