import 'dart:convert';

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

  Map<String, List> mySelectedEvents = {};

  final titleController = TextEditingController();
  final descpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDate = _focusedDay;

    // Load events from shared preferences
    loadPreviousEvents();
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
        mySelectedEvents = Map<String, List>.from(json.decode(eventsJson));
      });
    }
  }

  List _listOfDayEvents(DateTime dateTime) {
    if (mySelectedEvents[DateFormat('yyyy-MM-dd').format(dateTime)] != null) {
      return mySelectedEvents[DateFormat('yyyy-MM-dd').format(dateTime)]!;
    } else {
      return [];
    }
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
            TextField(
              controller: descpController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Description',
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
              if (titleController.text.isEmpty && descpController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Required title and description'),
                    duration: Duration(seconds: 2),
                  ),
                );
                return;
              } else {
                setState(() {
                  if (mySelectedEvents[DateFormat('yyyy-MM-dd').format(_selectedDate!)] !=
                      null) {
                    mySelectedEvents[DateFormat('yyyy-MM-dd').format(_selectedDate!)]?.add({
                      "eventTitle": titleController.text,
                      "eventDescp": descpController.text,
                    });
                  } else {
                    mySelectedEvents[DateFormat('yyyy-MM-dd').format(_selectedDate!)] = [
                      {
                        "eventTitle": titleController.text,
                        "eventDescp": descpController.text,
                      }
                    ];
                  }
                });
                print("New Event for backend developer ${json.encode(mySelectedEvents)}");
                titleController.clear();
                descpController.clear();

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
            ..._listOfDayEvents(_selectedDate!).map((myEvents) => ListTile(
              leading: const Icon(
                Icons.done,
                color: Colors.teal,
              ),
              title: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text('Event Title: ${myEvents['eventTitle']}'),
              ),
              subtitle: Text('Description: ${myEvents['eventDescp']}'),
            ))
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
