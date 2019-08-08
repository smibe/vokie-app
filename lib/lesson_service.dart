import 'dart:async';

import 'package:vokie/DiContainer.dart';
import 'package:vokie/jsonApi.dart';
import 'package:vokie/json_object.dart';
import 'package:vokie/lesson.dart';

class LessonService {
  JsonApi api = DiContainer.resolve<JsonApi>();

  Future<Lesson> getLesson({int idx = 0}) async {
    var data = await getData(format: "csv");
    return getLessonFromData(data);
  }

  Future<Lesson> getLessonFromData(JsonObject data) async {
    var lessons = data.getList("lessons");
    var lessonData = lessons[0];

    var lesson = lessonData["words"] != null ? JsonObject.fromDynamic(lessonData) : await api.get(lessonData["url"]);

    return Lesson(lesson);
  }

  Future<JsonObject> getData({String format = "json"}) async {
    if (format == "json") {
      return api.getById("1lA-vhaxchV-4wi6quSQdOJAYbyZ3n_5g");
    } else {
      var csvContent = await api.getContentById("17dXxdYM10PzKbtGelsfNnyTb05UbK5-H");
      return Future.value(parseCsv(csvContent));
    }
  }

  JsonObject parseCsv(String csvContent) {
    var lines = csvContent.split("\n");
    var  data = Map<String, dynamic>();
    var lessons = List<dynamic>();
    data["lessons"] = lessons;
    var lesson;
    var words;
    for (var line in lines.skip(1)) {
      var fields = line.split(';');
      var name = fields[0].trim();
      if (name != "")
      {
        lesson = Map<String, dynamic>();
        lesson["name"] = name;
        words = List<dynamic>();
        lesson["words"] = words;
        lessons.add(lesson);
      }  else if (lesson != null) {
        if (fields.length >=2 && fields[1] != "" && fields[2] != null) {
          var word = Map<String, dynamic>();
          word["src"] = fields[1].trim();
          word["dest"] = fields[2];
          words.add(word);
        }
      }
    }
    return JsonObject.fromDynamic(data);
  }
}
