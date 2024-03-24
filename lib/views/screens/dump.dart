import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:text_area/text_area.dart';
import 'package:logbook/models/tag.dart';
import 'package:logbook/models/history.dart';

class Dump extends StatefulWidget {
  const Dump({super.key, required this.database});

  final Database database;

  @override
  State<Dump> createState() => DumpState();
}

class DumpState extends State<Dump> {
  List<History> histories = [];
  List<Tag> tags = [];

  @override
  void initState() {
    super.initState();

    reload();
  }

  void reload() async {
    getHistories(widget.database).then((result) {
      setState(() {
        histories = result;
      });
    });
    getTags(widget.database).then((result) {
      setState(() {
        tags = result;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final tagsController = TextEditingController(
        text: tags.map((tag) => tag.csv().join(",")).toList().join("\n"));
    final hitoriesController = TextEditingController(
        text: histories
            .map((history) => history.csv().join(","))
            .toList()
            .join("\n"));

    return Column(
        children: [tagsController, hitoriesController]
            .map(
              (controller) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TextArea(
                          borderRadius: 3,
                          borderColor: const Color(0xFFCFD6FF),
                          validation: false,
                          textEditingController: controller),
                    ],
                  ),
                ),
              ),
            )
            .toList());
  }
}
