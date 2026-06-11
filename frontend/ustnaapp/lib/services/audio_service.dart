import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class AudioService {
  final AudioRecorder _audioRecorder = AudioRecorder();
  String? _currentFilePath;

  /// Checks if the application has permission to record audio.
  Future<bool> hasPermission() async {
    return await _audioRecorder.hasPermission();
  }

  /// Starts recording audio into a temporary PCM file.
  Future<void> startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getTemporaryDirectory();
        
        // Generate unique filename to avoid conflict / cache issues
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final filePath = '${directory.path}/recording_$timestamp.pcm';
        _currentFilePath = filePath;

        // Configure to PCM 16-bit, 16000Hz, Mono for Python speech_recognition
        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.pcm16bits,
            sampleRate: 16000,
            numChannels: 1,
          ),
          path: filePath,
        );
      } else {
        throw Exception('Brak uprawnień do korzystania z mikrofonu.');
      }
    } catch (e) {
      throw Exception('Nie udało się rozpocząć nagrywania: $e');
    }
  }

  /// Stops recording and returns the path to the recorded file.
  Future<String?> stopRecording() async {
    try {
      if (await _audioRecorder.isRecording()) {
        final path = await _audioRecorder.stop();
        return path ?? _currentFilePath;
      }
      return null;
    } catch (e) {
      throw Exception('Błąd podczas zatrzymywania nagrywania: $e');
    }
  }

  /// Returns true if recording is currently active.
  Future<bool> isRecording() async {
    return await _audioRecorder.isRecording();
  }

  /// Cleans up resources.
  void dispose() {
    _audioRecorder.dispose();
  }
}
