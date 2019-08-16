import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:vokie/DiContainer.dart';
import 'package:vokie/jsonApi.dart';
import 'package:vokie/json_object.dart';
import 'package:vokie/lesson.dart';
import 'package:vokie/storage.dart';

const String basicFrench = "17dXxdYM10PzKbtGelsfNnyTb05UbK5-H";
const String frenchSentences = "1C8H2UAHj5wB_Gi8MZBlGF-n_k1rbJeKT";

class LessonService {
  JsonApi api = DiContainer.resolve<JsonApi>();

  Future<Lesson> getCurrentLesson(Storage storage) async {
    if (!storage.containsKey("current")) {
      var idx = storage.get("current_idx", 0);
      return getLesson(storage, idx: idx);
    }

    var fileName = storage.getString("current");
    if (!await File(fileName).exists()) return getLesson(storage);

    return await loadLesson(storage.getString("current"));
  }

  dynamic getUnits() {
    return [
      {
        "name": "Basiswortschatz",
        "id": basicFrench,
      },
      {
        "name": "Französische Sätze",
        "id": frenchSentences,
      }
    ];
  }

  Future storeCurrentLesson(Storage storage, Lesson lesson) async {
    storage.set("current", await toFileName(lesson));
    return storeLesson(lesson);
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path + "/";
  }

  Future<Lesson> loadLesson(String fileName) async {
    var content = await File(fileName).readAsString();
    return Lesson.parse(content);
  }

  Future<String> toFileName(Lesson lesson, {String unit = basicFrench}) async {
    var name = lesson.data.name ?? "current_lesson";
    name = name.replaceAll(" ", "_") + ".json";
    var dir = await _localPath + unit;
    if (!await Directory(dir).exists()) Directory(dir).create();
    return await _localPath + unit + "/" + name;
  }

  Future storeLesson(Lesson lesson) async {
    var contents = json.encode(lesson);
    return await File(await toFileName(lesson)).writeAsString(contents);
  }

  Future<Lesson> getLesson(Storage storage, {int idx = 0}) async {
    if (storage.containsKey("current") && await File(storage.getString("current")).exists()) {
      return await loadLesson(storage.getString("current"));
    }
    var unit = storage.get("current_unit_id", basicFrench);
    var data = await getData(format: "csv", unit: unit);
    return getLessonFromData(data, idx);
  }

  Future<Lesson> getLessonFromData(JsonObject data, int idx) async {
    var lessons = data.getList("lessons");
    var lessonData = lessons[idx];

    var fileName = await toFileName(Lesson(JsonObject.fromDynamic(lessonData)));
    if (await File(fileName).exists()) return await loadLesson(fileName);

    var lesson = lessonData["words"] != null ? JsonObject.fromDynamic(lessonData) : await api.get(lessonData["url"]);

    return Lesson(lesson);
  }

  Future<String> unitFileName(String unit) async {
    return (await _localPath) + unit + ".csv;";
  }

  Future<JsonObject> getData({String format = "json", String unit = basicFrench}) async {
    if (format == "json") {
      return api.getById("1lA-vhaxchV-4wi6quSQdOJAYbyZ3n_5g");
    } else {
      String csvContent;
      var file = File(await unitFileName(unit));
      if (await file.exists()) {
        csvContent = await file.readAsString();
      } else {
        csvContent = await api.getContentById(unit);
        file.writeAsString(csvContent);
      }
      return Future.value(parseCsv(csvContent));
    }
  }

  JsonObject parseCsv(String csvContent) {
    var lines = csvContent.split("\n");
    var data = Map<String, dynamic>();
    var lessons = List<dynamic>();
    data["lessons"] = lessons;
    var lesson;
    var words;
    for (var line in lines.skip(1)) {
      var fields = line.split(';');
      var name = fields[0].trim();
      if (name != "") {
        lesson = Map<String, dynamic>();
        lesson["name"] = name;
        words = List<dynamic>();
        lesson["words"] = words;
        lessons.add(lesson);
      } else if (lesson != null) {
        if (fields.length >= 2 && fields[1] != "" && fields[2] != null) {
          Map<String, dynamic> word = extractWord(fields);
          words.add(word);
        }
      }
    }
    return JsonObject.fromDynamic(data);
  }

  Map<String, dynamic> extractWord(List<String> fields) {
    var word = Map<String, dynamic>();
    var keys = ["src", "dest", "mp3"];
    for (var k in keys) word[k] = "";
    var keyIdx = 0;
    bool quotedString = false;
    for (var i = 1; i < fields.length; i++) {
      if (keyIdx >= keys.length) break;
      var key = keys[keyIdx];
      var s = fields[i].trimRight();
      if (s.startsWith("\"")) {
        word[key] += s.substring(1);
        quotedString = true;
      } else if (s.endsWith("\"")) {
        if (quotedString)
          word[key] += ";" + s.substring(0, s.length - 1);
        else
          word[key] += s;
        quotedString = false;
        keyIdx++;
      } else {
        word[key] += s.trim();
        if (!quotedString) keyIdx++;
      }
    }
    return word;
  }
}
