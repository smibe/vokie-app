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
    var lesson = await lessonService.getLessonFromData(lessonsObject);

    expect(lessons.length, 2);
    expect (lesson, isNotNull);

  });
}
