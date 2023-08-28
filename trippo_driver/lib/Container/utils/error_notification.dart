import 'package:elegant_notification/elegant_notification.dart';
import 'package:flutter/material.dart';

class ErrorNotification {
  void showError(BuildContext context, String errorText) {
    return ElegantNotification.error(
        description: Text(
      errorText,
      maxLines: 3,
      style: const TextStyle(color: Colors.black),
    )).show(context);
  }

  void showSuccess(BuildContext context, String successText) {
    return ElegantNotification.success(
        description: Text(
      successText,
      maxLines: 3,
      style: const TextStyle(color: Colors.black),
    )).show(context);
  }
}
