import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(ReminderApp());
}

class ReminderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Reminder App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ReminderHomePage(),
    );
  }
}

class ReminderHomePage extends StatefulWidget {
  @override
  _ReminderHomePageState createState() => _ReminderHomePageState();
}

class _ReminderHomePageState extends State<ReminderHomePage> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final _reminderController = TextEditingController();
  FlutterLocalNotificationsPlugin? _flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  // Initialize the local notification plugin
  void _initializeNotifications() {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const androidInitialization = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings = InitializationSettings(android: androidInitialization);

    _flutterLocalNotificationsPlugin!.initialize(initializationSettings);
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2021),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
      });
  }

  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime)
      setState(() {
        _selectedTime = picked;
      });
  }

  // Format date and time for display
  String _formattedDate() {
    if (_selectedDate == null || _selectedTime == null) {
      return 'No reminder set';
    } else {
      final dateFormatted = DateFormat.yMMMMd().format(_selectedDate!);
      final timeFormatted = MaterialLocalizations.of(context).formatTimeOfDay(_selectedTime!);
      return '$dateFormatted at $timeFormatted';
    }
  }

  // Schedule a notification at the selected time and date
  void _scheduleReminder(DateTime reminderDateTime, String reminderText) async {
    final androidDetails = AndroidNotificationDetails(
      'reminder_channel_id',
      'Reminder Notifications',
      channelDescription: 'This channel is used for reminder notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin!.schedule(
      0,
      'Reminder',
      reminderText,
      reminderDateTime,
      notificationDetails,
    );
  }

  // Set the reminder and schedule a notification
  void _setReminder() {
    if (_reminderController.text.isNotEmpty && _selectedDate != null && _selectedTime != null) {
      // Combine the selected date and time into one DateTime object
      final reminderDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      _scheduleReminder(reminderDateTime, _reminderController.text);

      // Show a dialog that the reminder has been set
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text("Reminder Set!"),
            content: Text("Your reminder for '${_reminderController.text}' is set for ${_formattedDate()}."),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK")
              )
            ],
          )
      );
    } else {
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text("Error"),
            content: Text("Please fill out all fields."),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK")
              )
            ],
          )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reminder App', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _reminderController,
              decoration: InputDecoration(labelText: 'Reminder Description'),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_selectedDate == null ? 'Pick a Date' : 'Date: ${DateFormat.yMd().format(_selectedDate!)}', style: TextStyle(fontWeight: FontWeight.w700)),
                ElevatedButton(
                  onPressed: () => _pickDate(context),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.purple), // Violet button color
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.white),  // White text color
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,  // Square edges
                      ),
                    ),
                  ),
                  child: Text('Select Date'),
                ),

              ],
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_selectedTime == null ? 'Pick a Time' : 'Time: ${_selectedTime!.format(context)}', style: TextStyle(fontWeight: FontWeight.w700)),
                ElevatedButton(
                  onPressed: () => _pickTime(context),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.purple), // Violet button color
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.white),  // White text color
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,  // Square edges
                      ),
                    ),
                  ),
                  child: Text('Select Time'),
                ),
              ],
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: _setReminder,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.white), // Violet button color
                foregroundColor: MaterialStateProperty.all<Color>(Colors.purple),  // White text color
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,  // Square edges
                  ),
                ),
              ),
              child: Text('Set Reminder'),
            ),
            SizedBox(height: 20),
            Text(_formattedDate()),
          ],
        ),
      ),
    );
  }
}
