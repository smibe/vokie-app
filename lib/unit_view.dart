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
  List<dynamic> _units = List<dynamic>();
  LessonService lessonService = DiContainer.resolve<LessonService>();

  dynamic _currentUnit;

  @override
  void initState() {
    _currentUnitId = _storage.getString("current_unit_id");
    _retrieveCurrentUnit().then((d) {
        setState(() => unit = d);
    });
    selection = _storage.get("current_idx", 0);
    _storage.valueChanged("current_unit_id").add(onUnitChanged);
    super.initState();
  }

  @override
  void dispose()
  {
    _storage.valueChanged("current_unit_id").handlers.remove(onUnitChanged); 
    super.dispose();
  }

  void onUnitChanged(String unitId) async
  {
      var u = await _retrieveCurrentUnit();
      setState(() {
        unit = u;
      });
 }

  Future<JsonObject> _retrieveCurrentUnit() async {
    _units = await lessonService.getUnits();
    _currentUnit = _units.firstWhere((x) => x["id"] == _currentUnitId,
          orElse: (() => _units[0] as Map<String, dynamic>));

    if (_currentUnit == null) return null;
    return await lessonService.getData(format: "cvs", unit: _currentUnit["id"]);
  }

  void _refreshCurrentUnit() async {
    lessonService.resetUnits();
    await lessonService.removeCached(unit: _currentUnit["id"]);
    var data = await _retrieveCurrentUnit();

    await lessonService.updateCurrentLesson();
    setState(() => unit = data);
  }

  getItems() {
    var list = _units.map((u) {
      return DropdownMenuItem<dynamic>(value: u, child: Text(u["name"]));
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
              DropdownButton<dynamic>(
                value: _currentUnit,
                items: getItems(),
                onChanged: (value) {
                  setState(() {
                    _currentUnitId = value["id"];
                    _retrieveCurrentUnit();
                    _storage.setString("current_unit_id", value["id"]);
                    _storage.setString("current_unit_name", value["name"]);
                    _storage.remove("current_idx");
                    _storage.remove("current");
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
                        DiContainer.resolve<Storage>()
                            .setString("current_idx", value.toString());
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
