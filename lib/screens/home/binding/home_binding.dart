import 'package:get/get.dart';
import 'package:taxi/controller/location_controller.dart';
import 'package:taxi/screens/home/controller/home_controller.dart';
import 'package:taxi/screens/homepage/controller/booking_controller.dart';
import 'package:taxi/screens/homepage/controller/homepage_controller.dart';
import 'package:taxi/controller/online_record_controller.dart';
import 'package:taxi/screens/messages/controller/messages_controller.dart';
import 'package:taxi/screens/performance/controller/dispatch_record_controller.dart';
import 'package:taxi/screens/performance/controller/performance_controller.dart';
import 'package:taxi/screens/setting/controller/setting_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<HomeController>(HomeController());
    Get.put<LocationController>(LocationController());
    Get.lazyPut<BookingController>(() => BookingController());
    Get.lazyPut<OnlineRecordController>(() => OnlineRecordController());
    // Get.lazyPut<HomepageController>((() => HomepageController()));
    Get.lazyPut<PerformanceController>((() => PerformanceController()));
    Get.lazyPut<DispatchRecordController>((() => DispatchRecordController()));
    Get.lazyPut<MessagesController>((() => MessagesController()));
    Get.lazyPut<SettingController>((() => SettingController()));
  }
}
