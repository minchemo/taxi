import 'package:flutter/material.dart';

class StatisticalData extends StatelessWidget {
  const StatisticalData(
      {Key? key,
      required this.countTitle,
      this.curretDate,
      this.lastDate,
      this.data})
      : super(key: key);
  final String countTitle;
  final String? curretDate;
  final String? lastDate;
  final Map<String, dynamic>? data;
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            lastDate != null
                ? Align(
                    alignment: Alignment.center,
                    child: Text(
                      "統計日期 $curretDate ~ $lastDate",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ))
                : Align(
                    alignment: Alignment.center,
                    child: Text("統計日期 $curretDate ")),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "本$countTitle上線時間",
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  data!["onlineTime"] == "暫無資料" ? "0" : data!["onlineTime"],
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "本$countTitle里程數",
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  data!["totalDistance"] == "暫無資料"
                      ? "0"
                      : data!["totalDistance"].toStringAsFixed(1),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "本$countTitle業績數",
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  data!["performaceCount"].toString(),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ));
  }
}
