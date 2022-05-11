import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taxi/constants/constants.dart';
import 'package:taxi/screens/homepage/controller/homepage_controller.dart';

class FinishOrderScreen extends GetView<HomepageController> {
  const FinishOrderScreen({Key? key}) : super(key: key);
  static String routeName = "/finishOrderScreen";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.yellow[600],
            title: Center(
                child: Text("付款完成", style: TextStyle(color: Colors.black)))),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(Constants.success,width: 200,),
            Text("完成", style: TextStyle(fontSize: 18)),
            TextButton(
              onPressed: controller.lastFinish,
              child: Text("確定", style: TextStyle(fontSize: 20)),
            )
          ],
        )));
  }
}
