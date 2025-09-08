import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../widgets/heart_rate_widget.dart';

class PPGCameraView_sateless extends StatefulWidget {
  final Function(int bpm) onReading;
  const PPGCameraView_sateless({required this.onReading, Key? key})
      : super(key: key);

  @override
  State<PPGCameraView_sateless> createState() => _PPGCameraViewState();
}

class _PPGCameraViewState extends State<PPGCameraView_sateless>
    with SingleTickerProviderStateMixin {
  late CameraController _controller;
  bool _processing = false;
  bool _showCamera = false;
  bool _flashOn = true;
  bool _isDarkTheme = true;

  List<int> _redSamples = [];
  Timer? _bpmTimer;
  int _bpm = 0;

  late AnimationController _animationController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.1).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final backCamera = cameras.first;

    _controller =
        CameraController(backCamera, ResolutionPreset.low, enableAudio: false);
    await _controller.initialize();
    await _controller.setFlashMode(FlashMode.torch);
    _flashOn = true;

    await _controller.startImageStream(_processCameraImage);
    setState(() {});
    _bpmTimer =
        Timer.periodic(const Duration(seconds: 3), (_) => _calculateBPM());
  }

  void _processCameraImage(CameraImage image) {
    if (_processing) return;
    _processing = true;

    try {
      final redAvg = _averageRedIntensity(image);
      _redSamples.add(redAvg);
      if (_redSamples.length > 150) {
        _redSamples = _redSamples.sublist(_redSamples.length - 150);
      }
    } finally {
      _processing = false;
    }
  }

  int _averageRedIntensity(CameraImage image) {
    final bytes = image.planes[0].bytes;
    int sum = 0;
    for (int i = 0; i < bytes.length; i += 4) {
      sum += bytes[i];
    }
    return sum ~/ (bytes.length ~/ 4);
  }

  void _calculateBPM() {
    if (_redSamples.length < 2) return;

    final diffs = List.generate(
        _redSamples.length - 1, (i) => _redSamples[i + 1] - _redSamples[i]);
    final peaks = <int>[];
    for (int i = 1; i < diffs.length - 1; i++) {
      if (diffs[i - 1] > 0 && diffs[i] < 0 && _redSamples[i] > 128) {
        peaks.add(i);
      }
    }

    if (peaks.length < 2) return;
    final intervals =
        List.generate(peaks.length - 1, (i) => peaks[i + 1] - peaks[i]);
    final avgInterval = intervals.reduce((a, b) => a + b) / intervals.length;

    final bpm = (60 * 30 / avgInterval).round();

    setState(() => _bpm = bpm);
    widget.onReading(bpm);
    _animationController.forward().then((_) => _animationController.reverse());
  }

  Future<void> _toggleFlash() async {
    if (_controller.value.isInitialized) {
      if (_flashOn) {
        await _controller.setFlashMode(FlashMode.off);
      } else {
        await _controller.setFlashMode(FlashMode.torch);
      }
      setState(() => _flashOn = !_flashOn);
    }
  }

  Future<void> _toggleCameraView() async {
    setState(() => _showCamera = !_showCamera);
  }

  @override
  void dispose() {
    _controller.dispose();
    _bpmTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final backgroundColor = _isDarkTheme ? Colors.black : Colors.white;
    final textColor = _isDarkTheme ? Colors.white : Colors.black;
    final bpmColor = Colors.blueAccent;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: _controller.value.isInitialized
          ? SafeArea(
              child: Stack(
                children: [
                  // Center BPM Display
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ScaleTransition(
                          scale: _scaleAnim,
                          child: AnimatedDefaultTextStyle(
                            duration: Duration(milliseconds: 300),
                            style: TextStyle(
                              fontSize: size.width * 0.1,
                              fontWeight: FontWeight.w600,
                              color: bpmColor,
                            ),
                            child:
                                Text(_bpm > 0 ? '$_bpm BPM' : 'Measuring...'),
                          ),
                        ),
                        SizedBox(height: 40),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: buildRedIntensityChart(_redSamples),
                        ),
                      ],
                    ),
                  ),

                  // Theme Toggle
                  Positioned(
                    top: 20,
                    right: 20,
                    child: AnimatedSwitcher(
                      duration: Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) =>
                          ScaleTransition(scale: animation, child: child),
                      child: IconButton(
                        key: ValueKey(_isDarkTheme),
                        icon: Icon(
                          _isDarkTheme ? Icons.light_mode : Icons.dark_mode,
                          color: textColor,
                          size: 28,
                        ),
                        onPressed: () {
                          setState(() => _isDarkTheme = !_isDarkTheme);
                        },
                      ),
                    ),
                  ),

                  // Flash Toggle
                  Positioned(
                    top: 20,
                    left: 20,
                    child: IconButton(
                      icon: Icon(
                        _flashOn ? Icons.flash_on : Icons.flash_off,
                        color: textColor,
                        size: 28,
                      ),
                      onPressed: _toggleFlash,
                    ),
                  ),

                  // Camera Preview (optional)
                  if (_showCamera)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: size.height * 0.15),
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          width: size.width * 0.4,
                          height: size.width * 0.4,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: bpmColor.withOpacity(0.25),
                                blurRadius: 10,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                          child: ClipOval(child: CameraPreview(_controller)),
                        ),
                      ),
                    ),

                  // FAB for camera view toggle
                  Positioned(
                    bottom: 30,
                    right: 20,
                    child: FloatingActionButton.extended(
                      backgroundColor: bpmColor,
                      onPressed: _toggleCameraView,
                      icon: Icon(
                        _showCamera ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white,
                      ),
                      label: Text(
                        _showCamera ? 'Hide Camera' : 'Show Camera',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
