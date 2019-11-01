import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vokie/DiContainer.dart';
import 'package:vokie/LessonView.dart';
import 'package:vokie/jsonApi.dart';
import 'package:vokie/jsonHttp_api.dart';

import 'package:vokie/json_object.dart';
import 'package:vokie/lesson.dart';
import 'package:vokie/lesson_service.dart';
import 'package:vokie/storage.dart';
import 'package:vokie/unit_view.dart';
import 'package:vokie/vokable.dart';

void main() async {
  await initialize();
  runApp(new MyApp());
}

Future initialize() async {
  DiContainer.setInstance<JsonApi>(new JsonHttpApi());
  var sharedPreferences = await SharedPreferences.getInstance();
  DiContainer.setInstance<SharedPreferences>(sharedPreferences);
  DiContainer.setInstance<Storage>(Storage());
  DiContainer.setInstance<LessonService>(LessonService());
  DiContainer.setInstance<AudioPlayer>(AudioPlayer());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Vokabeltrainer',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Lektionen'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var lessonsJson = """
  {
    "name": "dummy",
    "source": "Deutsch",
    "destination": "English",
    "words":[
    ]
  }""";

  _MyHomePageState() {
    var jsonLessons = JsonObject.fromDynamic(json.decode(lessonsJson));
    this.lessonController = Lesson(jsonLessons);
  }

  Lesson lessonController;
  String view = "lesson";

  Storage _storage;
  bool _hasChanged = false;

  LessonService service;
  List<Vokabel> lesson;

  int selected = 0;

  Widget empty = Container(width: 0.0, height: 0.0);
  Timer _timer;

  List setVisible = new List<int>();
  void allVisible() {
    setVisible.clear();
    for (int i = 0; i < lesson.length; i++) {
      if (!lesson[i].showTarget) {
        lesson[i].showTarget = true;
        setVisible.add(i);
      }
    }
  }

  void restart() {
    for (var v in lesson) 
    {
      v.showTarget = false;
      v.lastResponse = LastResponse.unknown;
    }
  }

  void resetVisible() {
    for (var idx in setVisible) lesson[idx].showTarget = false;
  }

  void save() {
    if (_hasChanged) {
      service.storeCurrentLesson(_storage, lessonController);
    }
    _hasChanged = false;
  }

  @override
  void initState() {
    _storage = DiContainer.resolve<Storage>();

    _timer = Timer.periodic(Duration(seconds: 5), (t) {
      save();
    });
    
    getCurrentLesson();

    _storage.valueChanged("current_idx").add((v){
      getCurrentLesson();
    });
    
    super.initState();

  }

  void getCurrentLesson() {
    this.service = new LessonService();
    service.getCurrentLesson(_storage).then((l) {
      var firstLesson = l.data.lesson;
      this.lessonController = l;
      this.lessonController.hasChanged.add((s) => setState(() {}));
      setState(() => this.lesson = firstLesson);
    });
  }

  @override
  void dispose() {
    save();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var scaffold = new Scaffold(
        appBar: new AppBar(title: Text(widget.title), actions: <Widget>[
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () {
              setState(() => view = "unit");
            },
          ),
          IconButton(
            icon: Icon(Icons.check_box_outline_blank),
            onPressed: () {
              setState(() => view = "lesson");
            },
          ),
          view == "lesson"
              ? IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: () => setState(() => restart()),
                )
              : empty,
          view == "lesson"
              ? GestureDetector(
                  onTapDown: (d) => setState(() => allVisible()),
                  onTap: () => setState(() => resetVisible()),
                  child: IconButton(icon: Icon(Icons.visibility), onPressed: () => setState(() => resetVisible())),
                )
              : empty,
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {},
          ),
        ]),
        body: getView (view));
    return scaffold;
  }

  Widget getView(String view) {
    switch (view) {
      case "lesson":
        return LessonView(this.lessonController, onChanged: () => _hasChanged = true);
        case "unit":
        return UnitView();
      default:
        return empty;
    }
  }
}
