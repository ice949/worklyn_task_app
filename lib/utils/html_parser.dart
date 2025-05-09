import 'package:html/parser.dart' as htmlParser;
import 'package:worklyn_task_app/models/task_data.dart';

class HtmlParserUtil {
  static List<TaskData> parseTasks(String htmlMessage) {
    final document = htmlParser.parse(htmlMessage);
    final olElement = document.querySelector('ol');
    if (olElement == null) return [];

    final taskElements = olElement.querySelectorAll('li');
    return taskElements
        .asMap()
        .entries
        .map((entry) => TaskData(id: entry.key + 1, title: entry.value.text.trim()))
        .where((task) => task.title != "Untitled Task")
        .toList();
  }
}
