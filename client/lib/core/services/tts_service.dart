import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Text-to-Speech service for story narration
class TTSService extends ChangeNotifier {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isPlaying = false;
  bool _isPaused = false;
  double _speed = 1.0;
  int _currentWord = 0;

  bool get isPlaying => _isPlaying;
  bool get isPaused => _isPaused;
  double get speed => _speed;
  int get currentWord => _currentWord;

  static const List<double> speedOptions = [0.8, 1.0, 1.2];

  TTSService() {
    _initTts();
  }

  void _initTts() {
    _flutterTts.setStartHandler(() {
      _isPlaying = true;
      _isPaused = false;
      notifyListeners();
    });

    _flutterTts.setCompletionHandler(() {
      _isPlaying = false;
      _isPaused = false;
      _currentWord = 0;
      notifyListeners();
    });

    _flutterTts.setCancelHandler(() {
      _isPlaying = false;
      _isPaused = false;
      _currentWord = 0;
      notifyListeners();
    });

    _flutterTts.setPauseHandler(() {
      _isPaused = true;
      notifyListeners();
    });

    _flutterTts.setContinueHandler(() {
      _isPaused = false;
      notifyListeners();
    });

    _flutterTts.setProgressHandler((String text, int startOffset, int endOffset, String word) {
      _currentWord = endOffset;
      notifyListeners();
    });

    // Set default language
    _flutterTts.setLanguage('en-US');
    _flutterTts.setSpeechRate(0.5);
    _flutterTts.setVolume(1.0);
    _flutterTts.setPitch(1.0);
  }

  /// Set playback speed
  Future<void> setSpeed(double speed) async {
    _speed = speed;
    await _flutterTts.setSpeechRate(speed * 0.5);
    notifyListeners();
  }

  /// Play text
  Future<void> speak(String text) async {
    if (text.isEmpty) return;

    await _flutterTts.speak(text);
  }

  /// Pause playback
  Future<void> pause() async {
    await _flutterTts.pause();
  }

  /// Resume playback
  Future<void> resume() async {
    await _flutterTts.speak('');
  }

  /// Stop playback
  Future<void> stop() async {
    await _flutterTts.stop();
    _isPlaying = false;
    _isPaused = false;
    _currentWord = 0;
    notifyListeners();
  }

  /// Toggle play/pause
  Future<void> togglePlayPause(String text) async {
    if (_isPlaying && !_isPaused) {
      await pause();
    } else if (_isPaused) {
      await resume();
    } else {
      await speak(text);
    }
  }

  /// Cycle through speed options
  Future<void> cycleSpeed() async {
    final currentIndex = speedOptions.indexOf(_speed);
    final nextIndex = (currentIndex + 1) % speedOptions.length;
    await setSpeed(speedOptions[nextIndex]);
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }
}
