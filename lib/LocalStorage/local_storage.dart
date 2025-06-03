import 'package:get_storage/get_storage.dart';

class LocalStorageService {
  static final _box = GetStorage();

  static const String _loggedUserKey = 'loggedUser';
  static const String _otherUserKey = 'otherUser';

  /// ✅ Save logged user
  static void saveLoggedUser(String userId) {
    _box.write(_loggedUserKey, userId);
  }

  /// ✅ Save other user
  static void saveOtherUser(String userId) {
    _box.write(_otherUserKey, userId);
  }

  /// ✅ Get logged user
  static String? getLoggedUser() {
    return _box.read<String>(_loggedUserKey);
  }

  /// ✅ Get other user
  static String? getOtherUser() {
    return _box.read<String>(_otherUserKey);
  }

  /// ❌ Clear both
  static void clearUsers() {
    _box.remove(_loggedUserKey);
    _box.remove(_otherUserKey);
  }
}
