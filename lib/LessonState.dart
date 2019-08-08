import 'package:vokie/vokable.dart';

class LessonState {
    List<Vokabel> lesson;
    int selected = 0;
    Vokabel get selectedVokabel => lesson[selected];
}