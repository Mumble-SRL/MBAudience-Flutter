import 'package:shared_preferences/shared_preferences.dart';

class MBAudienceSessionManager {
  /// The date of start of this session
  DateTime _startSessionDate;

  Future<void> increaseSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int session = prefs.getInt('com.mumble.mburger.audience.session') ?? 0;
    int newSession = session + 1;
    await prefs.setInt('com.mumble.mburger.audience.session', newSession);
    String key = _sessionDateKeyForSession(newSession);
    await prefs.setInt(key, DateTime.now().millisecondsSinceEpoch);
    await _clearOldSessionValues();
    await startSession();
  }

  String _sessionDateKeyForSession(int session) {
    String sessionString = session.toString();
    return "com.mumble.mburger.audience.sessionTime.session" + sessionString;
  }

  Future<int> get currentSession => _currentSession();

  Future<int> _currentSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('com.mumble.mburger.audience.session') ?? 0;
  }

  Future<void> _clearOldSessionValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int currentSession = await _currentSession();
    // Clear only the last 3 values, this should be enough because this function will be called at every start, ideally it will find only currentSession - 2
    List<int> sessionsToClear = [
      currentSession - 2,
      currentSession - 3,
      currentSession - 4,
    ];
    for (int i in sessionsToClear) {
      if (i >= 0) {
        await prefs.remove(_sessionDateKeyForSession(i));
      }
    }
  }

  Future<void> startSession() async {
    if (_startSessionDate != null) {
      await endSession();
    }
    _startSessionDate = DateTime.now();
  }

  Future<void> endSession() async {
    if (_startSessionDate != null) {
      int sessionTime = await _totalSessionTime();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
          'com.mumble.mburger.audience.sessionTime', sessionTime);
      _startSessionDate = null;
    }
  }

  Future<int> get totalSessionTime => _totalSessionTime();

  Future<int> _totalSessionTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int time = prefs.getInt('com.mumble.mburger.audience.sessionTime') ?? 0;
    if (_startSessionDate != null) {
      time += DateTime.now().difference(_startSessionDate).inSeconds;
    }
    return time;
  }

  Future<DateTime> startSessionDateForSession(int session) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = _sessionDateKeyForSession(session);
    int value = prefs.getInt(key);
    if (value != null && value != 0) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return null;
  }
}
