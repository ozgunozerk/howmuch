import 'package:get/get.dart';
import 'package:tuple/tuple.dart';

import 'package:how_much/util/parsing.dart';
import 'package:how_much/controllers/report_controller.dart';

enum DateInterval { lastDay, lastMonth, customInterval }

enum DateType { start, end }

class DateController extends GetxController {
  // default values are yesterday and today for dates
  final startDate = DateTime.now().subtract(const Duration(days: 1)).obs;
  final endDate = DateTime.now().obs;

  final Rx<DateInterval> selectedInterval = DateInterval.lastDay.obs;

  void selectInterval(DateInterval interval) {
    selectedInterval.value = interval;
    final currentDate = DateTime.now();
    switch (interval) {
      case DateInterval.lastDay:
        startDate.value = currentDate.subtract(const Duration(days: 1));
        endDate.value = currentDate;
        updateReportController();
        break;
      case DateInterval.lastMonth:
        startDate.value = currentDate.subtract(const Duration(days: 30));
        endDate.value = currentDate;
        updateReportController();
        break;
      case DateInterval.customInterval:
        // For custom interval, the interval chip widget will show a dialog to select dates
        // that dialog updates the `startDate` and `endDate` values via dateController
        // before calling `selectInterval()` function
        updateReportController();
        break;
      default:
        break;
    }
  }

  void updateReportController() {
    // we set the default days in ReportController using `getStartAndEndDatesUtc`,
    // on ReportController's `onInit` phase.
    // We can't use `updateReportController` for setting default dates
    // in ReportController's `onInit`, since it will cause StackOverflow:
    // 1. ReportController will find DateController
    // 2. DateController will try to find the ReportController, but can't
    //    since ReportController's onInit is not finalized yet
    //    so, it will try to create a new ReportController,
    //    and that will be a cycle (going back to step 1)

    Get.find<ReportController>().dateRange = getStartAndEndDatesUtc();
  }

  Tuple2<String, String> getStartAndEndDatesUtc() {
    // reportController will use these dates to query snapshots
    // and snapshots dates are in UTC,
    // but when user was selecting dates, we display the dates in local time,
    // so, we need to convert these dates back to UTC.

    /*
    1. hardcode server update times list:
      serverUpdateHours = [00, 06, 12, 18] -> UTC
    2. derive local update times from it:
      localUpdateHours = [13, 19, 01, 07] -> example: for +13 timezone
    3. order it:
      localUpdateTimesOrdered = [01, 07, 13, 19]
    4. for `start`, pick the smallest item in `localUpdateTimesOrdered`
      start date = yyyy-MM-dd -> merge this with yyyy-MM-dd-02 in this case
    5. for `end`, pick the biggest item in `localUpdateTimesOrdered`
      end date = yyyy-MM-dd -> merge this with yyyy-MM-dd-20
    6. convert these `start` and `end` dates now to UTC
    7. voila! we now have the UTC versions of the snapshot intervals
    */

    // Step 1: Hardcode server update times list in UTC
    List<int> serverUpdateHours = [00, 06, 12, 18];
    DateTime now = DateTime.now();
    int timezoneOffset = now.timeZoneOffset.inHours;

    // Step 2: Derive local update times and format them
    List<int> localUpdateHours = serverUpdateHours
        .map((utcTime) => (utcTime + timezoneOffset) % 24)
        .toList();

    // Step 3: Order localUpdateTimesFormatted
    localUpdateHours.sort();

    // Step 4: Pick the smallest item in localUpdateTimesFormatted for start
    DateTime startDateTime = DateTime(
      startDate.value.year,
      startDate.value.month,
      startDate.value.day,
      localUpdateHours.first,
    );

    // Step 5: Pick the biggest item in localUpdateTimesFormatted for end
    DateTime endDateTime = DateTime(
      endDate.value.year,
      endDate.value.month,
      endDate.value.day,
      localUpdateHours.last,
    );

    if (endDateTime.day == now.day) {
      // means, end date time is today
      // the current snapshot may not be finalized, and we want to include it
      endDateTime = endDateTime.add(const Duration(hours: 6));
    }

    String startDateUtc = formatDateWithHour(startDateTime.toUtc());
    String endDateUtc = formatDateWithHour(endDateTime.toUtc());

    return Tuple2(startDateUtc, endDateUtc);
  }
}
