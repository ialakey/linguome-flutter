class FormatService {
  static String formatDateString(String inputDate) {
    DateTime dateTime = DateTime.parse(inputDate);
    String formattedDate = '${dateTime.day.toString().padLeft(2, '0')}/'
        '${dateTime.month.toString().padLeft(2, '0')}/'
        '${dateTime.year.toString().substring(2)} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
    return formattedDate;
  }
}
