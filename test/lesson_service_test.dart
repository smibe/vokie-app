import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vokie/lesson_service.dart';

main() {
  test('parce csv test', () async {
    var content = """
Lektion\tFranzösisch\tDeutsch
Abschnitt 1\t\t
\ton\tman
\thomme (m)\t"Mensch\t Mann"
\tà raison de\tà, je, zu
\tgrand\tgroß
\tconnaître\tkennen
\t
Abschnitt 2\t\t
\têtre\tsein
\tpersonne\t"keiner, keine, keines\t niemand"
\toù\t"wo\t wohin"
\tdeux\tzwei
\tsix\tsechs
    """;

    TestWidgetsFlutterBinding.ensureInitialized();
    var lessonService = LessonService();
    var lessonsObject = lessonService.parseTsv(content);
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
