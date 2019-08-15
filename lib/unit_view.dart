import 'package:flutter/material.dart';
import 'package:vokie/DiContainer.dart';
import 'package:vokie/storage.dart';

import 'json_object.dart';
import 'lesson_service.dart';

class UnitView extends StatefulWidget {
  final String name;

  UnitView(this.name);

  @override
  _UnitViewState createState() => _UnitViewState();
}

class _UnitViewState extends State<UnitView> {
  JsonObject unit;
  int selection;

  @override
  void initState() {
    LessonService lessonService = LessonService();
    lessonService.getData(format: "cvs").then((d) {
      setState(() => unit = d);
    });
    selection = DiContainer.resolve<Storage>().get("current_idx", 0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var lessons = unit?.getList("lessons") ?? new List<dynamic>();
    return Column(
      children: <Widget>[
        Text(
          widget.name,
        ),
        Expanded(
          child: Container(
            child: ListView.builder(
              itemCount: lessons.length,
              itemBuilder: (BuildContext context, int index) {
                return Row(
                  children: <Widget>[
                    Radio(value: index, groupValue: selection, onChanged: (int value) {
                      DiContainer.resolve<Storage>().remove("current");
                      DiContainer.resolve<Storage>().setString("current_idx", value.toString());
                      setState((){selection = value;});
                    },),
                    Text(lessons[index]["name"]),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
