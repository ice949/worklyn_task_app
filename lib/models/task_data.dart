class TaskData {
  final int id;
  final String title;
  final DateTime? dueDate;
  bool completed;

  TaskData({
    required this.id,
    required this.title,
    this.dueDate,
    this.completed = false,
  });
}


class TaskDataApi {
  final String id;
  final String title;
  final String note;
  final DateTime dueDate;
  bool completed;

  TaskDataApi({
    required this.id,
    required this.title,
    required this.note,
    required this.dueDate,
    this.completed = false,
  });
}