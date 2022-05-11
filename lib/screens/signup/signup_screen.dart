import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:taxi/constants/constants.dart';
import 'package:taxi/screens/home/home_screen.dart';
import 'package:taxi/screens/signup/controller/signup_controller.dart';

class SignupScreen extends GetView<SignupController> {
  static const routeName = "/signupScreen";
  const SignupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Padding(
                padding: EdgeInsets.only(left: 60, right: 60),
                child: Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          child: Image.asset(
                            Constants.logo,
                            height: 150,
                            width: 150,
                          )),
                      SizedBox(height: 30),
                      TextField(
                        onChanged: controller.onChangeAccount,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: '帳號',
                        ),
                      ),
                      SizedBox(height: 30),
                      TextField(
                        onChanged: controller.onChangePassword,
                        obscureText: true,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: '密碼',
                        ),
                      ),
                      Obx(() => controller.errorMsg == ""
                          ? SizedBox()
                          : Text(controller.errorMsg,
                              style: TextStyle(color: Colors.red))),
                      SizedBox(height: 20),
                      TextButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.yellow[600]),
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                            ))),
                        onPressed: controller.login,
                        child: Padding(
                            padding: EdgeInsets.only(right: 15, left: 15),
                            child: Text(
                              "登入",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 16),
                            )),
                      ),
                    ])))));
  }
}
