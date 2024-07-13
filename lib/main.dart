import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

enum AppTheme {
  Light,
  Dark,
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AppTheme _currentTheme = AppTheme.Light;

  void _toggleTheme(AppTheme theme) {
    setState(() {
      _currentTheme = theme;
    });
  }

@override
Widget build(BuildContext context) {
  return MaterialApp(
    title: 'Calendar App',
    theme: _buildThemeData(AppTheme.Light), // Set initial light theme
    darkTheme: _buildThemeData(AppTheme.Dark), // Set dark theme
    themeMode: _currentTheme == AppTheme.Light ? ThemeMode.light : ThemeMode.dark,
    debugShowCheckedModeBanner: false, // Remove debug banner
    home: CalendarGrid(
      currentTheme: _currentTheme,
      toggleTheme: _toggleTheme,
    ),
  );
}

  ThemeData _buildThemeData(AppTheme themeMode) {
    switch (themeMode) {
      case AppTheme.Light:
        return ThemeData(
          primarySwatch: Colors.red,
          brightness: Brightness.light,
          scaffoldBackgroundColor: Colors.white,
          cardColor: Colors.white,
          textTheme: TextTheme(
            bodyLarge: TextStyle(color: Colors.black),
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.red[200],
            titleTextStyle: TextStyle(color: Colors.black, fontSize: 20),
            iconTheme: IconThemeData(color: Colors.black),
          ),
        );
      case AppTheme.Dark:
        return ThemeData(
          primarySwatch: Colors.red,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Colors.black,
          cardColor: Colors.grey[900],
          textTheme: TextTheme(
            bodyLarge: TextStyle(color: Colors.white),
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.red[700],
            titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
            iconTheme: IconThemeData(color: Colors.white),
          ),
        );
    }
  }
}

class Event {
  String title;
  String description;
  DateTime date;
  String status;

  Event(this.title, this.description, this.date, this.status);
}


class CalendarGrid extends StatefulWidget {
  final AppTheme currentTheme;
  final Function(AppTheme) toggleTheme;

  const CalendarGrid({
    Key? key,
    required this.currentTheme,
    required this.toggleTheme,
  }) : super(key: key);

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

  @override
  void initState() {
    super.initState();
    _initializeSelectedIndex();
  }

  Color _getUserAccountsDrawerHeaderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? Colors.red : Colors.red[200]!;
  }

  void _initializeSelectedIndex() {
    _highlightedDate = DateTime.now();
    indexOfFirstDayMonth = getIndexOfFirstDayInMonth(_selectedDate);
    _selectedIndex = indexOfFirstDayMonth + int.parse(DateFormat('d').format(_highlightedDate!)) - 1;
    _updateSelectedDateEvents();
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
  String status = 'Busy'; // Default status to 'Busy'

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
               maxLines: null, // Allow multiline input
             ),
             TextField(
               controller: descriptionController,
               decoration: InputDecoration(labelText: 'Description'),
               maxLines: null, // Allow multiline input
             ),

            Row(
              children: [
                Text('Status: '),
                Row(
                  children: [
                    Icon(
                      Icons.circle,
                      color: Colors.red,
                      size: 10,
                    ),
                    SizedBox(width: 5),
                    Text('Busy'),
                  ],
                ),
              ],
            ),
            // Add DatePicker for selecting event date
            TextButton(
              onPressed: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _highlightedDate ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(DateTime.now().year + 5),
                );
                if (pickedDate != null) {
                  setState(() {
                    _highlightedDate = pickedDate;
                  });
                }
              },
              child: Text(
                'Pick Date',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              _showDiscardDialog(context);
            },
          ),
          TextButton(
            child: Text('Add'),
            onPressed: () {
              if (titleController.text.isEmpty || descriptionController.text.isEmpty) {
                _showWarningDialog(context);
              } else {
                setState(() {
                  _events.putIfAbsent(
                    _highlightedDate!,
                    () => [],
                  ).add(
                    Event(
                      titleController.text,
                      descriptionController.text,
                      _highlightedDate!,
                      'Busy'                      
                    ),
                  );
                });
                Navigator.of(context).pop();
                _updateSelectedDateEvents();
              }
            },
          ),
        ],
      );
    },
  );
}

  // Method to retrieve all upcoming events
  List<Event> _getAllUpcomingEvents() {
    List<Event> upcomingEvents = [];

    _events.forEach((date, events) {
      upcomingEvents.addAll(events);
    });

    // Sort events by date if events have date field
    upcomingEvents.sort((a, b) => a.date.compareTo(b.date));

    return upcomingEvents;
  }

  // Method to navigate to Upcoming Events screen
void _navigateToUpcomingEvents(BuildContext context) {
  List<Event> upcomingEvents = _getAllUpcomingEvents();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Upcoming Events'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (upcomingEvents.isNotEmpty)
                ...upcomingEvents.map((event) {
                  return ListTile(
                    title: Text(event.title),
                    subtitle: Text(event.description),
                    trailing: Text(DateFormat.yMMMd().format(event.date)),
                  );
                }).toList(),
              if (upcomingEvents.isEmpty)
                Text('No Upcoming Events'),
            ],
          ),
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



  void _showDiscardDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Discard this event?'),
          content: Text('Are you sure you want to discard this event?'),
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
                Navigator.of(context).pop(); // Close discard confirmation dialog
                Navigator.of(context).pop(); // Close add event dialog
              },
            ),
          ],
        );
      },
    );
  }

  void _showWarningDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Incomplete Information'),
          content: Text('Event title and description are required.'),
          actions: [
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
              Row(
                children: [
                  Text('Status: '),
                  Row(
                    children: [
                      Icon(
                        Icons.circle,
                        color: Colors.red,
                        size: 10,
                      ),
                      SizedBox(width: 5),
                      Text('Busy'),
                    ],
                  ),
                ],
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

  void _showDeleteConfirmationDialog(Event event) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Event'),
          content: Text('Are you sure you want to delete this event?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                setState(() {
                  _events[_highlightedDate]?.remove(event);
                  _selectedDateEvents.remove(event);
                });
                Navigator.of(context).pop();
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
    _selectedDateEvents =
        _events[_highlightedDate] ?? [];
  }

  int getIndexOfFirstDayInMonth(DateTime date) {
    DateTime firstDay = DateTime(date.year, date.month, 1);
    return firstDay.weekday % 7;
  }

List<Widget> _buildCalendar() {
  final List<Widget> cells = [];
  final List<String> daysOfWeek = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  final int daysInMonth = DateUtils.getDaysInMonth(_selectedDate.year, _selectedDate.month);

  // Calculate previous month's days
  DateTime previousMonthDate = DateTime(_selectedDate.year, _selectedDate.month - 1, 1);
  int daysInPreviousMonth = DateUtils.getDaysInMonth(previousMonthDate.year, previousMonthDate.month);
  int indexOfFirstDayMonth = getIndexOfFirstDayInMonth(_selectedDate);
  int remainingDaysInPreviousMonth = indexOfFirstDayMonth;

  // Add headers for days of the week
  for (int i = 0; i < daysOfWeek.length; i++) {
    cells.add(
      Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(8.0),
        child: Text(
          daysOfWeek[i],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
      ),
    );
  }

  // Add empty cells for preceding days of the current month
  for (int i = 0; i < indexOfFirstDayMonth; i++) {
    cells.add(
      Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(8.0),
        child: Text(
          '${daysInPreviousMonth - remainingDaysInPreviousMonth + i + 1}',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: Colors.grey.withOpacity(0.5),
          ),
        ),
      ),
    );
  }

  // Add cells for each day of the current month
  for (int day = 1; day <= daysInMonth; day++) {
    final date = DateTime(_selectedDate.year, _selectedDate.month, day);
    final bool isToday = date.year == DateTime.now().year &&
        date.month == DateTime.now().month &&
        date.day == DateTime.now().day;
    final bool isSelected = date == _highlightedDate;

    // Determine if the date has events
    bool hasEvents = _events.containsKey(date) && _events[date]!.isNotEmpty;

    cells.add(
      GestureDetector(
        onTap: () => _onDateTap(date),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.red[200] : Colors.transparent,
            border: Border.all(
              color: Colors.grey.withOpacity(0.5),
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (hasEvents) // Show red dot indicator if there are events
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              if (isToday)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    width: 10,
                    height: 10,
                  ),
                ),
              Text(
                day.toString(),
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: isToday ? Colors.red : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Calculate next month's days
  int remainingDaysInNextMonth = 7 - (cells.length % 7);
  for (int i = 0; i < remainingDaysInNextMonth; i++) {
    cells.add(
      Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(8.0),
        child: Text(
          '${i + 1}',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: Colors.grey.withOpacity(0.5),
          ),
        ),
      ),
    );
  }

  return cells;
}





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prime Scheduler App'),
        actions: [
          IconButton(
            icon: widget.currentTheme == AppTheme.Light
                ? Icon(Icons.wb_sunny) // Light mode icon
                : Icon(Icons.nightlight_round), // Dark mode icon
            onPressed: () {
              // Toggle theme on icon press
              widget.toggleTheme(widget.currentTheme == AppTheme.Light ? AppTheme.Dark : AppTheme.Light);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: _goToPreviousMonth,
                ),
                Text(
                  DateFormat.yMMMM().format(_selectedDate),
                  style: TextStyle(fontSize: 20.0),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: _goToNextMonth,
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8.0),
              child: GridView.count(
                crossAxisCount: 7,
                children: _buildCalendar(),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _addEvent,
            child: const Text('Add Event'),
          ),
          if (_highlightedDate != null)
            Container(
              height: 197,
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    'Events on ${DateFormat.yMMMd().format(_highlightedDate!)}:',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),
                  _selectedDateEvents.isNotEmpty
                      ? SizedBox(
                          height: 150, // Set a fixed height for the event list
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: _selectedDateEvents.length,
                            itemBuilder: (context, index) {
                              Event event = _selectedDateEvents[index];
                              return Card(
                                child: ListTile(
                                  title: Text(event.title),
                                  subtitle: Text(event.description),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit),
                                        onPressed: () => _editEvent(event),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () => _showDeleteConfirmationDialog(event),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      : const Text('No events'),
                ],
              ),
            ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
              UserAccountsDrawerHeader(
                 accountName: Text(userName),
                 accountEmail: Text(userEmail),
                 currentAccountPicture: CircleAvatar(
                 backgroundColor: Colors.white,
                 child: Text(
                  userName[0],
                  style: TextStyle(fontSize: 40.0),
                 ),
                 ),
                   decoration: BoxDecoration(
                   color: _getUserAccountsDrawerHeaderColor(context),
                 ),
               ),

            ListTile(
              leading: Icon(Icons.person),
              title: Text('Edit Profile'),
              onTap: () {
                _navigateToProfileScreen(context); // Navigate to edit profile screen
              },
            ),
                              ListTile(
              leading: Icon(Icons.event),
              title: Text('Upcoming Events'),
              onTap: () {
              _navigateToUpcomingEvents(context);
              }
                  ),
            ListTile(
              leading: Icon(Icons.help),
              title: Text('Help & Support'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Help & Support'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
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
              },
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('About'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('About'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
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
              },
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                // Optionally, you can navigate to the calendar view here
              },
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToProfileScreen(BuildContext context) {
    Navigator.pop(context); // Close the drawer
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
          userName: userName,
          userEmail: userEmail,
          onUpdateProfile: _updateProfile,
        ),
      ),
    );
  }

  void _updateProfile(String newUserName, String newUserEmail) {
    setState(() {
      userName = newUserName;
      userEmail = newUserEmail;
    });
  }
}

class ProfileScreen extends StatefulWidget {
  final String userName;
  final String userEmail;
  final Function(String, String) onUpdateProfile;

  const ProfileScreen({
    Key? key,
    required this.userName,
    required this.userEmail,
    required this.onUpdateProfile,
  }) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userName);
    _emailController = TextEditingController(text: widget.userEmail);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _updateProfile();
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _updateProfile() {
    String newName = _nameController.text;
    String newEmail = _emailController.text;
    widget.onUpdateProfile(newName, newEmail);
    Navigator.of(context).pop(); // Close the profile screen
  }
}

class DateUtils {
  static int getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }
}
