import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

extension BuildContextExtension on BuildContext {
  String translate(String key) {
    String value = FlutterI18n.translate(this, key);
    return value;
  }
}
