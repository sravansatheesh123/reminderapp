import 'package:flutter/material.dart';
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


  String _formattedDate() {
    if (_selectedDate == null || _selectedTime == null) {
      return 'No reminder set';
    } else {
      final dateFormatted = DateFormat.yMMMMd().format(_selectedDate!);
      final timeFormatted = _selectedTime!.format(context);
      return '$dateFormatted at $timeFormatted';
    }
  }


  void _setReminder() {
    if (_reminderController.text.isNotEmpty && _selectedDate != null && _selectedTime != null) {
      // Here, you would save the reminder to a database or use a service to notify
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text("Reminder Set!"),
            content: Text(
                "Your reminder for '${_reminderController.text}' is set for ${_formattedDate()}."),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"))
            ],
          ));
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
                  child: Text("OK"))
            ],
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reminder App'),
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
                Text(_selectedDate == null ? 'Pick a Date' : 'Date: ${DateFormat.yMd().format(_selectedDate!)}'),
                ElevatedButton(
                  onPressed: () => _pickDate(context),
                  child: Text('Select Date'),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_selectedTime == null ? 'Pick a Time' : 'Time: ${_selectedTime!.format(context)}'),
                ElevatedButton(
                  onPressed: () => _pickTime(context),
                  child: Text('Select Time'),
                ),
              ],
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: _setReminder,
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