import 'package:flutter/material.dart';

// sqlite
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:logbook/models/tag.dart';
import 'package:logbook/models/history.dart';
import 'package:logbook/views/screens/daily_histories.dart';
import 'package:logbook/views/screens/tag_histories.dart';
import 'package:logbook/views/screens/tags.dart';

const appName = "Logbook";

void main() async {
  await init();

  runApp(const MyApp());
}

Future<void> init() async {
  // Avoid errors caused by flutter upgrade.
  // Importing 'package:flutter/widgets.dart' is required.
  WidgetsFlutterBinding.ensureInitialized();
  // Open the database and store the reference.
  final database = openDatabase(
    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    join(await getDatabasesPath(), 'logbook_database.db'),

    onCreate: (db, version) {
      // Run the CREATE TABLE statement on the database.
      return db.execute(
        [Tag.createTagTableStatement(), History.createTagTableStatement()]
            .join(";"),
      );
    },
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    version: 1,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: appName),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

enum Screen {
  dailyHistories,
  tagHistories,
  tags,
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  Screen currentScreen = Screen.dailyHistories;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void switchScreen(BuildContext context, Screen screen) {
    setState(() {
      currentScreen = screen;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              child: Text("Menu"),
            ),
            ListTile(
                title: const Text("Daily histories"),
                onTap: () {
                  switchScreen(context, Screen.dailyHistories);
                }),
            ListTile(
                title: const Text("Tag histories"),
                onTap: () {
                  switchScreen(context, Screen.tagHistories);
                }),
            ListTile(
                title: const Text("Tags"),
                onTap: () {
                  switchScreen(context, Screen.tags);
                }),
          ],
        ),
      ),
      body: currentScreen == Screen.dailyHistories
          ? const DailyHistories()
          : (currentScreen == Screen.tagHistories
              ? const TagHistories()
              : (currentScreen == Screen.tags
                  ? const Tags()
                  : Center(
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
                    ))),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
