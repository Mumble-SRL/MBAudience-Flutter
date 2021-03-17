import 'package:shared_preferences/shared_preferences.dart';

/// Class that manages MBAudience sessions and session dates.
/// It uses the `shared_preferences` package to save informations.
class MBAudienceSessionManager {
  /// The date of start of this session
  DateTime? _startSessionDate;

  /// Increases a session for MBAudience.
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

  /// The key used to store the date of the session with index `session`.
  /// @param session The session index.
  /// @return The key to use to save in the shared preference.
  String _sessionDateKeyForSession(int session) {
    String sessionString = session.toString();
    return "com.mumble.mburger.audience.sessionTime.session" + sessionString;
  }

  /// Getter for the current session index.
  Future<int> get currentSession => _currentSession();

  /// A Future that completes with the current session index.
  Future<int> _currentSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('com.mumble.mburger.audience.session') ?? 0;
  }

  /// Clears old session values stored.
  Future<void> _clearOldSessionValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int currentSession = await _currentSession();
    //It clears only the last 3 values, this should be enough because this function will be called at every start.
    //Ideally it will find only currentSession - 2
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

  /// Starts a new session.
  Future<void> startSession() async {
    if (_startSessionDate != null) {
      await endSession();
    }
    _startSessionDate = DateTime.now();
  }

  /// Ends the current session.
  Future<void> endSession() async {
    if (_startSessionDate != null) {
      int sessionTime = await _totalSessionTime();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
        'com.mumble.mburger.audience.sessionTime',
        sessionTime,
      );
      _startSessionDate = null;
    }
  }

  /// Getter for the total session time, in seconds.
  Future<int> get totalSessionTime => _totalSessionTime();

  /// Returns the total session time saved, in seconds.
  Future<int> _totalSessionTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int time = prefs.getInt('com.mumble.mburger.audience.sessionTime') ?? 0;
    if (_startSessionDate != null) {
      time += DateTime.now().difference(_startSessionDate!).inSeconds;
    }
    return time;
  }

  /// The date of start of a session.
  /// @param session The index of the session.
  /// @return The date when the session with the index has started, if no session is found this function returns `null`.
  Future<DateTime?> startSessionDateForSession(int session) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = _sessionDateKeyForSession(session);
    int? value = prefs.getInt(key);
    if (value != null && value != 0) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return null;
  }
}
