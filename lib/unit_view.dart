import 'package:flutter/material.dart';
import 'package:vokie/DiContainer.dart';
import 'package:vokie/storage.dart';

import 'json_object.dart';
import 'lesson_service.dart';

class UnitView extends StatefulWidget {
  UnitView();

  @override
  _UnitViewState createState() => _UnitViewState();
}

class _UnitViewState extends State<UnitView> {
  JsonObject unit;
  int selection;
  var _storage = DiContainer.resolve<Storage>();
  String _currentUnitId;
  List<dynamic> _units;
  LessonService lessonService = LessonService();

  dynamic _currentUnit;

  @override
  void initState() {
    _currentUnitId = _storage.getString("current_unit_id");
    _units = lessonService.getUnits();
    _retrieveCurrentUnit();
    selection = _storage.get("current_idx", 0);
    super.initState();
  }

  void _retrieveCurrentUnit() {
    _currentUnit =
        _units.firstWhere((x) => x["id"] == _currentUnitId, orElse: (() => _units[0] as Map<String, String>));

    lessonService.getData(format: "cvs", unit: _currentUnit["id"]).then((d) {
      setState(() => unit = d);
    });
  }

  void _refreshCurrentUnit() async {
    await lessonService.removeCached(unit: _currentUnit["id"]);
    var data = await lessonService.getData(format: "cvs", unit: _currentUnit["id"]);
    setState(() => unit = data);
  }

  String get currentId => _currentUnit["id"];

  getItems() {
    var list = _units.map((u) {
      return DropdownMenuItem<String>(value: u["id"].toString(), child: Text(u["name"]));
    });
    return list.toList();
  }

  @override
  Widget build(BuildContext context) {
    var lessons = unit?.getList("lessons") ?? new List<dynamic>();
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: <Widget>[
              DropdownButton<String>(
                value: currentId,
                items: getItems(),
                onChanged: (value) {
                  setState(() {
                    _currentUnitId = value;
                    _retrieveCurrentUnit();
                    _storage.setString("current_unit_id", value);
                    _storage.remove("current_idx");
                  });
                },
              ),
              Expanded(child: Padding(padding: EdgeInsets.all(0))),
              IconButton(
                  onPressed: () {
                    _refreshCurrentUnit();
                  },
                  icon: Icon(
                    Icons.refresh,
                  ))
            ],
          ),
        ),
        Expanded(
          child: Container(
            child: ListView.builder(
              itemCount: lessons.length,
              itemBuilder: (BuildContext context, int index) {
                return Row(
                  children: <Widget>[
                    Radio(
                      value: index,
                      groupValue: selection,
                      onChanged: (int value) {
                        DiContainer.resolve<Storage>().remove("current");
                        DiContainer.resolve<Storage>().setString("current_idx", value.toString());
                        setState(() {
                          selection = value;
                        });
                      },
                    ),
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
