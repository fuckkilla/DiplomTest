import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late WebSocketChannel _channel;
  String result = '';
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _channel = WebSocketChannel.connect(Uri.parse('ws://10.0.2.2:8765'));
    _channel.stream.listen((message) {
      setState(() => result = message);
    });
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _controller = CameraController(cameras[0], ResolutionPreset.medium);
    await _controller.initialize();
    if (!mounted) return;
    setState(() {});
    _startFrameSendingLoop();
  }

  void _startFrameSendingLoop() {
    Timer.periodic(Duration(milliseconds: 300), (timer) async {
      if (!_controller.value.isInitialized || _sending) return;
      _sending = true;
      try {
        final XFile picture = await _controller.takePicture();
        final bytes = await picture.readAsBytes();
        final base64Image = base64Encode(bytes);
        _channel.sink.add(base64Image);
      } catch (_) {}
      _sending = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text('Gesture Recognition')),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: CameraPreview(_controller),
          ),
          SizedBox(height: 10),
          Text('Server response: $result'),
        ],
      ),
    );
  }
}
