import 'package:flutter/services.dart';

class GuidFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;

    if (text.length > 8) {
      text = '${text.substring(0, 8)}-${text.substring(8)}';
    }
    if (text.length > 13) {
      text = '${text.substring(0, 13)}-${text.substring(13)}';
    }
    if (text.length > 18) {
      text = '${text.substring(0, 18)}-${text.substring(18)}';
    }
    if (text.length > 23) {
      text = '${text.substring(0, 23)}-${text.substring(23)}';
    }

    return TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length)
    );
  }
}