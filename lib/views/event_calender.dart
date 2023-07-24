import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    // TODO: implement initState
    super.initState();
    _selectedDate = _focusedDay;

    loadPreviousEvents();
  }

  loadPreviousEvents(){
    print("object");
    setState(() {
      mySelectedEvents = {
        "2023-07-13":[
          {"eventDescp": "11", "eventTitle": "111"}
        ],
        "2023-07-10":[
          {"eventDescp": "11", "eventTitle": "111"},
          {"eventDescp": "22", "eventTitle": "222"}
        ]
      };
    });
    print(mySelectedEvents);
  }
  List _listOfDayEvents(DateTime dateTime) {
    if (mySelectedEvents[DateFormat('yyyy-MM-dd').format(dateTime)] != null) {
      return mySelectedEvents[DateFormat('yyyy-MM-dd').format(dateTime)]!;
    } else {
      return [];
    }
  }

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
                    if (titleController.text.isEmpty &&
                        descpController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Required title and description'),
                        duration: Duration(seconds: 2),
                      ));
                      return;
                    } else {
                      print(titleController.text);
                      print(descpController.text);

                      setState(() {
                        if (mySelectedEvents[DateFormat('yyyy-MM-dd')
                            .format(_selectedDate!)] !=
                            null) {
                          mySelectedEvents[
                          DateFormat('yyyy-MM-dd').format(_selectedDate!)]
                              ?.add({
                            "eventTitle": titleController.text,
                            "eventDescp": descpController.text,
                          });
                        } else {
                          mySelectedEvents[
                          DateFormat('yyyy-MM-dd').format(_selectedDate!)] = [
                            {
                              "eventTitle": titleController.text,
                              "eventDescp": descpController.text,
                            }
                          ];
                        }
                      });
                      print(
                          "New Event for backend developer ${json.encode(mySelectedEvents)}");
                      titleController.clear();
                      descpController.clear();
                      Navigator.pop(context);
                      return;
                    }
                  },
                  child: const Text('Add Event'),
                )
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Event Calender'),
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
              eventLoader: _listOfDayEvents,holidayPredicate: (day) {
                print(day.weekday);
                var importantDays = [DateTime.utc(2023, 07, 02), DateTime.utc(2023, 07, 05)];
              return importantDays.contains(day);//day == DateTime.utc(2023, 07, 02) || day == DateTime.utc(2023, 07, 05);
              },
            ),
            ..._listOfDayEvents(_selectedDate!).map((myEvents) => ListTile(
                  leading: const Icon(
                    Icons.done,
                    color: Colors.teal,
                  ),
                  title: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text('Event Title: ${myEvents['e ventTitle']}'),
                  ),
                  subtitle: Text('Description: ${myEvents['eventDescp']}'),
                ))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddEventDialog(),
          label: const Text('Add Event')),
    );
  }
}
