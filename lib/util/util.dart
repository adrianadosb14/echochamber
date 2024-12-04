import 'package:flutter/material.dart';

class Util {
  static String? dateTimeToString(DateTime date){
       return "${date.day.toString().padLeft(2,'0')}/${date.month.toString().padLeft(2,'0')}/${date.year.toString()} ${date.hour.toString().padLeft(2,'0')}:${date.minute.toString().padLeft(2,'0')}";
  }

  static Future<DateTime> showDateTimePicker({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    initialDate ??= DateTime.now();
    firstDate ??= initialDate.subtract(const Duration(days: 365 * 100));
    lastDate ??= firstDate.add(const Duration(days: 365 * 200));

    final DateTime selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    )??DateTime.now();

    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );

    return selectedTime == null
        ? selectedDate
        : DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );
  }
}

extension ColorUtils on Color {
  Color textColorFromBg() {
    return computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }
}