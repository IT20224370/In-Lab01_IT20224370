import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipeModel.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final keyValue = GlobalKey<FormState>();
  final titleOnChangeHandler = TextEditingController();
  final descriptionOnChangeHandler = TextEditingController();
  final ingredientOnChangeHandler = TextEditingController();
  late CollectionReference recipesCollRef;

  @override
  void initState() {
    super.initState();
    recipesCollRef = FirebaseFirestore.instance.collection('recipes');
  }

  @override
  void dispose() {
    titleOnChangeHandler.dispose();
    descriptionOnChangeHandler.dispose();
    ingredientOnChangeHandler.dispose();
    super.dispose();
  }

  void showAddRecipeBox() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Recipe'),
          content: Form(
            key: keyValue,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleOnChangeHandler,
                  decoration: InputDecoration(
                    labelText: 'Title',
                  ),
                  //validate whether user enter a title for the recipe
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                //validate whether user enter a description
                TextFormField(
                  controller: descriptionOnChangeHandler,
                  decoration: InputDecoration(
                    labelText: 'Description',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: ingredientOnChangeHandler,
                  decoration: InputDecoration(
                    labelText: 'Ingredients (separated by commas)',
                  ),
                  //validate whether user enters at least one ingredient
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter at least one ingredient';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (keyValue.currentState!.validate()) {
                  final title = titleOnChangeHandler.text;
                  final description = descriptionOnChangeHandler.text;
                  final ingredients = ingredientOnChangeHandler.text
                      .split(',')
                      .map((e) => e.trim())
                      .toList();
                  await recipesCollRef.add(Recipe(
                          title: title,
                          description: description,
                          ingredients: ingredients)
                      .toJson());
                  Navigator.pop(context);
                  titleOnChangeHandler.clear();
                  descriptionOnChangeHandler.clear();
                  ingredientOnChangeHandler.clear();
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void showEditRecipeBox(DocumentSnapshot recipeSnapshot) async {
    final recipe =
        Recipe.fromJson(recipeSnapshot.data() as Map<String, dynamic>);
    titleOnChangeHandler.text = recipe.title;
    descriptionOnChangeHandler.text = recipe.description;
    ingredientOnChangeHandler.text = recipe.ingredients.join(', ');

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Recipe'),
          content: Form(
            key: keyValue,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleOnChangeHandler,
                  decoration: InputDecoration(
                    labelText: 'Title',
                  ),

                  //validate whether user enter a title for the recipe
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: descriptionOnChangeHandler,
                  decoration: InputDecoration(
                    labelText: 'Description',
                  ),

                  //validate whether user enter a description
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),

                //validate whether user enters at least one ingredient
                TextFormField(
                  controller: ingredientOnChangeHandler,
                  decoration: InputDecoration(
                    labelText: 'Ingredients (separated by commas)',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter at least one ingredient';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (keyValue.currentState!.validate()) {
                  final title = titleOnChangeHandler.text;
                  final description = descriptionOnChangeHandler.text;
                  final ingredients = ingredientOnChangeHandler.text
                      .split(',')
                      .map((e) => e.trim())
                      .toList();
                  await recipeSnapshot.reference.update(Recipe(
                          title: title,
                          description: description,
                          ingredients: ingredients)
                      .toJson());
                  Navigator.pop(context);
                  titleOnChangeHandler.clear();
                  descriptionOnChangeHandler.clear();
                  ingredientOnChangeHandler.clear();
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void showDeleteRecipeConfirmBox(DocumentSnapshot recipeSnapshot) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmation Recipe Deletion'),
          content: Text('Are you sure, do you want to delete selected recipe?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await recipeSnapshot.reference.delete();
                Navigator.pop(context);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recipes List'), //title of the screen
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: recipesCollRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final recipes = snapshot.data!.docs
              .map((doc) => Recipe.fromJson(doc.data() as Map<String, dynamic>))
              .toList();

          return ListView.builder(
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              return ListTile(
                title: Text(recipe.title),
                subtitle: Text(recipe.description),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    showDeleteRecipeConfirmBox(snapshot.data!.docs[index]);
                  },
                ),
                onTap: () {
                  showEditRecipeBox(snapshot.data!.docs[index]);
                },
              );
            },
          );
        },
      ),

      //floating add action button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddRecipeBox();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
