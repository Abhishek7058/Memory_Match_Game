import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  late AudioPlayer _audioPlayer;
  bool _isEnabled = true;
  bool _isInitialized = false;

  Future<void> init() async {
    try {
      _audioPlayer = AudioPlayer();
      _isInitialized = true;
      if (kDebugMode) {
        print('AudioService initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize AudioService: $e');
      }
      _isInitialized = false;
    }
  }

  bool get isEnabled => _isEnabled;
  bool get isInitialized => _isInitialized;

  void toggleSound() {
    _isEnabled = !_isEnabled;
    if (kDebugMode) {
      print('Sound ${_isEnabled ? 'enabled' : 'disabled'}');
    }
  }

  Future<void> playFlipSound() async {
    if (!_isEnabled || !_isInitialized) return;
    try {
      await _audioPlayer.play(AssetSource('sounds/flip.mp3'));
      if (kDebugMode) {
        print('Playing flip sound');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error playing flip sound: $e');
      }
    }
  }

  Future<void> playMatchSound() async {
    if (!_isEnabled || !_isInitialized) return;
    try {
      await _audioPlayer.play(AssetSource('sounds/match.mp3'));
      if (kDebugMode) {
        print('Playing match sound');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error playing match sound: $e');
      }
    }
  }

  Future<void> playVictorySound() async {
    if (!_isEnabled || !_isInitialized) return;
    try {
      await _audioPlayer.play(AssetSource('sounds/victory.mp3'));
      if (kDebugMode) {
        print('Playing victory sound');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error playing victory sound: $e');
      }
    }
  }

  Future<void> playButtonSound() async {
    if (!_isEnabled || !_isInitialized) return;
    try {
      // Optional button click sound
      await _audioPlayer.play(AssetSource('sounds/button.mp3'));
      if (kDebugMode) {
        print('Playing button sound');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error playing button sound: $e');
      }
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}