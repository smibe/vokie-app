import 'package:vokie/LessonState.dart';
import 'package:vokie/event.dart';
import 'package:vokie/json_object.dart';
import 'package:vokie/vokable.dart';

class Lesson {
  Lesson(JsonObject values){
    this.data.lesson = getWords(values);
  }
  LessonState data = LessonState();
  int selected = 0;
  Event<LessonState> hasChanged = new Event<LessonState>();

  List<Vokabel> getWords(JsonObject values) {
    List<Vokabel> result = List<Vokabel>();
    for (var word in values.getList("words")) {
      result.add(Vokabel(word["src"].toString(), word["dest"].toString()));
    }
    return result;
  }

  void select(int idx) {
    this.data.selected = idx;
    hasChanged.invoke(this.data);
  }

  void notifyChanged() => hasChanged.invoke(this.data);

  Vokabel get selectedVokabel  => this.data.selectedVokabel;

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
