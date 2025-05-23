import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:worklyn_task_app/views/widgets/calendar_selector.dart';

class TasksView extends StatefulWidget {
  const TasksView({Key? key}) : super(key: key);

  @override
  _TasksViewState createState() => _TasksViewState();
}

class _TasksViewState extends State<TasksView> {
  bool _isLoading = true;
  List<TaskData> _tasks = [];
  DateTime selData = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchTasksFromApi();
  }

  void _onDateSelected(DateTime day, DateTime focusedDay) {
    setState(() {
      selData = day;
    });
  }

  void _fetchTasksFromApi() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId') ?? ''; // fallback if not set

    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User ID not found in local storage.')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final url = Uri.parse('https://api.worklyn.com/konsul/actionPoints.list');

    try {
      final response = await http.get(
        url,
        headers: {
          'X-Environment': 'development',
          'Cookie': 'id=$userId',
          'content-type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        final List<dynamic> points = jsonBody['data']['points'];

        setState(() {
          _isLoading = false;
          _tasks =
              points.map((item) {
                return TaskData(
                  id: item['id'] ?? '',
                  title: item['name'] ?? 'No title',
                  note: item['note'] ?? '',
                  dueDate:
                      DateTime.tryParse(item['dueWhen'] ?? '') ??
                      DateTime.now(),
                  completed: item['status'] == 'DONE',
                );
              }).toList();
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load tasks: $e')));
    }
  }

  void _showTaskDetails(TaskData task) {
    bool showCalendar = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      barrierColor: Colors.black.withOpacity(0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return FractionallySizedBox(
              heightFactor: 0.9,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 0,
                  vertical: 20,
                ),
                child:
                    showCalendar
                        ? CalendarSelector(
                          selectedDate: selData,
                          onDaySelected: _onDateSelected,
                          onBack:
                              () => setModalState(() => showCalendar = false),
                        )
                        : _buildTaskDetailsView(
                          context,
                          task,
                          () => setModalState(() => showCalendar = true),
                        ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTaskDetailsView(
    BuildContext context,
    TaskData task,
    VoidCallback switchToCalendar,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    'Edit Task',
                    style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Task deleted')));
                  Navigator.pop(context);
                },
                child: Text(
                  'Delete',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: task.completed,
                    onChanged: (val) {
                      task.completed = val ?? false;
                    },
                    shape: CircleBorder(),
                  ),
                  Text(task.title),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                    color: Color(0xFFEAEDED),
                  ),
                  width: 140,
                  padding: EdgeInsets.symmetric(horizontal: 13, vertical: 6),
                  child: InkWell(
                    onTap: switchToCalendar,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 18,
                          color: Colors.green,
                        ),
                        SizedBox(width: 8),
                        Text("Today", style: TextStyle(color: Colors.green)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        Container(
          width: double.infinity,
          height: 1,
          color: Color.fromARGB(255, 210, 213, 213),
        ),
        Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Icon(Icons.add),
              SizedBox(width: 10),
              Text("Add subtask"),
            ],
          ),
        ),
        Spacer(),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            minimumSize: Size(double.infinity, 48),
          ),
          child: Text('Close'),
        ),
      ],
    );
  }


  String _formatDate(DateTime date) {
    return "${_getWeekday(date.weekday)}, ${date.day} ${_getMonth(date.month)}";
  }

  String _getWeekday(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  String _getMonth(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 15,
          children: [
            SizedBox(
              height: 40,
              child: const Text(
                "Tasks",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              child:
                  _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.all(12),
                          itemCount: _tasks.length,
                          itemBuilder: (_, index) {
                            final task = _tasks[index];
                            return InkWell(
                              onTap: () => _showTaskDetails(task),
                              child: Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      children: [
                                        Checkbox(
                                          value: task.completed,
                                          onChanged: (val) {
                                            setState(() {
                                              task.completed = val ?? false;
                                            });
                                          },
                                          shape: CircleBorder(),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                task.title,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  decoration:
                                                      task.completed
                                                          ? TextDecoration
                                                              .lineThrough
                                                          : null,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.calendar_today,
                                                    size: 14,
                                                    color: Colors.green,
                                                  ),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    _formatDate(task.dueDate),
                                                    style: TextStyle(
                                                      color: Colors.green,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

class TaskData {
  final String id;
  final String title;
  final String note;
  final DateTime dueDate;
  bool completed;

  TaskData({
    required this.id,
    required this.title,
    required this.note,
    required this.dueDate,
    this.completed = false,
  });
}
