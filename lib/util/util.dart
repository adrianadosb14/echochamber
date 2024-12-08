import 'dart:convert';
import 'dart:typed_data';
import 'dart:html' as html;
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

  static showLoginDialog(BuildContext context) async {
    await showDialog(context: context, builder: (context) {
      return const AlertDialog(
        title: Text('No has iniciado sesión'),
        content: IntrinsicHeight(child: Center(child: Text('No puedes realizar esta acción porque no has iniciado sesión todavía.')))
      );
    });
  }

  static saveFileWeb(Uint8List bytes, {String? filename}) {
    // prepare
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = 'filename??newFile';
    html.document.body?.children.add(anchor);

    anchor.click();

    html.document.body?.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }
}

extension ColorUtils on Color {
  Color textColorFromBg() {
    return computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }
}