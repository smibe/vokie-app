import 'dart:convert';

import 'package:vokie/LessonState.dart';
import 'package:vokie/event.dart';
import 'package:vokie/json_object.dart';
import 'package:vokie/vokable.dart';

class Lesson {
  Lesson.parse(String jsonContent) {
    var x = json.decode(jsonContent);
    data.name = x["name"];
    data.lesson = getWords(JsonObject.fromDynamic(x));
  }

  Lesson(JsonObject values) {
    this.data.lesson = getWords(values);
  }

  dynamic toJson() {
    return data.toJson();
  }

  LessonState data = LessonState();
  int selected = 0;
  Event<LessonState> hasChanged = new Event<LessonState>();

  List<Vokabel> getWords(JsonObject values) {
    List<Vokabel> result = List<Vokabel>();
    for (var word in values.getList("words")) {
      result.add(Vokabel.fromDynamic(word));
    }
    return result;
  }

  void select(int idx) {
    this.data.selected = idx;
    hasChanged.invoke(this.data);
  }

  void notifyChanged() => hasChanged.invoke(this.data);

  Vokabel get selectedVokabel => this.data.selectedVokabel;

  void correct() {
    selectedVokabel.correct++;
    notifyChanged();
  }

  void showTarget(bool show) {
    selectedVokabel.showTarget = show;
    notifyChanged();
  }

  void wrong() {
    selectedVokabel.wrong++;
    notifyChanged();
  }
}
