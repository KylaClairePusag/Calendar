import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calendar App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light, // Default theme is light
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark, // Dark theme
      ),
      debugShowCheckedModeBanner: false, // Remove debug banner
      home: const CalendarGrid(),
    );
  }
}

class Event {
  String title;
  String description;
  String status;

  Event(this.title, this.description, this.status);
}

class CalendarGrid extends StatefulWidget {
  const CalendarGrid({Key? key}) : super(key: key);

  @override
  _CalendarGridState createState() => _CalendarGridState();
}

class _CalendarGridState extends State<CalendarGrid> {
  DateTime _selectedDate = DateTime.now();
  DateTime? _highlightedDate;
  late int _selectedIndex;
  late int indexOfFirstDayMonth;
  Map<DateTime, List<Event>> _events = {};
  List<Event> _selectedDateEvents = [];
  bool _isDarkMode = false; // Track current theme mode

  String _userName = 'User Name';
  String _userEmail = 'user@example.com';

  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeSelectedIndex();
    _nameController.text = _userName;
    _emailController.text = _userEmail;
  }

  void _initializeSelectedIndex() {
    indexOfFirstDayMonth =
        getIndexOfFirstDayInMonth(_selectedDate);
    _selectedIndex = indexOfFirstDayMonth +
        int.parse(DateFormat('d').format(_selectedDate)) -
        1;
  }

  void _goToPreviousMonth() {
    setState(() {
      _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month - 1,
          1);
      _initializeSelectedIndex();
    });
  }

  void _goToNextMonth() {
    setState(() {
      _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month + 1,
          1);
      _initializeSelectedIndex();
    });
  }

  void _addEvent() {
    if (_highlightedDate == null) return;

    TextEditingController titleController =
        TextEditingController();
    TextEditingController descriptionController =
        TextEditingController();
    String status = 'Free';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Event'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                    labelText: 'Title'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                    labelText: 'Description'),
              ),
              DropdownButtonFormField<String>(
                value: status,
                decoration: InputDecoration(
                    labelText: 'Status'),
                items: ['Free', 'Busy']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Row(
                      children: [
                        Icon(
                          Icons.circle,
                          color: _getStatusColor(
                              value),
                        ),
                        SizedBox(width: 8),
                        Text(value),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    status = newValue!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                setState(() {
                  _events.putIfAbsent(
                      _highlightedDate!,
                      () => []).add(
                    Event(
                      titleController.text,
                      descriptionController.text,
                      status,
                    ),
                  );
                });
                Navigator.of(context).pop();
                _updateSelectedDateEvents();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDiscardDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Discard this event?'),
          actions: [
            TextButton(
              child: Text('Keep Editing'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Discard'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _editEvent(Event event) {
    TextEditingController titleController =
        TextEditingController(text: event.title);
    TextEditingController descriptionController =
        TextEditingController(text: event.description);
    String status = event.status;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Event'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                    labelText: 'Title'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                    labelText: 'Description'),
              ),
              DropdownButtonFormField<String>(
                value: status,
                decoration: InputDecoration(
                    labelText: 'Status'),
                items: ['Free', 'Busy']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Row(
                      children: [
                        Icon(
                          Icons.circle,
                          color: _getStatusColor(
                              value),
                        ),
                        SizedBox(width: 8),
                        Text(value),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    status = newValue!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                setState(() {
                  event.title = titleController.text;
                  event.description =
                      descriptionController.text;
                  event.status = status;
                });
                Navigator.of(context).pop();
                _updateSelectedDateEvents();
              },
            ),
          ],
        );
      },
    );
  }

  void _onDateTap(DateTime date) {
    setState(() {
      _highlightedDate = date;
      _selectedIndex =
          indexOfFirstDayMonth + date.day - 1;
      _updateSelectedDateEvents();
    });
  }

  void _updateSelectedDateEvents() {
    _selectedDateEvents =
        _events[_highlightedDate] ?? [];
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Busy':
        return Colors.red;
      case 'Free':
      default:
        return Colors.green;
    }
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  void _editProfile() {
    TextEditingController nameController =
        TextEditingController(text: _userName);
    TextEditingController emailController =
        TextEditingController(text: _userEmail);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration:
                    InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: emailController,
                decoration:
                    InputDecoration(labelText: 'Email'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                setState(() {
                  _userName = nameController.text;
                  _userEmail = emailController.text;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(_userName),
              accountEmail: Text(_userEmail),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Color.fromARGB(255, 230, 224, 224),
                child: Text(
                  _userName.isEmpty ? 'U' : _userName[0],
                  style: TextStyle(fontSize: 40.0),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Edit Profile'),
              onTap: _editProfile,
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Settings'),
                      content: Text('Settings dialog'),
                      actions: [
                        TextButton(
                          child: Text('Close'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.help),
              title: Text('Help & Support'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Help & Support'),
                      content: Text('Contact us at primescheduler@help.com. Visit our PrimeScheduler site for common questions.'),
                      actions: [
                        TextButton(
                          child: Text('Close'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('About'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('About'),
                      content: Text('Prime Scheduler App. Version 1.0.0 Developed by Group 9'),
                      actions: [
                        TextButton(
                          child: Text('Close'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: _goToPreviousMonth,
              ),
              Text(
                DateFormat.yMMMM()
                    .format(_selectedDate),
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward),
                onPressed: _goToNextMonth,
              ),
            ],
          ),
          SizedBox(
            height: 50,
            child: GridView.builder(
              physics:
                  const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
              ),
              itemCount: daysOfWeek.length,
              itemBuilder:
                  (BuildContext context, int index) {
                return Container(
                  alignment: Alignment.center,
                  child: Text(
                    daysOfWeek[index],
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFFFD00F0F),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  const BorderRadius.only(
                bottomLeft:
                    Radius.circular(20),
                bottomRight:
                    Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      Colors.black.withOpacity(0.3),
                  spreadRadius: 0.1,
                  blurRadius: 7,
                  offset: const Offset(0, 7.75),
                ),
              ],
            ),
            child: GridView.builder(
              physics:
                  const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio:
                    1.0, // Adjust the aspect ratio to control the size
              ),
              itemCount: 42,
              itemBuilder:
                  (BuildContext context, int index) {
                int day = index +
                    1 -
                    indexOfFirstDayMonth;
                DateTime currentDate = DateTime(
                    _selectedDate.year,
                    _selectedDate.month,
                    day);
                List<Event>? events =
                    (day > 0 &&
                            day <=
                                DateTime(
                                        _selectedDate
                                            .year,
                                        _selectedDate
                                                .month +
                                            1,
                                        0)
                                    .day)
                        ? _events[currentDate]
                        : null;

                return Padding(
                  padding:
                      const EdgeInsets.all(4.0), // Adjust padding to control spacing
                  child: GestureDetector(
                    onTap: () {
                      if (day >
                              0 &&
                          day <=
                              DateTime(
                                      _selectedDate
                                          .year,
                                      _selectedDate
                                              .month +
                                          1,
                                      0)
                                  .day) {
                        _onDateTap(currentDate);
                      }
                    },
                    child: Stack(
                      children: [
                        Container(
                          alignment: Alignment.center,
                          decoration:
                              BoxDecoration(
                            color:
                                currentDate ==
                                        _highlightedDate
                                    ? const Color(
                                        0xFFFD00F0F)
                                    : Colors.transparent,
                            borderRadius:
                                BorderRadius.circular(
                                    50),
                          ),
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .center,
                            children: [
                              if (day >
                                      0 &&
                                  day <=
                                      DateTime(
                                              _selectedDate
                                                  .year,
                                              _selectedDate
                                                      .month +
                                                  1,
                                              0)
                                          .day)
                                Text(
                                  '$day',
                                  style: TextStyle(
                                    color:
                                        currentDate ==
                                                _highlightedDate
                                            ? Colors
                                                .white
                                            : index %
                                                        7 ==
                                                    6
                                                ? Colors
                                                    .redAccent
                                                : Colors
                                                    .black,
                                    fontSize: 15,
                                  ),
                                ),
                              if (events !=
                                      null &&
                                  events.isNotEmpty)
                                ...events
                                    .take(1)
                                    .map((event) {
                                  return Text(
                                    event.title,
                                    style:
                                        TextStyle(
                                      color: _getStatusColor(
                                          event.status),
                                      fontSize: 10,
                                    ),
                                    overflow:
                                        TextOverflow
                                            .ellipsis,
                                  );
                                }).toList(),
                              if (events !=
                                      null &&
                                  events.length >
                                      1)
                                Text(
                                  '+${events.length - 1} more',
                                  style:
                                      TextStyle(
                                    color:
                                        currentDate ==
                                                _highlightedDate
                                            ? Colors
                                                .white
                                            : Colors
                                                .black,
                                    fontSize: 10,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 10), // Add space between calendar grid and button
          ElevatedButton(
            onPressed: _addEvent,
            child: const Text("Add Event"),
          ),
          Expanded(
            child: _highlightedDate !=
                        null &&
                    _selectedDateEvents
                        .isNotEmpty
                ? ListView.builder(
                    itemCount:
                        _selectedDateEvents.length,
                    itemBuilder:
                        (context, index) {
                      Event event =
                          _selectedDateEvents[
                              index];
                      return ListTile(
                        leading: Icon(
                          Icons.circle,
                          color: _getStatusColor(
                              event.status),
                        ),
                        title: Text(
                          event.title,
                          style: TextStyle(
                            color: _getStatusColor(
                                event.status),
                          ),
                        ),
                        subtitle:
                            Text(event.description),
                        trailing: Row(
                          mainAxisSize:
                              MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                _editEvent(
                                    event); // Call _editEvent here
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  _events[_highlightedDate]
                                      ?.remove(
                                          event);
                                  _selectedDateEvents
                                      .remove(
                                          event);
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  )
                : Center(
                    child: Text(
                      _highlightedDate ==
                              null
                          ? 'Select a date to view events'
                          : 'No events for this date',
                      style:
                          TextStyle(fontSize: 16),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

List<int> listOfDatesInMonth(
    DateTime currentDate) {
  var selectedMonthFirstDay =
      DateTime(currentDate.year,
          currentDate.month, 1);
  var nextMonthFirstDay = DateTime(
      selectedMonthFirstDay.year,
      selectedMonthFirstDay.month + 1,
      1);
  var totalDays = nextMonthFirstDay
      .difference(selectedMonthFirstDay)
      .inDays;
  return List<int>.generate(
      totalDays, (i) => i + 1);
}

int getIndexOfFirstDayInMonth(
    DateTime currentDate) {
  var selectedMonthFirstDay =
      DateTime(currentDate.year,
          currentDate.month, 1);
  return selectedMonthFirstDay
      .weekday % 7;
}

const List<String> daysOfWeek = [
  "Sun",
  "Mon",
  "Tue",
  "Wed",
  "Thu",
  "Fri",
  "Sat"
];
