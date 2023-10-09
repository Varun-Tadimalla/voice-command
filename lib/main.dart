import 'package:flutter/material.dart';
import 'package:speech_recognition/speech_recognition.dart';

void main() => runApp(VoiceControlledPictureApp());

class VoiceControlledPictureApp extends StatefulWidget {
  @override
  _VoiceControlledPictureAppState createState() =>
      _VoiceControlledPictureAppState();
}

class _VoiceControlledPictureAppState extends State<VoiceControlledPictureApp> {
  SpeechRecognition _speech;
  bool _isListening = false;
  String _currentWord = '';
  String _currentImageUrl = '';

  final Map<String, String> wordToImageUrl = {
    'cat': 'https://example.com/cat.jpg',
    'dog': 'https://example.com/dog.jpg',
    'flower': 'https://example.com/flower.jpg',
    // Add more words and URLs as needed
  };

  @override
  void initState() {
    super.initState();
    _initSpeechRecognition();
  }

  void _initSpeechRecognition() {
    _speech = SpeechRecognition();
    _speech.setAvailabilityHandler((bool isAvailable) {
      setState(() => _isListening = isAvailable);
    });
    _speech.setCurrentLocaleHandler((String locale) {});
    _speech.setRecognitionStartedHandler(() {
      setState(() => _isListening = true);
    });
    _speech.setRecognitionResultHandler((String result) {
      setState(() => _currentWord = result);
    });
    _speech.setRecognitionCompleteHandler(() {
      setState(() {
        _isListening = false;
        _processVoiceCommand();
      });
    });
    _speech.activate().then((result) {
      if (!mounted) return;
      setState(() => _isListening = result);
    });
  }

  void _processVoiceCommand() {
    final command = _currentWord.toLowerCase();
    if (wordToImageUrl.containsKey(command)) {
      setState(() => _currentImageUrl = wordToImageUrl[command]!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Voice-Controlled Picture Viewer'),
        ),
        body: Stack(
          children: <Widget>[
            if (_currentImageUrl.isNotEmpty)
              Image.network(
                _currentImageUrl,
                fit: BoxFit.cover, // Cover the entire screen
                width: double.infinity,
                height: double.infinity,
              ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Listening: $_isListening',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Voice Command: $_currentWord',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _isListening ? _speech.stop : _speech.listen,
          child: Icon(_isListening ? Icons.mic_off : Icons.mic),
        ),
      ),
    );
  }
}
