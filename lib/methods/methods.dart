class Methods {
  Map<String, dynamic> getThisMonth() {
    String date = DateTime.now().toString();
    DateTime currentDate = DateTime.parse(date);

    DateTime startDayOfMonth = DateTime(currentDate.year, currentDate.month, 1);
    DateTime lastDayOfMonth =
        DateTime(currentDate.year, currentDate.month + 1, 0);

    int startDayOfMonthTimestamp = int.parse(
        startDayOfMonth.millisecondsSinceEpoch.toString().substring(
            0, startDayOfMonth.millisecondsSinceEpoch.toString().length - 3));
    int lastDayOfMonthTimestamp = int.parse(
        lastDayOfMonth.millisecondsSinceEpoch.toString().substring(
            0, lastDayOfMonth.millisecondsSinceEpoch.toString().length - 3));
    print("=== startDayOfMonth ===  $startDayOfMonth");
    print(startDayOfMonthTimestamp);
    print("=== lastDayOfMonth === $lastDayOfMonth");
    print(lastDayOfMonthTimestamp);

    Map<String, dynamic> res = {
      "startDayOfMonthTimestamp": startDayOfMonthTimestamp,
      "lastDayOfMonthTimestamp": lastDayOfMonthTimestamp
    };

    return res;
  }

  Map<String, dynamic> getThisWeek() {
    DateTime currentTime = DateTime.now();
    int weekDay = currentTime.weekday;
    DateTime firstDayOfWeek = currentTime.subtract(Duration(days: weekDay - 1));

    DateTime lastDayOfWeek = currentTime
        .add(Duration(days: DateTime.daysPerWeek - currentTime.weekday));

    firstDayOfWeek =
        DateTime(firstDayOfWeek.year, firstDayOfWeek.month, firstDayOfWeek.day);
    lastDayOfWeek =
        DateTime(lastDayOfWeek.year, lastDayOfWeek.month, lastDayOfWeek.day);

    int startDayOfWeekTimestamp = int.parse(
        firstDayOfWeek.millisecondsSinceEpoch.toString().substring(
            0, firstDayOfWeek.millisecondsSinceEpoch.toString().length - 3));
    int lastDayOfWeekTimestamp = int.parse(lastDayOfWeek.millisecondsSinceEpoch
        .toString()
        .substring(
            0, lastDayOfWeek.millisecondsSinceEpoch.toString().length - 3));
    print(firstDayOfWeek);
    print(lastDayOfWeek);

    Map<String, dynamic> res = {
      "startDayOfWeekTimestamp": startDayOfWeekTimestamp,
      "lastDayOfWeekTimestamp": lastDayOfWeekTimestamp
    };


    return res;
  }

  Map<String, dynamic> getThisDay() {
    DateTime currentTime = DateTime.now();
    currentTime =
        DateTime(currentTime.year, currentTime.month, currentTime.day);
    DateTime lastTime =
        DateTime(currentTime.year, currentTime.month, currentTime.day + 1);

    int startDayOfDayTimestamp = int.parse(currentTime.millisecondsSinceEpoch
        .toString()
        .substring(
            0, currentTime.millisecondsSinceEpoch.toString().length - 3));
    int lastDayOfDayTimestamp = int.parse(lastTime.millisecondsSinceEpoch
        .toString()
        .substring(0, lastTime.millisecondsSinceEpoch.toString().length - 3));

    Map<String, dynamic> res = {
      "startDayOfDayTimestamp": startDayOfDayTimestamp,
      "lastDayOfDayTimestamp": lastDayOfDayTimestamp
    };

    return res;
  }

  Map<String, dynamic> getBeforeMonth() {
    String date = DateTime.now().toString();
    DateTime currentDate = DateTime.parse(date);

    DateTime startDayOfMonth;
    DateTime lastDayOfMonth = DateTime(currentDate.year, currentDate.month, 0);

    if (currentDate.month - 1 != 0) {
      startDayOfMonth = DateTime(currentDate.year, currentDate.month - 1, 1);
    } else {
      startDayOfMonth = DateTime(currentDate.year - 1, 12, 1);
    }

    int startDayOfMonthTimestamp = int.parse(
        startDayOfMonth.millisecondsSinceEpoch.toString().substring(
            0, startDayOfMonth.millisecondsSinceEpoch.toString().length - 3));
    int lastDayOfMonthTimestamp = int.parse(
        lastDayOfMonth.millisecondsSinceEpoch.toString().substring(
            0, lastDayOfMonth.millisecondsSinceEpoch.toString().length - 3));
    print("=== startDayOfMonth ===  $startDayOfMonth");
    print(startDayOfMonthTimestamp);
    print("=== lastDayOfMonth === $lastDayOfMonth");
    print(lastDayOfMonthTimestamp);

    Map<String, dynamic> res = {
      "startDayOfMonthTimestamp": startDayOfMonthTimestamp,
      "lastDayOfMonthTimestamp": lastDayOfMonthTimestamp
    };

    return res;
  }
}
