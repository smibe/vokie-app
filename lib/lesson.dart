import 'package:vokie/json_object.dart';
import 'package:vokie/vokable.dart';

class Lesson {
  JsonObject data;
  Lesson(JsonObject this.data);

  List<Vokabel> getWords() {
    List<Vokabel> result = List<Vokabel>();
    for (var word in data.getList("words")) {
      result.add(Vokabel(word["src"].toString(), word["dest"].toString()));
    }
    return result;
  }
}
