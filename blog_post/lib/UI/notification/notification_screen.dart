import 'package:blog_post/provider/notification/notification_model.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    NotificationModel notificationModelRead = context.read<NotificationModel>();
    NotificationModel notificationModelWatch =
        context.watch<NotificationModel>();

    return Scaffold(
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.close),
              ),
            ],
          ),

          Row(
            children: [
              const Text("Уведомления о новых постах"),
              Switch(
                  value: notificationModelRead.isNotificationNewPost,
                  onChanged: (value) =>
                      notificationModelWatch.changeNotificationNewPost()),
            ],
          ),
          Row(
            children: [
              const Text("Уведомления о новых комментариях"),
              Switch(
                  value: notificationModelRead.isNotificationNewComment,
                  onChanged: (value) =>
                      notificationModelWatch.changeNotificationNewComment()),
            ],
          ),
          Row(
            children: [
              const Text("Уведомления о новых лайках"),
              Switch(
                  value: notificationModelRead.isNotificationLike,
                  onChanged: (value) =>
                      notificationModelWatch.changeNotificationLike()),
            ],
          )
        ],
      ),
    );
  }
}
