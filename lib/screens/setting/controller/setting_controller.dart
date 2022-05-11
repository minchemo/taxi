import 'dart:async';
import 'dart:io';

import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get_storage/get_storage.dart';
import 'package:taxi/screens/signup/signup_screen.dart';

class SettingController extends GetxController {
  final RxBool _pushNotify = false.obs;
  bool get pushNotify => _pushNotify.value;

  @override
  void onInit() {
    print("Setting");
    super.onInit();
  }

  void logOut() async {
    GetStorage storageBox = GetStorage();

    storageBox.remove("user");
    Timer.periodic(Duration(seconds: 1), (timer) async {
      exit(0);
    });

    // Get.offAllNamed(SignupScreen.routeName);

    // exit(0);
  }

  void onChangePushNotify(value) {
    _pushNotify.value = value;
  }
}
