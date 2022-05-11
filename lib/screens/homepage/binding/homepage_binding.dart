import 'package:get/get.dart';
import 'package:taxi/screens/homepage/controller/booking_controller.dart';
import 'package:taxi/screens/homepage/controller/homepage_controller.dart';
import 'package:taxi/controller/online_record_controller.dart';

class HomepageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BookingController>(() => BookingController());
    // Get.put<HomepageController>(HomepageController());
  }
}
