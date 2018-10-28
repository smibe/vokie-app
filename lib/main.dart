import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

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

class Vokabel {
  String source;
  String target;
  int correct = 0;
  int wrong = 0;
  bool showTarget = false;

  Vokabel(this.source, this.target);
}

class _MyHomePageState extends State<MyHomePage> {
  List<Vokabel> lesson = [
    Vokabel("Tisch", "table"),
    Vokabel("Fahrrad", "bicycle"),
  ];

  int selected = 0;

  void addVokabel(Vokabel vokabel) {
    setState(() {
      lesson.add(vokabel);
    });
  }

  Widget empty = Container(width: 0.0, height: 0.0);

  List setVisible = new List<int>();
  void allVisible(){
    setVisible.clear();
    for(int i = 0; i < lesson.length; i++)
    {
      if (!lesson[i].showTarget) {
        lesson[i].showTarget = true;
        setVisible.add(i);
      }
    }
  }

  void restart() {
    for (var v in lesson)
      v.showTarget = false;
  }

  void resetVisible() {
    for (var idx in setVisible)
      lesson[idx].showTarget = false;
  }

  @override
  Widget build(BuildContext context) {
    TextTheme tStyle = Theme.of(context).textTheme;
    return new Scaffold(
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
            icon: Icon(Icons.add),
            onPressed: () {},
          ),
        ]),
        body: new ListView.builder(
          padding: EdgeInsets.all(10.0),
          itemCount: lesson.length,
          itemBuilder: (context, idx) {
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
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(lesson[idx].target,
                              style: TextStyle(fontSize: 28.0)),
                          Text(lesson[idx].showTarget ? lesson[idx].source : "",
                              style: TextStyle(fontSize: 18.0)),
                         ]),
                    idx == selected
                        ? Container(
                            alignment: Alignment.centerRight,
                            child: Column(
                              children: <Widget>[
                                RaisedButton(
                                    onPressed: () => setState(() {
                                      if (!lesson[idx].showTarget)
                                        lesson[idx].showTarget = true;
                                      else 
                                        selected++;
                                    }),
                                    color: Colors.greenAccent,
                                    child: Text(lesson[idx].showTarget ? "Richtig" : "OK")),
                                lesson[idx].showTarget
                                ? RaisedButton(
                                  onPressed: () => setState(() {
                                    lesson[idx].wrong++;
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
          },
        ));
  }
}
