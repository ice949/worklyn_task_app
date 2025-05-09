extension DateFormatting on DateTime {
  String get weekdayShort {
    const days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    return days[this.weekday - 1];
  }
  String get monthShort {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return months[this.month - 1];
  }
  String get formatted {
    return '$weekdayShort, ${this.day} $monthShort';
  }
}
