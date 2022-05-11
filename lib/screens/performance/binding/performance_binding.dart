import 'package:get/get.dart';
import 'package:taxi/screens/performance/controller/dispatch_record_controller.dart';
import 'package:taxi/screens/performance/controller/performance_controller.dart';

class PerformanceBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<PerformanceController>(PerformanceController());
    Get.lazyPut(() => DispatchRecordController());
  }
}
