import 'package:get/get.dart';
import 'package:taxi/screens/messages/controller/messages_controller.dart';

class MessagesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MessagesController>((() => MessagesController()));
  }
}
