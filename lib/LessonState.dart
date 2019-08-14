import 'package:vokie/vokable.dart';

import 'json_object.dart';

class LessonState {
    String name;
    List<Vokabel> lesson;
    int selected = 0;
    Vokabel get selectedVokabel => lesson[selected];

    LessonState();
    LessonState.fromJson(dynamic obj) {
      name = obj["name"] ?? "";
      lesson = getWords(JsonObject(obj));
    }

  List<Vokabel> getWords(JsonObject values) {
    List<Vokabel> result = List<Vokabel>();
    for (var word in values.getList("words")) {
      result.add(Vokabel.fromDynamic(word));
    }
    return result;
  }

    toJson() {
      return {
        "name": name,
        "words": lesson,
      };
    }
}