import 'package:get/get.dart';
import 'package:taxi/screens/setting/controller/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ProfileController>(ProfileController());
  }
}
