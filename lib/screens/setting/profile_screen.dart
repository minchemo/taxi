import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:taxi/screens/setting/controller/profile_controller.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({Key? key}) : super(key: key);
  static String routeName = "/profileScreen";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
          title: Text("個人資料", style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.yellow[600],
        ),
        body: Padding(
            padding: EdgeInsets.all(20),
            child: Obx(
              () => ListView(
                children: [
                  controller.user["icon"] != ""
                      ? Center(
                          child: Image.network(controller.user["icon"],
                              width: 200, height: 200))
                      : SizedBox(),
                  // Container(
                  //     margin: EdgeInsets.symmetric(horizontal: 120),
                  //     child: SizedBox(
                  //         child: ElevatedButton(
                  //             onPressed: () {},
                  //             style: ButtonStyle(
                  //                 backgroundColor: MaterialStateProperty.all(
                  //                     Colors.yellow[800])),
                  //             child: Text("選取照片",
                  //                 style: TextStyle(color: Colors.black))))),
                  SizedBox(height: 30),
                  Text(
                    "帳號:${controller.user["id"]} ",
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "姓名:${controller.user["name"]} ",
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "性別: ${controller.user["sex"]}",
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "車型顏色: ${controller.user["carColor"]}",
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "車牌: ${controller.user["license"]} ",
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "電話: ${controller.user["phone"]} ",
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 50),
                  TextField(
                    controller: controller.oldPasswordController,
                    onChanged: controller.onChangeOldPassword,
                    decoration: InputDecoration(
                      errorText: controller.isOldValidate ? '舊密碼錯誤' : null,
                      border: OutlineInputBorder(),
                      labelText: '舊密碼',
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: controller.newPasswordController,
                    onChanged: controller.onChangePassword,
                    decoration: InputDecoration(
                      errorText: controller.isNewPassword ? '密碼不相符' : null,
                      border: OutlineInputBorder(),
                      labelText: '新密碼',
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: controller.confirmPasswordController,
                    onChanged: controller.onChangeConfirmPassword,
                    decoration: InputDecoration(
                      errorText: controller.isNewPassword ? '密碼不相符' : null,
                      border: OutlineInputBorder(),
                      labelText: '確認新密碼',
                    ),
                  ),
                  SizedBox(height: 10),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //   children: [
                  //     ElevatedButton(
                  //         onPressed: () => Get.back(),
                  //         style: ButtonStyle(
                  //             fixedSize: (MaterialStateProperty.all(Size(100, 60))),
                  //             backgroundColor:
                  //                 MaterialStateProperty.all(Colors.yellow[800])),
                  //         child: Text("取消", style: TextStyle(color: Colors.black,fontSize: 18))),
                  ElevatedButton(
                      onPressed: () {
                        controller.submit();
                      },
                      style: ButtonStyle(
                          fixedSize: (MaterialStateProperty.all(Size(100, 60))),
                          backgroundColor:
                              MaterialStateProperty.all(Colors.yellow[800])),
                      child: Text("儲存",
                          style: TextStyle(color: Colors.black, fontSize: 18)))
                  //   ],
                  // )
                ],
              ),
            )));
  }
}
