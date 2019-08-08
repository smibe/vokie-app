import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vokie/DiContainer.dart';
import 'package:vokie/LessonView.dart';
import 'package:vokie/jsonApi.dart';
import 'package:vokie/jsonHttp_api.dart';

import 'package:vokie/json_object.dart';
import 'package:vokie/lesson.dart';
import 'package:vokie/lesson_service.dart';
import 'package:vokie/vokable.dart';

void main() async {
  await initialize();
  runApp(new MyApp());
}

Future initialize() async {
  DiContainer.setInstance<JsonApi>(new JsonHttpApi());
  DiContainer.setInstance<SharedPreferences>(await SharedPreferences.getInstance());
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
  var  lessonsJson = """
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

  LessonService service;
  List<Vokabel> lesson;

  int selected = 0;

  Widget empty = Container(width: 0.0, height: 0.0);

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
    for (var v in lesson) v.showTarget = false;
  }

  void resetVisible() {
    for (var idx in setVisible) lesson[idx].showTarget = false;
  }

  @override
  void initState() {
    super.initState();

    this.service = new LessonService();
    service.getLesson().then((l) {
      var firstLesson = l.data.lesson;
      this.lessonController = l;
      this.lessonController.hasChanged.add((s) => setState((){}));
      setState(() => this.lesson = firstLesson);
    });
  }

  @override
  Widget build(BuildContext context) {
    TextTheme tStyle = Theme.of(context).textTheme;
    var scaffold = new Scaffold(
        appBar: new AppBar(title: new Text(widget.title), actions: <Widget>[
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.check_box_outline_blank),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => setState(() => restart()),
          ),
          GestureDetector(
            onTapDown: (d) => setState(() => allVisible()),
            onTap: () => setState(() => resetVisible()),
            child: IconButton(
                icon: Icon(Icons.visibility),
                onPressed: () => setState(() => resetVisible())),
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {},
          ),
        ]),
        body: new LessonView(this.lessonController));
    return scaffold;
  }

  Widget createItem(context, idx) {
    var vokabel = lesson[idx];
    var showTarget = vokabel.showTarget;

    return GestureDetector(
      onTap: () {
        setState(() {
          selected = idx;
        });
      },
      child: Container(
        padding: EdgeInsets.all(10.0),
        decoration: new BoxDecoration(
            color: idx == selected
                ? Color.fromRGBO(220, 220, 220, 1.0)
                : Colors.white),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(vokabel.target, style: TextStyle(fontSize: 28.0)),
              Text(showTarget ? vokabel.source : "",
                  style: TextStyle(fontSize: 18.0)),
              showTarget
                  ? Row(
                      children: [
                        Text(vokabel.correct.toString(),
                            style: TextStyle(
                                color: vokabel.correct == 0
                                    ? Colors.black
                                    : Colors.green)),
                        Text(" / "),
                        Text(vokabel.wrong.toString(),
                            style: TextStyle(
                                color: vokabel.wrong == 0
                                    ? Colors.black
                                    : Colors.red)),
                      ],
                    )
                  : empty,
            ]),
            idx == selected
                ? Container(
                    alignment: Alignment.centerRight,
                    child: Column(
                      children: <Widget>[
                        RaisedButton(
                            onPressed: () => setState(() {
                                  if (!vokabel.showTarget)
                                    vokabel.showTarget = true;
                                  else {
                                    selected++;
                                    vokabel.correct++;
                                  }
                                }),
                            color: Colors.greenAccent,
                            child: Text(
                                vokabel.showTarget ? "Richtig" : "OK")),
                        vokabel.showTarget
                            ? RaisedButton(
                                onPressed: () => setState(() {
                                      vokabel.wrong++;
                                      selected++;
                                    }),
                                color: Colors.orangeAccent,
                                child: Text("Falsch"))
                            : empty,
                      ],
                    ))
                : empty,
          ],
        ),
      ),
    );
  }
}
