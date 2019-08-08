import 'dart:async';
import 'package:vokie/json_object.dart';

abstract class JsonApi {
   Future<JsonObject> get(String url);
   Future<String> getString(String url);
   Future<JsonObject> getById(String id);
   Future<String> getContentById(String id);
}
