import 'dart:async';
import 'package:dhikrs/Controller/AddedListChecker.dart';
import 'package:dhikrs/Controller/NotificationHelper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:screen_state/screen_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:permission_handler/permission_handler.dart';


class TimerProvider with ChangeNotifier {
  Timer? _timer;
  bool _isTimerRunning = false;
  int _selectedNumber = 10;
  late SharedPreferences _prefs;
  double _angleOffset = 0.0;
  bool _isEnglishSelected = true; // Track selected Translation
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;


  // Screen _screen = Screen();
  // StreamSubscription<ScreenStateEvent>? _subscription;
  // ScreenStateEvent? _screenStateEvent;


  TimerProvider() {
    _initPreferences();
    // startListening();
  }

  bool get isTimerRunning => _isTimerRunning;
  int get selectedNumber => _selectedNumber;
  double get angleOffset => _angleOffset;
  bool get isEnglishSelected => _isEnglishSelected;

  Future<void> _initPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSelectedNumber();
    _loadTranslationPreference();
  }

  // void onData(ScreenStateEvent event) {
  //   _screenStateEvent = event;  // Store the screen state event
  //   print(event);
  // }
  //
  // void startListening() {
  //   try {
  //     _subscription = _screen.screenStateStream.listen(onData);
  //   } on ScreenStateException catch (exception) {
  //     print(exception);
  //   }
  // }


  void _loadSelectedNumber() {
    int? selectedNumber = _prefs.getInt('selectedNumber');
    if (selectedNumber != null) {
      _selectedNumber = selectedNumber;
      notifyListeners();
    }
  }

  void _loadTranslationPreference() {
    bool? isEnglishSelected = _prefs.getBool('isEnglishSelected');
    if (isEnglishSelected != null) {
      _isEnglishSelected = isEnglishSelected;
      notifyListeners();
    }
  }

  Future<void> _saveSelectedNumber(int number) async {
    await _prefs.setInt('selectedNumber', number);
  }

  Future<void> _saveTranslationPreference(bool isEnglishSelected) async {
    await _prefs.setBool('isEnglishSelected', isEnglishSelected);
  }

  Future<void> _saveTimerState(bool isRunning) async {
    await _prefs.setBool('isTimerRunning', isRunning);
  }

  void startTimer(BuildContext context) async {
    var notificationStatus = await Permission.notification.status;

    if (notificationStatus.isDenied) {
      notificationStatus = await Permission.notification.request();

      if (notificationStatus.isGranted) {
        _startTimer(context);
        // startBackgroundTask();
      }
    } else if (notificationStatus.isGranted) {
      _startTimer(context);
      // startBackgroundTask();
    } else {
      print('Notification permission status: $notificationStatus');
    }
  }

  void _startTimer(BuildContext context) {

    final List<dynamic> allItems =
        AddedListChecker.getAllSelectedItems(context);

    if (allItems.isNotEmpty) {
      if (_timer == null || !_timer!.isActive) {
        _timer = Timer.periodic(Duration(minutes: _selectedNumber), (timer) {
          NotificationHelper.showNotification(context, _isEnglishSelected);
        });
        _isTimerRunning = true;
        _saveTimerState(true);
        // startBackgroundTask();
        notifyListeners();
      } else {
        _showEmptyListMessage(context);
        notifyListeners();
      }
    }
  }

  void _showEmptyListMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('No items selected'),
          content: Text(
              'Please select at least one item before starting the timer.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

//   void startBackgroundTask() {
//   Workmanager().registerPeriodicTask(
//     "1",
//     "backgroundTask",
//     frequency: Duration(minutes: 15), // Minimum is 15 minutes
//     inputData: <String, dynamic>{},
//   );
// }

// void stopBackgroundTask() {
//   Workmanager().cancelAll();
// }

  void pauseTimer() {
    _timer?.cancel();
    _isTimerRunning = false;
    // removeFromStartup();
    // stopBackgroundTask();
    notifyListeners();
  }

  void toggleTimer(BuildContext context) {
    if (_isTimerRunning) {
      pauseTimer();
    } else {
      startTimer(context);
    }
  }

  void selectNumber(int number) {
    pauseTimer();
    _selectedNumber = number;
    _angleOffset = 0.0; // Reset angle offset
    _saveSelectedNumber(number);
    notifyListeners();
  }

  void updateAngle(double angle) {
    _angleOffset += angle;
    notifyListeners();
  }

  void setTranslation(bool isEnglish) {
    _isEnglishSelected = isEnglish;
    _saveTranslationPreference(isEnglish); // Save the Translation preference
    notifyListeners();
  }
}
