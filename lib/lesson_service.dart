import 'dart:_http';
import 'dart:async';
import 'dart:convert';

import 'package:vokie/DiContainer.dart';
import 'package:vokie/jsonApi.dart';
import 'package:vokie/json_object.dart';
import 'package:vokie/lesson.dart';

class LessonService {
  JsonApi api = DiContainer.resolve<JsonApi>();

  Future<Lesson> getLesson() async {
    var data = await getData();
    var lessons = data.getList("lessons");
    var lessonData = lessons[0];

    var lesson = await api.get(lessonData["url"]);
    
    return Lesson(lesson);
  }

  Future<JsonObject> getData() async {
      return api.getById("1lA-vhaxchV-4wi6quSQdOJAYbyZ3n_5g");
  }
}

