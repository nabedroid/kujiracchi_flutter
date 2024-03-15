

class StringUtil {
  StringUtil._() {
    throw UnimplementedError();
  }

  /// h, m, s int to hh:mm:ss string
  static String hmsToString(int h, int m, int s) {
    return'${h.toString().padLeft(2, "0")}:'
        '${m.toString().padLeft(2, "0")}:'
        '${s.toString().padLeft(2, "0")}';
  }

  /// hh:mm:ss string to [h, m, s] int list
  static (int, int, int) hmsToInt(String hms) {
    List<int> l = hms.split(':').map((v) => int.parse(v)).toList();
    return (l[0], l[1], l[2]);
  }

  static String dateTimeToHHMMSS(DateTime d) {
    String hh = d.hour.toString().padLeft(2, '0');
    String mm = d.minute.toString().padLeft(2, '0');
    String ss = d.second.toString().padLeft(2, '0');
    return '$hh:$mm:$ss';
  }

  static bool isInt(String? str) {
    return str == null ? false : int.tryParse(str) != null;
  }
}