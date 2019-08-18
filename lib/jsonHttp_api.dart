import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:vokie/jsonApi.dart';
import 'package:vokie/json_object.dart';

class JsonHttpApi extends JsonApi {
  Future<String> readResponse(HttpClientResponse response) {
    var completer = new Completer<String>();
    var contents = new StringBuffer();
    response.transform(utf8.decoder).listen((String data) {
      contents.write(data);
    }, onDone: () => completer.complete(contents.toString()),
    onError: (e) => print("something went wrong"));
    return completer.future;
  }


  Future<JsonObject> get(String url) async {
    var jsonString = await getString(url);
    return JsonObject(jsonString);
  }

  Future<String> getString(String url) async {
    var http = HttpClient();
    var response = await http.getUrl(Uri.parse(url));
    var r = await response.close();
    var result = await readResponse(r);
    return result;
  }

  Future<JsonObject> getById(String id) async {
    return getFromDrive(id);
  }

  Future<String> getContentById(String id) async {
    return await getStringFromDrive(id);
  }

  Future<JsonObject> getFromDrive(String id) async {
    var url = "https://drive.google.com/uc?export=download&id=" + id;
    return await get(url);
  }

  Future<String> getStringFromDrive(String id) async {
    var url = "https://drive.google.com/uc?export=download&id=" + id;
    return await getString(url);
  }
}
