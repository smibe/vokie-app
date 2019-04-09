import 'dart:async';
import 'package:vokie/json_object.dart';

abstract class JsonApi {
   Future<JsonObject> get(String url);
   Future<JsonObject> getById(String id);
}
