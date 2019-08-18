import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vokie/lesson_service.dart';

main() {
  test('parce csv test', () async {
    var content = """
Lektion;Französisch;Deutsch
Abschnitt 1;;
;on;man
;homme (m);"Mensch; Mann"
;à raison de;à, je, zu
;grand;groß
;connaître;kennen
;
Abschnitt 2;;
;être;sein
;personne;"keiner, keine, keines; niemand"
;où;"wo; wohin"
;deux;zwei
;six;sechs
    """;
    var lessonService = LessonService();
    var lessonsObject = lessonService.parseCsv(content);
    var lessons = lessonsObject.getList("lessons");
    var lesson = await lessonService.getLessonFromData(lessonsObject, 0);

    expect(lessons.length, 2);
    expect (lesson, isNotNull);

    var words = lesson.data.lesson;
    expect(words[0].source, "on");
    expect(words[0].target, "man");
    expect(words[1].source, "homme (m)");
    expect(words[1].target, "Mensch; Mann");

  });

  test('download mp3', () async {
    await LessonService.downloadAndUnzip("1odtqPztmBW_Ada61BJrlb2WidqQrQmXq", "download");
    var file = File("download/1odtqPztmBW_Ada61BJrlb2WidqQrQmXq.zip");
    expect(file.existsSync(), isTrue); 
  });
}
