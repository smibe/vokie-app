import 'package:flutter/material.dart';
import 'package:vokie/LessonState.dart';
import 'package:vokie/lesson.dart';

@immutable
class LessonView extends StatelessWidget {
  final LessonState state;
  final Lesson lesson;
  final Function onChanged;

  LessonView(this.lesson, {@required this.onChanged}) : this.state = lesson.data;

  final Widget empty = Container(width: 0.0, height: 0.0);

  Widget createItem(context, idx) {
    var vokabel = state.lesson[idx];
    var showTarget = vokabel.showTarget;

    return GestureDetector(
      onTap: () {
        this.lesson.select(idx);
      },
      child: Container(
        padding: EdgeInsets.all(10.0),
        decoration: new BoxDecoration(
            color: idx == this.lesson.data.selected ? Color.fromRGBO(220, 220, 220, 1.0) : Colors.white),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(vokabel.target, style: TextStyle(fontSize: 28.0)),
                Text(showTarget ? vokabel.source : "", style: TextStyle(fontSize: 18.0)),
                showTarget
                    ? Row(
                        children: [
                          Text(vokabel.correct.toString(),
                              style: TextStyle(color: vokabel.correct == 0 ? Colors.black : Colors.green)),
                          Text(" / "),
                          Text(vokabel.wrong.toString(),
                              style: TextStyle(color: vokabel.wrong == 0 ? Colors.black : Colors.red)),
                        ],
                      )
                    : empty,
              ]),
            ),
            idx == this.state.selected
                ? Container(
                    width: 100,
                    alignment: Alignment.centerRight,
                    child: Column(
                      children: <Widget>[
                        RaisedButton(
                            onPressed: () {
                              onChanged();
                              if (!state.selectedVokabel.showTarget)
                                this.lesson.showTarget(true);
                              else {
                                this.lesson.correct();
                                this.lesson.select(idx + 1);
                              }
                            },
                            color: Color(0xee89fb98),
                            child: Text(vokabel.showTarget ? "Richtig" : "OK")),
                        vokabel.showTarget
                            ? RaisedButton(
                                onPressed: () {
                                  this.lesson.wrong();
                                  this.lesson.select(idx + 1);
                                },
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

  @override
  Widget build(BuildContext context) {
    var body = Theme.of(context).textTheme.headline;
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(10),
          color: Color(0xffe0e0e0),
                  child: Row(
            children: <Widget>[
              Text(state.name ?? "unknown", style: body),
              Text("    ${state.currentDone}/${state.total - state.done} (${state.total})", style: body),
            ],
          ),
        ),
        Expanded(
          child: Container(
            child: ListView.builder(
              padding: EdgeInsets.all(10.0),
              itemCount: state.lesson.length,
              itemBuilder: createItem,
            ),
          ),
        ),
      ],
    );
  }
}
