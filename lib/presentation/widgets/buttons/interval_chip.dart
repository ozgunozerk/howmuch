import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:how_much/controllers/snapshots_controller.dart';
import 'package:how_much/controllers/helpers/date.dart';
import 'package:how_much/presentation/ui/colours.dart';
import 'package:how_much/presentation/ui/text_styles.dart';
import 'package:how_much/util/parsing.dart';

class IntervalChipWidget extends StatelessWidget {
  final Color color;

  IntervalChipWidget({super.key, required this.color});

  final DateController dateController = Get.find<DateController>();
  final SnapshotsController snapshotsController =
      Get.find<SnapshotsController>();

  late final String earliestDateString =
      snapshotsController.getFirstSnapshotDate();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        Obx(() => _buildChoiceChip(
              context,
              "Last day",
              DateInterval.lastDay,
              () => dateController.selectInterval(DateInterval.lastDay),
              color,
            )),
        Obx(() => _buildChoiceChip(
              context,
              "Last month",
              DateInterval.lastMonth,
              () => dateController.selectInterval(DateInterval.lastMonth),
              color,
            )),
        Obx(() => _buildChoiceChip(
              context,
              "Custom",
              DateInterval.customInterval,
              () => _showDatePickerDialog(context),
              color,
            )),
      ],
    );
  }

  ChoiceChip _buildChoiceChip(
    BuildContext context,
    String label,
    DateInterval interval,
    FutureOr<void> Function() onTap,
    Color color,
  ) {
    return ChoiceChip(
      showCheckmark: false,
      side: const BorderSide(color: Colors.transparent, width: 0),
      label: Text(label,
          style:
              chipTextStyle(dateController.selectedInterval.value == interval)),
      selected: dateController.selectedInterval.value == interval,
      selectedColor: color,
      disabledColor: howLightGrey,
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      onSelected: _isIntervalAvailable(interval) ? (_) => onTap() : null,
    );
  }

  bool _isIntervalAvailable(DateInterval interval) {
    final DateTime earliestDate = earliestDateString.isNotEmpty
        ? parseDateWithHour(earliestDateString)
        : DateTime.now(); // if there are no snapshots yet
    final differenceInDays = DateTime.now().difference(earliestDate).inDays;
    switch (interval) {
      case DateInterval.lastDay:
        // lastDay chip should always be available
        return true;
      case DateInterval.lastMonth:
        // lastMonth chip be enabled only if history is >= 30 days
        return differenceInDays >= 30;
      case DateInterval.customInterval:
        // custom chip should be enabled only if there is at least >=2 days of history
        return differenceInDays >= 2; // lastDay already covers `>= 1`
      default:
        return false;
    }
  }

  Future<void> _showDatePickerDialog(BuildContext context) async {
    await _selectAndUpdateDateRange(context); // updates date controller
    dateController.selectInterval(DateInterval
        .customInterval); // signals report controller to recalculate
  }

  Future<void> _selectAndUpdateDateRange(BuildContext context) async {
    final firstSnapshotDate =
        parseDateWithHour(snapshotsController.getFirstSnapshotDate());
    final lastSnapshotDate =
        parseDateWithHour(snapshotsController.getLastSnapshotDate());
    final initialStartDate = dateController.startDate.value;
    final initialEndDate = dateController.endDate.value;
    final pickedDateRange = await showDateRangePicker(
      context: context,
      firstDate: firstSnapshotDate,
      lastDate: lastSnapshotDate,
      initialDateRange:
          DateTimeRange(start: initialStartDate, end: initialEndDate),
    );
    if (pickedDateRange != null) {
      dateController.startDate.value = pickedDateRange.start;
      dateController.endDate.value = pickedDateRange.end;
    }
  }
}
