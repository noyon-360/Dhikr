import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:dhikrs/Controller/AddedListChecker.dart';
import 'package:dhikrs/Controller/NameClass.dart';
import 'package:dhikrs/ListOfAllName/Dhikrs.dart';
import 'package:dhikrs/ListOfAllName/ListOfAllNameInBangla.dart';
import 'package:dhikrs/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationHelper {
  static Future<void> showNotification(BuildContext context, bool isEnglishSelected) async {
    final List<dynamic> allItems = AddedListChecker.getAllSelectedItems(context);
    final randomIndex = Random().nextInt(allItems.length);
    final item = allItems[randomIndex];

    String name;
    String meaning;

    if (item is AllahName) {
      name = isEnglishSelected
          ? item.name
          : allahNamesBangla.firstWhere((element) => element.name == item.name).name;
      meaning = isEnglishSelected
          ? item.meaning
          : allahNamesBangla.firstWhere((element) => element.name == item.name).meaning;
    } else if (item is Dhikr) {
      name = isEnglishSelected
          ? item.name
          : mostCommonDhikrBangla.firstWhere((element) => element.name == item.name).name;
      meaning = isEnglishSelected
          ? item.meaning
          : mostCommonDhikrBangla.firstWhere((element) => element.name == item.name).meaning;
    } else if (item is NameEntry) {
      name = item.name;
      meaning = item.meaning;
    } else {
      return;
    }

    if (Platform.isWindows) {
      final notification = LocalNotification(
        title: name,
        body: meaning,
      );
      notification.show();

      // Automatically remove the notification after a specified duration
      Timer(const Duration(seconds: 7), () {
        notification.close();
      });
    } else {
      final int notificationId = Random().nextInt(100000);
      AndroidNotificationChannel channel = AndroidNotificationChannel(
        notificationId.toString(),
        "High Importance Notifications",
        importance: Importance.max,
      );

      AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(channel.id, channel.name.toString(),
              channelDescription: 'your channel description',
              importance: Importance.high,
              priority: Priority.high,
              ticker: "ticker");

      NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidNotificationDetails);

      Future.delayed(Duration.zero, () {
        flutterLocalNotificationsPlugin.show(
          notificationId,
          name,
          meaning,
          platformChannelSpecifics,
        );
      });

      Future.delayed(const Duration(seconds: 7), () {
        flutterLocalNotificationsPlugin.cancel(notificationId);
      });
    }
  }

  static Future<void> performBackgroundTask() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isEnglishSelected = prefs.getBool('isEnglishSelected') ?? true;

    // In a background task, you don't have access to the context
    await showNotificationWithoutContext(isEnglishSelected);
  }

  static Future<void> showNotificationWithoutContext(bool isEnglishSelected) async {
    // Logic to select a random item and show notification in the background

    // Example without context:
    String name = isEnglishSelected ? "Default Name" : "ডিফল্ট নাম";
    String meaning = isEnglishSelected ? "Default Meaning" : "ডিফল্ট অর্থ";

    if (Platform.isWindows) {
      final notification = LocalNotification(
        title: name,
        body: meaning,
      );
      notification.show();

      Timer(const Duration(seconds: 7), () {
        notification.close();
      });
    } else {
      final int notificationId = Random().nextInt(100000);
      AndroidNotificationChannel channel = AndroidNotificationChannel(
        notificationId.toString(),
        "High Importance Notifications",
        importance: Importance.max,
      );

      AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(channel.id, channel.name.toString(),
              channelDescription: 'your channel description',
              importance: Importance.high,
              priority: Priority.high,
              ticker: "ticker");

      NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidNotificationDetails);

      Future.delayed(Duration.zero, () {
        flutterLocalNotificationsPlugin.show(
          notificationId,
          name,
          meaning,
          platformChannelSpecifics,
        );
      });

      Future.delayed(const Duration(seconds: 7), () {
        flutterLocalNotificationsPlugin.cancel(notificationId);
      });
    }
  }
}
