import 'package:flutter/material.dart';
import 'package:worklyn_task_app/models/task_data.dart';
import 'package:worklyn_task_app/views/widgets/calendar_view.dart';
import 'package:worklyn_task_app/views/widgets/task_details_view.dart';

void showEditTaskModal({
  required BuildContext context,
  required TaskData task,
  required DateTime selData,
  required void Function(DateTime, DateTime) onDateSelected,
}) {
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
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
              child: showCalendar
                  ? CalendarViewWidget(
                      backToTaskDetails: () => setModalState(() {
                        showCalendar = false;
                      }),
                      selData: selData,
                      onDateSelected: onDateSelected,
                    )
                  : TaskDetailsViewWidget(
                      task: task,
                      switchToCalendar: () => setModalState(() {
                        showCalendar = true;
                      }),
                      onDelete: () {},
                    ),
            ),
          );
        },
      );
    },
  );
}
