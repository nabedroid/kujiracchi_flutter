/// Utilクラス
class StringUtil {
  StringUtil._() {
    throw UnimplementedError();
  }

  /// int型のh, m, s をjson保存用のString型のhh:mm:ssに変換する
  static String hmsToString(int h, int m, int s) {
    return'${h.toString().padLeft(2, "0")}:'
        '${m.toString().padLeft(2, "0")}:'
        '${s.toString().padLeft(2, "0")}';
  }

  /// jsonに保存されたString型のhh:mm:ss形式をint型のh、m、sに分割する
  static (int, int, int) hmsToInt(String hms) {
    List<int> l = hms.split(':').map((v) => int.parse(v)).toList();
    return (l[0], l[1], l[2]);
  }

  /// DateTimeをhh:mm:ss形式に変換する
  /// ユーザーが設定した時刻区切り文字を使用していないことに留意
  static String dateTimeToHHMMSS(DateTime d) {
    String hh = d.hour.toString().padLeft(2, '0');
    String mm = d.minute.toString().padLeft(2, '0');
    String ss = d.second.toString().padLeft(2, '0');
    return '$hh:$mm:$ss';
  }

  /// 文字列がint型に変換可能か判定する
  static bool isInt(String? str) {
    return str == null ? false : int.tryParse(str) != null;
  }
}