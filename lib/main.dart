import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

enum AppTheme {
  Light,
  Dark,
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calendar App',
      theme: _buildThemeData(AppTheme.Light), // Set initial light theme
      darkTheme: _buildThemeData(AppTheme.Dark), // Set dark theme
      debugShowCheckedModeBanner: false, // Remove debug banner
      home: const CalendarGrid(),
    );
  }

  ThemeData _buildThemeData(AppTheme themeMode) {
    switch (themeMode) {
      case AppTheme.Light:
        return ThemeData(
          primarySwatch: Colors.red,
          brightness: Brightness.light,
        );
      case AppTheme.Dark:
        return ThemeData(
          primarySwatch: Colors.red,
          brightness: Brightness.dark,
        );
    }
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
  String userName = "Dianne Kristel Castillo"; // User name
  String userEmail = "dayan@gmail.com"; // User email
  AppTheme _currentTheme = AppTheme.Light; // Track current theme

  @override
  void initState() {
    super.initState();
    _initializeSelectedIndex();
  }

  void _initializeSelectedIndex() {
    indexOfFirstDayMonth = getIndexOfFirstDayInMonth(_selectedDate);
    _selectedIndex = indexOfFirstDayMonth + int.parse(DateFormat('d').format(_selectedDate)) - 1;
  }

  void _goToPreviousMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1, 1);
      _initializeSelectedIndex();
    });
  }

  void _goToNextMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
      _initializeSelectedIndex();
    });
  }

  void _addEvent() {
    if (_highlightedDate == null) return;

    TextEditingController titleController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
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
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              DropdownButtonFormField<String>(
                value: status,
                decoration: InputDecoration(labelText: 'Status'),
                items: ['Free', 'Busy'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
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
                    () => [],
                  ).add(
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
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              DropdownButtonFormField<String>(
                value: status,
                decoration: InputDecoration(labelText: 'Status'),
                items: ['Free', 'Busy'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
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
                  event.description = descriptionController.text;
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
      _selectedIndex = indexOfFirstDayMonth + date.day - 1;
      _updateSelectedDateEvents();
    });
  }

  void _updateSelectedDateEvents() {
    _selectedDateEvents = _events[_highlightedDate] ?? [];
  }

  void _editProfile() {
    TextEditingController nameController = TextEditingController(text: userName);
    TextEditingController emailController = TextEditingController(text: userEmail);

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
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
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
                  userName = nameController.text;
                  userEmail = emailController.text;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _openSettings() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.palette),
                title: Text('Theme'),
                onTap: _showThemeDialog, // Open theme selection dialog
              ),
              ListTile(
                leading: Icon(Icons.notifications),
                title: Text('Notifications'),
                onTap: () {
                  // Handle notification settings
                },
              ),
            ],
          ),
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
  }

  void _openHelpSupport() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Help & Support'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Contact us at primescheduler@help.com'),
              Text('Visit our PrimeScheduler site for common questions.'),
            ],
          ),
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
  }

  void _openAbout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('About'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Prime Scheduler App'),
              Text('Version 1.0.0'),
              Text('Developed by Group 9'),
            ],
          ),
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
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Theme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Light Theme'),
                onTap: () {
                  _setTheme(AppTheme.Light);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text('Dark Theme'),
                onTap: () {
                  _setTheme(AppTheme.Dark);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _setTheme(AppTheme themeMode) {
    setState(() {
      _currentTheme = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.red[200],
        shadowColor: Colors.transparent,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.black),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            onPressed: _goToPreviousMonth,
          ),
          IconButton(
            icon: const Icon(
              Icons.arrow_forward,
              color: Colors.black,
            ),
            onPressed: _goToNextMonth,
          ),
        ],
        title: Text(
          DateFormat.yMMMM().format(_selectedDate),
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 50,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
              ),
              itemCount: daysOfWeek.length,
              itemBuilder: (BuildContext context, int index) {
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
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 0.1,
                  blurRadius: 7,
                  offset: const Offset(0, 7.75),
                ),
              ],
            ),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1.0, // Adjust the aspect ratio to control the size
              ),
              itemCount: listOfDatesInMonth(_selectedDate).length + indexOfFirstDayMonth,
              itemBuilder: (BuildContext context, int index) {
                DateTime currentDate = DateTime(
                  _selectedDate.year,
                  _selectedDate.month,
                  index + 1 - indexOfFirstDayMonth,
                );
                List<Event>? events = _events[currentDate];

                return Padding(
                  padding: const EdgeInsets.all(4.0), // Adjust padding to control spacing
                  child: GestureDetector(
                    onTap: () {
                      if (index >= indexOfFirstDayMonth) {
                        _onDateTap(currentDate);
                      }
                    },
                    child: Stack(
                      children: [
                        Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: currentDate == _highlightedDate
                                ? const Color(0xFFFD00F0F)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              index < indexOfFirstDayMonth
                                  ? const Text("")
                                  : Text(
                                      '${index + 1 - indexOfFirstDayMonth}',
                                      style: TextStyle(
                                        color: currentDate == _highlightedDate
                                            ? Colors.white
                                            : index % 7 == 6
                                                ? Colors.redAccent
                                                : Colors.black,
                                        fontSize: 15,
                                      ),
                                    ),
                              if (events != null && events.isNotEmpty)
                                ...events.take(1).map((event) {
                                  return Text(
                                    event.title,
                                    style: TextStyle(
                                      color: currentDate == _highlightedDate
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 10,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  );
                                }).toList(),
                              if (events != null && events.length > 1)
                                Text(
                                  '+${events.length - 1} more',
                                  style: TextStyle(
                                    color: currentDate == _highlightedDate
                                        ? Colors.white
                                        : Colors.black,
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
          Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              onPressed: _addEvent,
              tooltip: 'Add Event',
              child: Icon(Icons.add),
              backgroundColor: Colors.red[200],
            ),
          ),
          Expanded(
            child: _highlightedDate != null && _selectedDateEvents.isNotEmpty
                ? ListView.builder(
                    itemCount: _selectedDateEvents.length,
                    itemBuilder: (context, index) {
                      Event event = _selectedDateEvents[index];
                      return ListTile(
                        title: Text(event.title),
                        subtitle: Text(event.description),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                _editEvent(event); // Call _editEvent here
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  _events[_highlightedDate]?.remove(event);
                                  _selectedDateEvents.remove(event);
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
                      _highlightedDate == null
                          ? 'Select a date to view events'
                          : 'No events for this date',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.red[200],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 40, color: Colors.black),
                  ),
                  SizedBox(height: 10),
                  Text(
                    userName,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    userEmail,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),
                ],
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
              onTap: _openSettings,
            ),
            ListTile(
              leading: Icon(Icons.help),
              title: Text('Help & Support'),
              onTap: _openHelpSupport,
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('About'),
              onTap: _openAbout,
            ),
            ListTile(
              leading: Icon(Icons.arrow_back),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
            },
            ),
          ],
        ),
      ),
    );
  }

  List<String> daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  List<DateTime> listOfDatesInMonth(DateTime selectedDate) {
    DateTime firstDayOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    DateTime lastDayOfMonth =
        DateTime(selectedDate.year, selectedDate.month + 1, 0);
    int daysInMonth = lastDayOfMonth.day;

    List<DateTime> dates = [];
    for (int i = 0; i < daysInMonth; i++) {
      dates.add(firstDayOfMonth.add(Duration(days: i)));
    }

    return dates;
  }

  int getIndexOfFirstDayInMonth(DateTime selectedDate) {
    return DateTime(selectedDate.year, selectedDate.month, 1).weekday - 1;
  }
}
