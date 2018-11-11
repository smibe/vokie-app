import 'dart:_http';
import 'dart:async';
import 'dart:convert';

import 'package:vokie/json_object.dart';
import 'package:vokie/lesson.dart';

class LessonService {

  Future<String> readResponse(HttpClientResponse response) {
    var completer = new Completer<String>();
    var contents = new StringBuffer();
    response.transform(utf8.decoder).listen((String data) {
      contents.write(data);
    }, onDone: () => completer.complete(contents.toString()));
    return completer.future;
  }

   Future<JsonObject> get(String url) async {
     var http = HttpClient();
     var response = await http.getUrl(Uri.parse(url));
     var r = await response.close();
     var json = await readResponse(r);
     return JsonObject(json);
   }
   
   Future<JsonObject> getFromDrive(String id) async {
     var url = "https://drive.google.com/uc?export=download&id=" + id;
     return await get(url);
   }

   Future<JsonObject> getData() async {
      return getFromDrive("1lA-vhaxchV-4wi6quSQdOJAYbyZ3n_5g");
   }

  Future<Lesson> getLesson() async {
    var data = await getData();
    var lessons = data.getList("lessons");
    var lessonData = lessons[0];

    var lesson = await get(lessonData["url"]);
    
    return Lesson(lesson);
  }
}

