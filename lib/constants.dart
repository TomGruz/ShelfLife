import 'package:flutter/material.dart';


 enum FoodState{
  fine,
  closeToExpiration,
  expired,
}

enum RecipeState{
   unavailable,
  available,
  urgent,
}

const textBarDecoration = InputDecoration(
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color: kOrange,
    ),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.black26,
    ),
  ),
  border: OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.black26,
    ),
  ),
);

const kLightGreen = Color(0xffD3EDCD);
const kLightOrange = Color(0xFFFCF0D4);
const kOrange = Color(0xffFE8553);
const kLightGrey = Colors.black12;
const kLightRed = Color(0xfffce0d7);
const kRed = Color(0xffff5b21);

const labelStyle = TextStyle(
  fontSize: 16,
  color: Colors.black54,
);


const labelStyleBold = TextStyle(
  fontSize: 16,
  color: Colors.black54,
  fontWeight: FontWeight.bold,
);

const titleStyle = TextStyle(
  fontSize: 18,
  color: Colors.black54,
);