import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:taxi/screens/homepage/controller/homepage_controller.dart';
import 'package:taxi/screens/setting/controller/setting_controller.dart';
import 'package:taxi/screens/setting/profile_screen.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';

class SettingScreen extends GetView<SettingController> {
  SettingScreen({Key? key}) : super(key: key);

  HomepageController homepageController = Get.find();

  GetStorage box = GetStorage();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        InkWell(
            onTap: () => Get.toNamed(ProfileScreen.routeName),
            child: Padding(
                padding:
                    EdgeInsets.only(top: 15, bottom: 10, left: 20, right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("個人資料",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500)),
                    Icon(Icons.chevron_right)
                  ],
                ))),
        Divider(color: Colors.black),
        Padding(
            padding: EdgeInsets.only(top: 5, bottom: 5, left: 20, right: 20),
            child: InkWell(
                onTap: AppSettings.openNotificationSettings,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("推播通知",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500)),
                    Icon(Icons.navigate_next)
                  ],
                ))),
        Divider(color: Colors.black),
        Padding(
            padding: EdgeInsets.only(top: 5, bottom: 5, left: 20, right: 20),
            child: InkWell(
                onTap: () async {
                  final ok = await showOkCancelAlertDialog(
                      context: context,
                      style: AdaptiveStyle.material,
                      title: '確認要重置接單狀態嗎？',
                      okLabel: '確認',
                      cancelLabel: '取消');

                  // ignore: unrelated_type_equality_checks
                  if (ok == OkCancelResult.ok &&
                      homepageController.status != 2) {
                    box.remove('executingOrder');

                    EasyLoading.showSuccess('重置完成，請取消派遣並重新派遣');
                  } else if (homepageController.status == 2) {
                    EasyLoading.showError('您有進行中訂單，無法重置');
                  }
                },
                child: Row(children: [
                  Text("重置接單狀態",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                ]))),
        Divider(color: Colors.black),
        Padding(
            padding: EdgeInsets.only(top: 5, bottom: 5, left: 20, right: 20),
            child: InkWell(
                onTap: controller.logOut,
                child: Row(children: [
                  Text("登出",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                ]))),
        Divider(color: Colors.black),
      ],
    );
  }
}
