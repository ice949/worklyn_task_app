import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarViewWidget extends StatelessWidget {
  final VoidCallback backToTaskDetails;
  final DateTime selData;
  final void Function(DateTime, DateTime) onDateSelected;

  const CalendarViewWidget({
    Key? key,
    required this.backToTaskDetails,
    required this.selData,
    required this.onDateSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              GestureDetector(
                onTap: backToTaskDetails,
                child: Row(
                  children: const [
                    Icon(Icons.arrow_back, color: Color(0xFF1397C1)),
                    SizedBox(width: 4),
                    Text(
                      'Edit Task',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1397C1),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 25),
              const Center(
                child: Text(
                  'Choose Date',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: Center(
            child: TableCalendar(
              headerStyle: const HeaderStyle(formatButtonVisible: false),
              selectedDayPredicate: (day) => isSameDay(day, selData),
              availableGestures: AvailableGestures.all,
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: selData,
              onDaySelected: onDateSelected,
            ),
          ),
        ),
      ],
    );
  }
}
