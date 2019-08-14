import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:vokie/lesson.dart';

main () {

  test('serialization test', () {
    var content = """
      {"name": "someName",
      "words":[
        {"src":"Baum", "dest":"tree", "c":1, "st": true},
        {"src":"Tisch", "dest":"table"}
        ]}
    """;

    var lesson = Lesson.parse(content);
    expect (lesson.data.name,  "someName");
    expect (lesson.data.lesson.length, 2);
    var first = lesson.data.lesson[0];
    expect (first.source, "Baum");
    expect (first.target, "tree");
    expect (first.correct, 1);
    expect (first.showTarget, true);

    var jsonString = json.encode(lesson);
    expect (jsonString, isNot(""));
  });
}