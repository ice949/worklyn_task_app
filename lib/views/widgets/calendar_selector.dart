import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarSelector extends StatelessWidget {
  final DateTime selectedDate;
  final void Function(DateTime day, DateTime focusedDay) onDaySelected;
  final VoidCallback onBack;

  const CalendarSelector({
    Key? key,
    required this.selectedDate,
    required this.onDaySelected,
    required this.onBack,
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
        SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              GestureDetector(
                onTap: onBack,
                child: Row(
                  children: [
                    Icon(Icons.arrow_back, color: Color(0xFF1397C1)),
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
              SizedBox(width: 25),
              Center(
                child: Text(
                  'Choose Date',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 24),
        Expanded(
          child: Center(
            child: TableCalendar(
              headerStyle: HeaderStyle(formatButtonVisible: false),
              selectedDayPredicate: (day) => isSameDay(day, selectedDate),
              availableGestures: AvailableGestures.all,
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: selectedDate,
              onDaySelected: onDaySelected,
            ),
          ),
        ),
      ],
    );
  }
}
