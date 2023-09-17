// Create a class to represent a notification
import 'package:flutter/material.dart';
class Notification {
  final String title;
  final String body;
  final Map<String, String> data;
  Notification({
    required this.title,
    required this.body,
    required this.data,
  });
}
// Create a widget to display a notification
class NotificationWidget extends StatelessWidget {
  final Notification notification;
  const NotificationWidget({
    Key? key,
    required this.notification,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(notification.title),
      subtitle: Text(notification.body),
    );
  }
}