import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

class EventCalenderScreen extends StatefulWidget {
  const EventCalenderScreen({Key? key}) : super(key: key);

  @override
  State<EventCalenderScreen> createState() => _EventCalenderScreenState();
}

class _EventCalenderScreenState extends State<EventCalenderScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  List<Event> mySelectedEvents = [];

  final titleController = TextEditingController();
  final noteController = TextEditingController();

  @override
  void initState() {
    AwesomeNotifications().isNotificationAllowed().then((isAllowed){
      if(!isAllowed){
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
    super.initState();
    _selectedDate = _focusedDay;

    // Load events from shared preferences
    loadPreviousEvents();
    runNotification;
  }

  runNotification(){
    print(DateTime.now());
    while(DateTime.now() == 1){
      print(DateTime.now());
    }
  }

  triggerNotification(){
    AwesomeNotifications().createNotification(content: NotificationContent(id: 10, channelKey: 'basic_channel',
    title: 'Simple Notification',
    body: 'hi'));
  }

  void saveEventsToSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('mySelectedEvents', json.encode(mySelectedEvents));
  }

  void loadPreviousEvents() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? eventsJson = prefs.getString('mySelectedEvents');
    if (eventsJson != null) {
      setState(() {
        mySelectedEvents = (json.decode(eventsJson) as List)
            .map((event) => Event.fromJson(event))
            .toList();
      });
    }
  }

  List<Event> _listOfDayEvents(DateTime dateTime) {
    return mySelectedEvents
        .where((event) => isSameDay(event.date, dateTime))
        .toList();
  }

  var holidays = [
    DateTime.utc(2023, 03, 02),
    DateTime.utc(2023, 04, 05),
    DateTime.utc(2023, 05, 08),
    DateTime.utc(2023, 06, 12),
    DateTime.utc(2023, 07, 12),
    DateTime.utc(2023, 08, 20),
    DateTime.utc(2023, 09, 25),
    DateTime.utc(2023, 10, 15),
  ];

  _showAddEventDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Add New Event',
          textAlign: TextAlign.center,
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Title',
              ),
            ),
            // Date Picker
            ElevatedButton(
              onPressed: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2022),
                  lastDate: DateTime(2024),
                );
                if (pickedDate != null) {
                  setState(() {
                    _selectedDate = pickedDate;
                  });
                }
              },
              child: Text(
                "Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}",
              ),
            ),
            // Start Time Picker
            ElevatedButton(
              onPressed: () async {
                TimeOfDay? startTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (startTime != null) {
                  setState(() {
                    _startTime = startTime;
                  });
                }
              },
              child: Text("Start Time: ${_startTime?.format(context) ?? ''}"),
            ),
            // End Time Picker
            ElevatedButton(
              onPressed: () async {
                TimeOfDay? endTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (endTime != null) {
                  setState(() {
                    _endTime = endTime;
                  });
                }
              },
              child: Text("End Time: ${_endTime?.format(context) ?? ''}"),
            ),
            TextField(
              controller: noteController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Note',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (titleController.text.isEmpty ||
                  _selectedDate == null ||
                  _startTime == null ||
                  _endTime == null ||
                  noteController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill in all fields.'),
                    duration: Duration(seconds: 2),
                  ),
                );
                return;
              } else {
                setState(() {
                  mySelectedEvents.add(Event(
                    title: titleController.text,
                    date: _selectedDate!,
                    startTime: _startTime!,
                    endTime: _endTime!,
                    note: noteController.text,
                  ));
                });
                titleController.clear();
                noteController.clear();
                // Save events to shared preferences
                saveEventsToSharedPreferences();

                Navigator.pop(context);
                return;
              }
            },
            child: const Text('Add Event'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Event Calendar'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TableCalendar(
              focusedDay: _focusedDay,
              firstDay: DateTime(2022),
              lastDay: DateTime(2024),
              calendarFormat: _calendarFormat,
              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(_selectedDate, selectedDay)) {
                  setState(() {
                    _selectedDate = selectedDay;
                    _focusedDay = focusedDay;
                  });
                }
              },
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDate, day);
              },
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              eventLoader: _listOfDayEvents,
              holidayPredicate: (day) {
                print(day.weekday);
                return holidays.contains(day);
              },
              weekendDays: const [DateTime.saturday, DateTime.sunday],
            ),
            ..._listOfDayEvents(_selectedDate!).map((event) => ListTile(
              leading: const Icon(
                Icons.done,
                color: Colors.teal,
              ),
              title: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text('Event Title: ${event.title}'),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Date: ${DateFormat('yyyy-MM-dd').format(event.date)}'),
                  Text('Start Time: ${event.startTime.format(context)}'),
                  Text('End Time: ${event.endTime.format(context)}'),
                  Text('Note: ${event.note}'),
                ],
              ),
            )),
            ElevatedButton(onPressed: (){ triggerNotification();print(DateTime.now());}, child: Text("Click"))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEventDialog(),
        label: const Text('Add Event'),
      ),
    );
  }
}

class Event {
  final String title;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String note;

  Event({
    required this.title,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.note,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      title: json['title'],
      date: DateTime.parse(json['date']),
      startTime: TimeOfDay.fromDateTime(DateTime.parse(json['startTime'])),
      endTime: TimeOfDay.fromDateTime(DateTime.parse(json['endTime'])),
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'date': date.toIso8601String(),
      'startTime': DateTime(DateTime.now().year, DateTime.now().month, date.day, startTime.hour, startTime.minute).toIso8601String(),
      'endTime': DateTime(DateTime.now().year, DateTime.now().month, date.day, endTime.hour, endTime.minute).toIso8601String(),
      'note': note,
    };
  }
}