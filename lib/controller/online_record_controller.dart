import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:taxi/methods/methods.dart';
import 'package:taxi/repositories/online_record_repository.dart';

class OnlineRecordController extends GetxController {
  int startOnlineTime = 0;
  int endOnlineTime = 0;
  final OnlineRecordRepository _onlineRecordRepository =
      OnlineRecordRepository();

  final GetStorage storageBox = GetStorage();

  void createOnlineRecord() {
    print("======== createOnlineRecord ==========");
    String id = storageBox.read("user")["id"];

    print(storageBox.read("startOnlinetime"));

    if (storageBox.read("startOnlinetime") != null) {
      startOnlineTime = int.parse(storageBox.read("startOnlinetime"));
    }

    _onlineRecordRepository.createOnlineRecord(
        id, startOnlineTime, endOnlineTime);

    storageBox.remove("startOnlinetime");
  }

  Future<String> getOnlineTimeInOneWeek() async {
    print("========= getOnlineTimeInOneWeek =========");
    String id = storageBox.read("user")["id"];
    Map<String, dynamic> time = Methods().getThisWeek();

    List res = await _onlineRecordRepository.getAllOnlineRecordByTime(
        id, time["startDayOfWeekTimestamp"], time["lastDayOfWeekTimestamp"]);

    print(res);

    int totalOnlineTimeOneWeek = 0;
    for (int i = 0; i < res.length; i++) {
      totalOnlineTimeOneWeek = totalOnlineTimeOneWeek +
          (res[i]["endTime"] - res[i]["startTime"]) as int;
    }

    print(totalOnlineTimeOneWeek);
    return sec2HourAndmins(Duration(seconds: totalOnlineTimeOneWeek));
  }

  Future<String> getOnlineTimeInOneDay() async {
    print("========= getOnlineTimeInOneDay =========");
    String id = storageBox.read("user")["id"];
    Map<String, dynamic> time = Methods().getThisDay();

    List res = await _onlineRecordRepository.getAllOnlineRecordByTime(
        id, time["startDayOfDayTimestamp"], time["lastDayOfDayTimestamp"]);

    print(res);

    int totalOnlineTimeOneDay = 0;
    if (res.isEmpty) return "暫無資料";

    for (int i = 0; i < res.length; i++) {
      totalOnlineTimeOneDay = totalOnlineTimeOneDay +
          (res[i]["endTime"] - res[i]["startTime"]) as int;
    }

    print(totalOnlineTimeOneDay);

    return sec2HourAndmins(Duration(seconds: totalOnlineTimeOneDay));
  }

  Future<String> getOnlineTimeInOneMonth() async {
    print("========= getOnlineTimeInOneMonth =========");
    String id = storageBox.read("user")["id"];
    Map<String, dynamic> time = Methods().getThisMonth();

    List res = await _onlineRecordRepository.getAllOnlineRecordByTime(
        id, time["startDayOfMonthTimestamp"], time["lastDayOfMonthTimestamp"]);

    print(res);

    int totalOnlineTimeOneMonth = 0;
    for (int i = 0; i < res.length; i++) {
      totalOnlineTimeOneMonth = totalOnlineTimeOneMonth +
          (res[i]["endTime"] - res[i]["startTime"]) as int;
    }

    print(totalOnlineTimeOneMonth);
    return sec2HourAndmins(Duration(seconds: totalOnlineTimeOneMonth));
  }

  String sec2HourAndmins(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    // String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}小時$twoDigitMinutes分鐘";
  }

  void setStartOnlineTime() {
    String onlineTimeStr = DateTime.now().millisecondsSinceEpoch.toString();

    startOnlineTime =
        int.parse(onlineTimeStr.substring(0, onlineTimeStr.length - 3));
    print(startOnlineTime);

    storageBox.write("startOnlinetime", startOnlineTime.toString());
    print(storageBox.read("startOnlinetime"));
    print("========== StartOnlineTime ============");
    print(startOnlineTime);
    print("==========                 ============");
  }

  Future<void> setEndOnlineTime() async {
    String onlineTimeStr = DateTime.now().millisecondsSinceEpoch.toString();

    endOnlineTime =
        int.parse(onlineTimeStr.substring(0, onlineTimeStr.length - 3));
    print("========== EndOnlineTime ============");
    print(endOnlineTime);
    print("==========                 ============");
  }
}
