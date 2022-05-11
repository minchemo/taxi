import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OnlineRecordRepository {
  var dio = Dio();

  void createOnlineRecord(String id, int startTime, int endTime) async {
    String? apiUrl =
        dotenv.env['APP_SERVER_URL'].toString() + '/createOnlineRecord';
    var json = {"driverId": id, "startTime": startTime, "endTime": endTime};

    print(json);
    final res = await dio.post(apiUrl, data: json).catchError((error) {
      print(error);
    });

    print(res.data);
  }

  Future<List> getAllOnlineRecordByTime(String id, int startTime, int endTime) async {
    String? apiUrl =
        dotenv.env['APP_SERVER_URL'].toString() + '/getAllOnlineRecordByTime';
    var json = {"driverId": id, "startTime": startTime, "endTime": endTime};

    print(json);
    final res = await dio.post(apiUrl, data: json).catchError((error) {
      print(error);
    });

    print(res.data["data"]);

    return res.data["data"];
  }
}
