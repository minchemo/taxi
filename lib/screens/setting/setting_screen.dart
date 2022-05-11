import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taxi/screens/setting/controller/setting_controller.dart';
import 'package:taxi/screens/setting/profile_screen.dart';

class SettingScreen extends GetView<SettingController> {
  const SettingScreen({Key? key}) : super(key: key);

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
