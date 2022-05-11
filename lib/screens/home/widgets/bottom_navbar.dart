import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:taxi/screens/home/controller/home_controller.dart';

class BottomNavbar extends GetView<HomeController> {
  const BottomNavbar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(()=>BottomNavigationBar(
      type:BottomNavigationBarType.fixed,

      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: '首頁',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.message),
          label: '訊息',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.work),
          label: '業績查詢',
          
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: '設定',
        ),
      ],
      currentIndex: controller.bottomNavbarCurrentIndex,
 
      selectedItemColor: Colors.yellow[800],
      unselectedItemColor: Colors.black,
      onTap: controller.changeBottomNavbar,
      showUnselectedLabels: true,
      showSelectedLabels: true,
    ));
  }
}
