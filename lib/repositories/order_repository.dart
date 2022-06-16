import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OrderRepository {
  var dio = Dio();

  Future<List> getAllDoneOrderByTimeAndDriverId(id, startTime, endTime) async {
    String? apiUrl = dotenv.env['APP_SERVER_URL'].toString() +
        '/getAllDoneOrderByTimeAndDriverId';
    var json = {"driverId": id, "startTime": startTime, "endTime": endTime};
    print(json);
    final res = await dio.post(apiUrl, data: json).catchError((error) {
      print(error);
    });

    print(res.data["data"]);

    return res.data["data"];
  }

  Future<Response<dynamic>> updateOrder(String id, String startLat,
      String startLnt, String endLat, String endLnt) async {
    print("====== updateOrder =======");
    String? apiUrl = dotenv.env['APP_SERVER_URL'].toString() + '/updateOrder';

    final json = {
      "id": id,
      "startLat": startLat,
      "startLnt": startLnt,
      "endLat": endLat,
      "endLnt": endLnt
    };
    print(json);

    return dio.post(apiUrl, data: json);
  }

  Future<Response<dynamic>> patchOrder(
      String driverId, int payType, int price, String userPhone) async {
    print("====== patchOrder =======");
    String? apiUrl = dotenv.env['APP_SERVER_URL'].toString() + '/patchOrder';

    final json = {
      "driverId": driverId,
      "payType": payType,
      "price": price,
      "userPhone": userPhone
    };
    print(json);

    return dio.post(apiUrl, data: json);
  }

  Future<double> getGoogleMapDistance(start, destination) async {
    String? apiUrl =
        'https://maps.googleapis.com/maps/api/directions/json?origin=' +
            start.latitude.toString() +
            "," +
            start.longitude.toString() +
            '&destination=' +
            destination.latitude.toString() +
            ',' +
            destination.longitude.toString() +
            '&key=AIzaSyABBPDCxrOR-FesGUKaskcaw10PRizIB7o&language=zh-TW';
    print(apiUrl);
    final res = await dio.get(apiUrl).catchError((error) {
      print(error);
    });

    print(res.data["routes"][0]["legs"][0]["distance"]);

    return res.data["routes"][0]["legs"][0]["distance"]["value"] / 1000;
  }

  Future<List> getUnpayDriverOrder(id) async {
    print("getUnpayDriverOrder");
    String? apiUrl =
        dotenv.env['APP_SERVER_URL'].toString() + '/getUnpayDriverOrder';
    var json = {"driverId": id};
    print(json);
    final res = await dio.post(apiUrl, data: json).catchError((error) {
      print(error);
    });

    print(res.data);

    return res.data["data"];
  }

  Future<void> payUserOrder(String userPhone, String orderID) async {
    print("payUserOrder");
    String? apiUrl = dotenv.env['APP_SERVER_URL'].toString() + '/payUserOrder';
    var json = {"userPhone": userPhone, "orderId": orderID};
    print(json);
    final res = await dio.post(apiUrl, data: json).catchError((error) {
      print(error);
    });

    print(res);
  }
}
