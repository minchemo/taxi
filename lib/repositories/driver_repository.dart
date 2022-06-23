import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DriverRepository {
  var dio = Dio();

  Future<Map<String, dynamic>> getOneDriverById(id) async {
    print("getOneDriverById");
    String? apiUrl =
        dotenv.env['APP_SERVER_URL'].toString() + '/getOneDriverById';
    var json = {"id": id};
    print(json);
    print("getOneDriverById");

    final res = await dio.post(apiUrl, data: json).catchError((error) {
      print(error);
    });

    print(res.data["data"]);

    return res.data["data"];
  }

  Future<String> updateDriver(user, newPW) async {
    print("updateDriver");

    String? apiUrl = dotenv.env['APP_SERVER_URL'].toString() + '/updateDriver';
    var json = {
      "id": user["id"],
      "pw": newPW,
      "name": user["name"],
      "sex": user["sex"],
      "phone": user["phone"],
      "address": user["address"],
      "sharing": user["sharing"],
      "carColor": user["carColor"],
      "license": user["license"],
      "description": user["description"],
    };
    print(json);
    final res = await dio.post(apiUrl, data: json).catchError((error) {
      print(error);
    });

    return res.data["message"];
  }
}
