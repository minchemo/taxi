import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taxi/screens/homepage/controller/homepage_controller.dart';
import 'package:signature/signature.dart';

class ElectronicSignatureScreen extends GetView<HomepageController> {
  const ElectronicSignatureScreen({Key? key}) : super(key: key);
  static String routeName = "/electronicSignatureScreen";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            actions: [
              TextButton(
                  onPressed: () {
                    if (!controller.isLoadingFinishOrder) {
                      controller.finishOrder(1);
                    }
                  },
                  child: Text(
                    "完成",
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ))
            ],
            iconTheme: IconThemeData(
              color: Colors.black,
            ),
            backgroundColor: Colors.yellow[600],
            title: Text("電子簽帳", style: TextStyle(color: Colors.black))),
        body: Signature(
          controller: controller.signatureController,
          backgroundColor: Colors.white,
        ));
  }
}
