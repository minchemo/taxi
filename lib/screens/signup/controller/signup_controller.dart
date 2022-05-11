import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get_storage/get_storage.dart';
import 'package:taxi/repositories/driver_repository.dart';
import 'package:taxi/screens/home/home_screen.dart';

class SignupController extends GetxController {
  String _account = "";
  String _password = "";

  GetStorage storageBox = GetStorage();

  final RxString _errorMsg = "".obs;
  String get errorMsg => _errorMsg.value;

  final DriverRepository _driverRepository = DriverRepository();

  var dio = Dio();

  void onChangeAccount(value) => _account = value;
  void onChangePassword(value) => _password = value;

  @override
  void onInit() async {
    // storageBox.remove("executingOrder");
    // storageBox.erase();
    if (await checkLoggedOn()) {
      upDateData();
      Get.offNamed(HomeScreen.routeName);
    }

    super.onInit();
  }

  Future<bool> checkLoggedOn() async {
    final GetStorage storageBox = GetStorage();
    // storageBox.erase();
    final user = storageBox.read("user");
    print(user);

    if (user != null) return true;

    return false;
  }

  void upDateData() async {
    print("~~~~~~~~~~~~~~~~~~~~~ upDateData ~~~~~~~~~~~~~~~~~~~~~");
    String id = storageBox.read("user")["id"];
    Map<String, dynamic> res = await _driverRepository.getOneDriverById(id);
    res["id"] = id;
    storageBox.write("user", res);
  }

  void login() async {
    if (_account != "" && _password != "") {
      String? apiUrl = dotenv.env['APP_SERVER_URL'].toString() + '/driverLogin';

      final json = {
        "id": _account,
        "pw": _password,
      };
      print(json);
      final res = await dio.post(apiUrl, data: json).catchError((error) {
        print(error);
      });

      print(res);

      if (res.data["message"] == "Done") {
        res.data["data"]["id"] = _account;
        storageBox.write("user", res.data["data"]);
        upDateFCM();
        Get.offNamed(HomeScreen.routeName);
      } else {
        _errorMsg.value = "帳號或密碼錯誤";
      }
    }
  }

  void upDateFCM() async {
    final FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');
    String? token = await messaging.getToken();

    String? apiUrl =
        dotenv.env['APP_SERVER_URL'].toString() + '/updateDriverFCM';

    final json = {
      "id": _account,
      "fcm": token,
    };
    print(json);
    final res = await dio.post(apiUrl, data: json).catchError((error) {
      print(error);
    });

    print(res);
  }
}
