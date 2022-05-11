import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get_storage/get_storage.dart';
import 'package:taxi/repositories/driver_repository.dart';

class ProfileController extends GetxController {
  final _user = RxMap<String, dynamic>({}).obs;
  final GetStorage storageBox = GetStorage();
  Map<String, dynamic> get user => _user.value;
  String _oldPassword = "";
  String _newpassword = "";
  String _new2password = "";
  final RxBool _isOldValidate = false.obs;
  bool get isOldValidate => _isOldValidate.value;
  final RxBool _isNewPassword = false.obs;
  bool get isNewPassword => _isNewPassword.value;
  var oldPasswordController = TextEditingController();
  var newPasswordController = TextEditingController();
  var confirmPasswordController = TextEditingController();

  DriverRepository _driverRepository = DriverRepository();

  @override
  void onInit() {
    // TODO: implement onInit
    getUser();
    super.onInit();
  }

  void onChangeOldPassword(value) => _oldPassword = value;
  void onChangePassword(value) => _newpassword = value;
  void onChangeConfirmPassword(value) => _new2password = value;

  void submit() async {
    print("submit");
    if (_newpassword == "" || _new2password == "") return;

    _isOldValidate.value = false;
    _isNewPassword.value = false;
    final userData = storageBox.read("user");
    if (_oldPassword != userData["pw"]) {
      _isOldValidate.value = true;
      return;
    }
    if (_newpassword != _new2password) {
      _isNewPassword.value = true;
      return;
    }

    if (user["sex"] == "男")
      user["sex"] = true;
    else
      user["sex"] = false;

    EasyLoading.show(status: "加載中...");
    String res = await _driverRepository.updateDriver(user, _newpassword);
    if (res == "Update Successful") {
      user["pw"] = _newpassword;

      storageBox.write("user", user);
      oldPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();
      _oldPassword = "";
      _newpassword = "";
      _new2password = "";

      EasyLoading.showSuccess("更新成功");
    } else {
      EasyLoading.showError("更新失敗");
    }

    EasyLoading.dismiss();
  }

  void getUser() {
    final userData = storageBox.read("user");
    print(userData);
    if (userData != null) {
      Map<String, dynamic> mapData = json.decode(json.encode(userData));

      if (userData["sex"])
        mapData["sex"] = "男";
      else
        mapData["sex"] = "女";
      _user.value.value = mapData;
    }
  }
}
