import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';

import 'package:intl/intl.dart';

class MessagesController extends GetxController
    with SingleGetTickerProviderMixin {
  late TabController messageTabbar;
  var dio = Dio();
  GetStorage storageBox = GetStorage();
  String _id = "";

  final RxList _companyMessage = [].obs;
  List get companyMessage => _companyMessage;

  final RxBool _loading = false.obs;
  bool get loading => _loading.value;

  @override
  void onInit() {
    messageTabbar = TabController(length: 2, vsync: this);
    getCompanyMessage();
    super.onInit();
  }

  void dispose() {
    super.dispose();
  }

  void getCompanyMessage() async {
    _loading.value = true;
    print("Get CompanyMessages");
    _id = storageBox.read("user")["id"];
    String? apiUrl =
        dotenv.env['APP_SERVER_URL'].toString() + '/getAllMessageByDriverId';
    print(apiUrl);

    final json = {"driverId": _id, "creationTime": 0};
    print(json);
    final res = await dio.post(apiUrl, data: json).catchError((error) {
      _loading.value = false;
      print(error);
    });
    print(res.data["data"]);
    for (int i = 0; i < res.data["data"].length; i++) {
      DateTime tmpTime;
      tmpTime = DateTime.fromMillisecondsSinceEpoch(
          res.data["data"][i]["creationTime"] * 1000);
      res.data["data"][i]["date"] =
          DateFormat('yyyy/MM/dd kk:mm').format(tmpTime);

      // print(res.data["data"][i]["date"]);
    }

    _companyMessage.value = res.data["data"];
    _loading.value = false;

    // print(companyMessage);
  }
}
