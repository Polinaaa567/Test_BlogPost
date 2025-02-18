import 'package:blog_post/StateManager/notification_model.dart';
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
          IconButton(onPressed: () {
            Navigator.of(context).pop();
          }, icon: Icon(Icons.close),),
          Row(
            children: [
              Text("Уведомления о новых постах"),
              Switch(
                  value: notificationModelRead.isNotificateNewPost,
                  onChanged: (value) =>
                      notificationModelWatch.changeNotificateNewPost()),
            ],
          ),
          Row(
            children: [
              Text("Уведомления о новых комментариях в ваших постах"),
              Switch(
                  value: notificationModelRead.isNotificateNewComment,
                  onChanged: (value) =>
                      notificationModelWatch.changeNotificateNewComment()),
            ],
          ),
          Row(
            children: [
              Text("Уведомления о новых лайках на ваши посты"),
              Switch(
                  value: notificationModelRead.isNotificateLike,
                  onChanged: (value) =>
                      notificationModelWatch.changeNotificateLike()),
            ],
          )
        ],
      ),
    );
  }
}
