// public IP
String apiURL =
    "http://csi5112group5serviceloadbalancer-1583919089.us-east-1.elb.amazonaws.com/api";

// local IP
// String apiURL = "https://localhost:7173/api";

String convertToTitleCase(String text) {
  if (text.isEmpty) {
    return "";
  }

  if (text.length <= 1) {
    return text.toUpperCase();
  }

  // Split string into multiple words
  final List<String> words = text.split(' ');

  // Capitalize first letter of each words
  final capitalizedWords = words.map((word) {
    if (word.trim().isNotEmpty) {
      final String firstLetter = word.trim().substring(0, 1).toUpperCase();
      final String remainingLetters = word.trim().substring(1);

      return '$firstLetter$remainingLetters';
    }
    return '';
  });

  // Join/Merge all words back to one String
  return capitalizedWords.join(' ').replaceAll('"', '');
}

String displayDate(DateTime date) {
  String mm = date.month < 10 ? "0${date.month}" : "${date.month}";
  String dd = date.day < 10 ? "0${date.day}" : "${date.day}";
  return "${date.year}-$mm-$dd";
}

String displayDateTime(DateTime date) {
  String mon = date.month < 10 ? "0${date.month}" : "${date.month}";
  String dd = date.day < 10 ? "0${date.day}" : "${date.day}";
  String hh = date.hour < 10 ? "0${date.hour}" : "${date.hour}";
  String mm = date.minute < 10 ? "0${date.minute}" : "${date.minute}";
  String ss = date.second < 10 ? "0${date.second}" : "${date.second}";
  return "${date.year}-$mon-$dd $hh:$mm:$ss";
}
