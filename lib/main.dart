import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// sqlite
import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:logbook/models/enum/screen.dart';
import 'package:logbook/models/tag.dart';
import 'package:logbook/models/history.dart';
import 'package:logbook/views/screens/tag_histories.dart';
import 'package:logbook/views/screens/tags.dart';
import 'package:logbook/views/screens/category_tags.dart';

const appName = "Logbook";

void main() async {
  final database = await init();

  runApp(MyApp(database: database));
}

Future<Database> init() async {
  // Avoid errors caused by flutter upgrade.
  // Importing 'package:flutter/widgets.dart' is required.
  WidgetsFlutterBinding.ensureInitialized();
  // Open the database and store the reference.
  final database = openDatabase(
    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    join(await getDatabasesPath(), 'logbook_database.db'),

    onCreate: (db, version) async {
      // Run the CREATE TABLE statement on the database.
      await db.execute(Tag.createTagTableStatement());
      await db.execute(History.createTagTableStatement());
    },
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    version: 1,
  );

  return database;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.database});

  final Database database;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(title: appName, database: database),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.database});

  final String title;
  final Database database;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  Screen currentScreen = Screen.tags;
  Category currentCategory = Category.undefined;
  List<Tag> tags = [];
  var now = DateTime.now();
  int tagId = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void switchCategoryScreen(BuildContext context, Category category) {
    setState(() {
      currentCategory = category;
      currentScreen = Screen.categoryTags;
      tags = [];
    });
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();

    loadTags();
  }

  void loadTags() async {
    getTags(widget.database).then((result) {
      final target = result;
      target.sort((a, b) => b.updatedTimestamp.compareTo(a.updatedTimestamp));
      setState(() {
        tags = target;
      });
    });
  }

  void switchScreen(BuildContext context, Screen screen) {
    setState(() {
      currentScreen = screen;
    });

    switch (currentScreen) {
      case Screen.tags:
        loadTags();
      default:
        return;
    }
    Navigator.pop(context);
  }

  Widget drawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            child: Text("Menu"),
          ),
          ListTile(
              title: Text(Screen.tags.label),
              onTap: () {
                switchScreen(context, Screen.tags);
              }),
          ...availableCategories()
              .map((category) => ListTile(
                  title: Text(category.label),
                  onTap: () {
                    switchCategoryScreen(context, category);
                  }))
              .toList(),
        ],
      ),
    );
  }

  Widget body(BuildContext context) {
    switch (currentScreen) {
      case Screen.tags:
        return Tags(database: widget.database, datetime: now, tags: tags);
      case Screen.categoryTags:
        return CategoryTags(
            database: widget.database, category: currentCategory);
      case Screen.tagHistories:
        return TagHistories(database: widget.database);
      default:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'You have pushed the button this many times:',
              ),
              Text(
                '$_counter',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      drawer: drawer(context),
      body: SingleChildScrollView(child: body(context)),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
