import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'constants.dart';
import 'package:shelf_life_prototype/FoodManager.dart';
import 'package:shelf_life_prototype/HomeWidgets.dart';
import 'package:shelf_life_prototype/HeroDialogRoute.dart';
import 'package:intl/intl.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/model/parameter/SearchTerms.dart';
import 'package:shelf_life_prototype/Recipes.dart';

String recipePopupId = 'pupupR';
String itemPopupId = 'popupI';
String recipePopupShowId = 'pupupRS';

class RecipePopup extends StatefulWidget {
  RecipePopup(
      {required int this.local_id,
      required String this.document_id,
      required String this.recipeName});

  //Index of recipe inside local list
  final int local_id;
  //Index of recipe inside firebase
  final String document_id;
  //name of recipe
  final String recipeName;

  @override
  State<RecipePopup> createState() => _RecipePopupState();
}

RecipeState getState(DocumentSnapshot documentSnapshot) {
  if (documentSnapshot['state'] == 'available') {
    return RecipeState.available;
  } else if (documentSnapshot['state'] == 'warning') {
    return RecipeState.urgent;
  } else {
    return RecipeState.unavailable;
  }
}

class _RecipePopupState extends State<RecipePopup> {
  @override
  Widget build(BuildContext context) {
    //Trick to update StreamBuilder after the Hero animation has completed
    Future<void>.delayed(
      const Duration(milliseconds: 100),
      () {
        setState(() {});
      },
    );

    return Center(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 90, 20, 90),
        child: Hero(
          tag: recipePopupShowId + widget.local_id.toString(),
          child: Material(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
            child: Container(
              child: Padding(
                padding: EdgeInsets.all(30),
                child: Column(children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      'Ingredients for ' + widget.recipeName,
                      style: labelStyle.copyWith(
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('recipes')
                          .doc(widget.document_id)
                          .collection('ingredients')
                          .snapshots(), //build connection
                      builder: (context,
                          AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                        if (streamSnapshot.hasData) {
                          return ListView.builder(
                            physics: BouncingScrollPhysics(),
                            itemCount: streamSnapshot
                                .data!.docs.length, //number of rows
                            itemBuilder: (context, index) {
                              final DocumentSnapshot documentSnapshot =
                                  streamSnapshot.data!.docs[index];
                              return ItemCardMinimal(
                                name: documentSnapshot['name'],
                                image_url: documentSnapshot['image_url'],
                                state: getState(documentSnapshot),
                              );
                            },
                          );
                        }
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kOrange,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'close',
                          style: labelStyle.copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ItemPopup extends StatefulWidget {
  ItemPopup(
      {required this.imageUrl,
      required this.itemName,
      required this.expirationDate,
      required this.weight,
      required this.foodState,
      required this.id}) {
    if (foodState == FoodState.fine) {
      borderColor = Colors.black26;
    } else if (foodState == FoodState.closeToExpiration) {
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
  State<ItemPopup> createState() => _ItemPopupState();
}

class _ItemPopupState extends State<ItemPopup> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.fromLTRB(35, 90, 35, 90),
        child: Hero(
          tag: itemPopupId + widget.id.toString(),
          child: Material(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
              side: BorderSide(color: widget.borderColor, width: 1),
            ),
            child: Container(
              child: Padding(
                padding: EdgeInsets.all(25),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(widget.itemName,
                          style: labelStyleBold.copyWith(
                            fontSize: 23,
                          )),
                    ),

                    Expanded(
                      flex: 3,
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: Image.network(widget.imageUrl)),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Row(
                              children: [
                                Text(
                                  "weight: ",
                                  style: labelStyleBold.copyWith(fontSize: 18),
                                ),
                                Text(
                                  widget.weight + ' g',
                                  style: labelStyle.copyWith(fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'expiration date: ',
                          style: labelStyleBold.copyWith(
                              color: widget.borderColor,
                              fontSize: 18),
                        ),
                        Text(
                          widget.expirationDate,
                          style: labelStyle.copyWith(
                              color: widget.borderColor,
                              fontSize: 18),
                        ),
                      ],
                    ),
                    Expanded(
                      flex: 1,
                        child: Container(),),
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kOrange,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Close',
                            style: labelStyle.copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class dateAddPopup extends StatefulWidget {
  dateAddPopup({required this.itemName, required this.id});

  final String itemName;
  final String id;
  @override
  State<dateAddPopup> createState() => _dateAddPopupState();
}

class _dateAddPopupState extends State<dateAddPopup> {
  TextEditingController dateinput = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.fromLTRB(35, 90, 35, 90),
        child: Hero(
          tag: recipePopupId,
          child: Material(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            child: Container(
              child: Padding(
                padding: EdgeInsets.all(30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.itemName,
                            style: labelStyleBold.copyWith(
                              fontSize: 20,
                            )),
                        SizedBox(
                          height: 40,
                        ),
                        Text(
                          'Select date: ',
                          style: labelStyle,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextField(
                          controller: dateinput,
                          onTap: () async {
                            var pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2010),
                              lastDate: DateTime(2100),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: kOrange, // <-- SEE HERE
                                      onPrimary: Colors.black38, // <-- SEE HERE
                                      onSurface: Colors.black38, // <-- SEE HERE
                                    ),
                                    textButtonTheme: TextButtonThemeData(
                                      style: TextButton.styleFrom(
                                        backgroundColor:
                                            Colors.white, // button text color
                                      ),
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (pickedDate != null) {
                              setState(() {
                                dateinput.text = DateFormat('yyyy-MM-dd')
                                    .format(pickedDate)
                                    .toString();
                              });
                            }
                          },
                          readOnly: true,
                          decoration: textBarDecoration,
                        ),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kOrange,
                      ),
                      onPressed: () {
                        FirebaseFirestore.instance
                            .collection('food')
                            .doc(widget.id)
                            .update({'expiration_date': dateinput.text});
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Confirm',
                        style: labelStyle.copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class recipeAddPopup extends StatefulWidget {
  @override
  State<recipeAddPopup> createState() => _recipeAddPopupState();
}

class _recipeAddPopupState extends State<recipeAddPopup> {
  @override
  void initState() {
    super.initState();
  }

  String input = '';
  int tabIndex = 0;
  @override
  List<Widget> customDelegate() {
    return [
      Container(
        child: Text("hello"),
      ),
    ];
  }

  List<Product?> recipeItems = [];

  Widget build(BuildContext context) {
    Product? result;
    var textController = TextEditingController();

    List<Widget> tabs = [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search for ingredients:',
            style: labelStyle,
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
            readOnly: true,
            controller: textController,
            decoration: textBarDecoration.copyWith(
              suffixIcon: const Icon(
                Icons.search,
                color: kOrange,
              ),
            ),
            onTap: () async {
              print("Pressing search...");
              result = await showSearch<Product?>(
                context: context,
                delegate: RecipeSearchDelegate(),
              );
              if (result != null) {
                textController.text = result?.productName ?? "missingno";
                setState(() {
                  recipeItems.add(result);
                });
              }
            },
          ),
          SizedBox(height: 20),
          SizedBox(
            height: 270,
            child: ListView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: recipeItems.length,
              itemBuilder: (context, index) {
                return ItemSearchCard(
                    onTap: () {},
                    itemName: recipeItems?[index]?.productName ?? '',
                    image_url: recipeItems?[index]?.imageFrontUrl ?? '');
              },
            ),
          ),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recipe name: ',
            style: labelStyle,
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
            onChanged: (value) {
              input = value;
            },
            decoration: textBarDecoration,
          ),
        ],
      ),
    ];
    return Center(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 70, 20, 70),
        child: Hero(
          tag: recipePopupId,
          child: Material(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            child: Container(
              child: Padding(
                padding: EdgeInsets.all(30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    tabs[tabIndex],
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kOrange,
                      ),
                      onPressed: () {
                        if (tabIndex == 0) {
                          print('--pressing next--');
                          setState(() {
                            tabIndex = 1;
                          });
                        } else {
                          List<RecIngredient> ingredients = [];
                          for (var recipeItem in recipeItems) {
                            ingredients.add(
                              RecIngredient(
                                  name: recipeItem?.productName ?? '',
                                  image_url: recipeItem?.imageFrontUrl ?? '',
                                  barcode: recipeItem?.barcode ?? ''),
                            );
                          }
                          sendRecipeToCould(
                              recipe: Recipe(
                            name: input,
                            ingredients: ingredients,
                          ));
                          Navigator.pop(context);
                        }
                      },
                      child: Text(
                        (tabIndex == 0) ? 'next' : 'add',
                        style: labelStyle.copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RecipeSearchDelegate extends SearchDelegate<Product?> {
  @override
  List<Widget>? buildActions(BuildContext context) => [
        IconButton(
          onPressed: () {
            query = '';
            if (query.isEmpty) {
              close(context, null);
            }
          },
          icon: const Icon(Icons.close),
        )
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        onPressed: () => close(context, null),
        icon: const Icon(Icons.arrow_back),
      );

  @override
  Widget buildResults(BuildContext context) {
    Future<SearchResult> querySearch() {
      User foodUser =
          User(userId: 'txtxxx123@gmail.com', password: 'secretword123');

      var parameters = <Parameter>[
        const PageNumber(page: 0),
        const PageSize(size: 20),
        const SortBy(option: SortOption.POPULARITY),
        SearchTerms(terms: [query]),
      ];

      ProductSearchQueryConfiguration configuration =
          ProductSearchQueryConfiguration(
        parametersList: parameters,
        fields: [
          ProductField.NAME,
          ProductField.IMAGE_FRONT_URL,
          ProductField.BARCODE
        ],
      );

      return OpenFoodAPIClient.searchProducts(foodUser, configuration);
    }

    return FutureBuilder(
        future: querySearch(),
        builder: (context, AsyncSnapshot<SearchResult> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
                itemCount: snapshot.data?.products?.length ?? 0,
                itemBuilder: (context, index) {
                  final productName =
                      snapshot.data?.products?[index].productName ?? "";
                  final imageUrl =
                      snapshot.data?.products?[index].imageFrontUrl ?? "";
                  if (productName != "" && imageUrl != "") {
                    return ItemSearchCard(
                      onTap: () {
                        close(context, snapshot.data?.products?[index]);
                      },
                      itemName: productName,
                      image_url: imageUrl,
                    );
                  }
                  return Container();
                });
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    //do nothing
    return Container();
  }
}
