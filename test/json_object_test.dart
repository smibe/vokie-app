import 'package:test/test.dart';
import 'package:vokie/json_object.dart';

void main() {
  var testJson = '''{
    "testString":"stringValue",
    "testBool": true,
    "testInt": 999,
    "testList": ["first", "second"]
    }''';

  test('getValue test', () {
    var obj = JsonObject(testJson);
    expect(obj.getString("testString"), "stringValue");
    expect(obj.getBool("testBool"), true);
    expect(obj.getInt("testInt"), 999);
  });

  test('getList test', () {
    var obj = JsonObject(testJson);
    var list = obj.getList("testList");
    expect("first", list[0]); 
    expect("second", list[1]); 
  });
}
