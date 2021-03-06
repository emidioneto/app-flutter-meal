import 'package:app_flutter_meal/models/meal.dart';
import 'package:app_flutter_meal/screens/recipe_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RecipesScreen extends StatefulWidget {
  RecipesScreen(
      {Key? key,
      required this.title,
      required this.filter,
      required this.category})
      : super(key: key);

  final String title;
  final String filter;
  final String category;

  @override
  _RecipesScreenState createState() =>
      _RecipesScreenState(this.filter, this.category);
}

class _RecipesScreenState extends State<RecipesScreen> {
  final String apiUrlTemplate =
      "https://www.themealdb.com/api/json/v1/1/filter.php?categoryParam=filterParam";

  final String filter;

  final String category;

  late Future<MealSeries> mealSeries;

  _RecipesScreenState(this.filter, this.category);

  Future<String> _loadRemoteData(String filter, String category) async {
    String apiUrl = apiUrlTemplate
        .replaceFirst("filterParam", filter)
        .replaceFirst("categoryParam", category);
    final response = await (http.get(Uri.parse(apiUrl)));
    if (response.statusCode == 200) {
      print('response statusCode is 200');
      return response.body;
    } else {
      print('Http Error: ${response.statusCode}!');
      throw Exception('Invalid data source.');
    }
  }

  Future<MealSeries> fetchMeals() async {
    String jsonString = await _loadRemoteData(this.filter, this.category);

    final jsonResponse = json.decode(jsonString);

    MealSeries mealSeries = new MealSeries.fromJson(jsonResponse);

    return mealSeries;
  }

  @override
  void initState() {
    super.initState();
    mealSeries = fetchMeals();
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      title: Text("Best Recipes"),
    );
  }

  Widget mealCard(Meal item) {
    return Padding(
        padding: const EdgeInsets.all(10.0),
        child: GestureDetector(
          onTap: () {
            print("navigating to RecipeScreen with param:" + item.id);
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => RecipeScreen(
                      key: null, title: item.name, filter: item.id)),
            );
          },
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: 50.0,
                      height: 50.0,
                      decoration: new BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.dinner_dining,
                        color: Colors.black,
                        size: 24.0,
                        semanticLabel: 'Meal ' + item.name,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        item.name,
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder<MealSeries>(
          future: mealSeries,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.dataModel.length,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    children: <Widget>[
                      mealCard(snapshot.data!.dataModel[index])
                    ],
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            }
            return CircularProgressIndicator();
          }),
    );
  }
}
