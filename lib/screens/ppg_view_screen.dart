import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
// path to your BLoC files
import '../blocs/heart_rate/heart_rate_bloc.dart';
import '../widgets/heart_rate_widget.dart';

class PPGCameraView extends StatefulWidget {
  final Function(int bpm) onReading;
  const PPGCameraView({required this.onReading, Key? key}) : super(key: key);

  @override
  State<PPGCameraView> createState() => _PPGCameraViewState();
}

class _PPGCameraViewState extends State<PPGCameraView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnim;
  bool _isDarkTheme = true;
  bool _showCamera = false;
  List<int> _samples = [];
  int _latestBpm = 0;

  CameraController? _controller;

  @override
  void initState() {
    super.initState();
    context.read<HeartRateBloc>().add(StartMonitoring());

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    _scaleAnim = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller?.dispose();
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
      body: BlocConsumer<HeartRateBloc, HeartRateState>(
        listener: (context, state) {
          if (state is HeartRateUpdated) {
            widget.onReading(state.bpm);
            setState(() {
              _latestBpm = state.bpm;
              _samples.add(state.bpm);
              if (_samples.length > 150) {
                _samples = _samples.sublist(_samples.length - 150);
              }
            });
            _animationController
                .forward()
                .then((_) => _animationController.reverse());
          }
        },
        builder: (context, state) {
          if (state is HeartRateInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          // Check for controller initialization
          bool flashOn = true;

          if (state is HeartRateMeasuring) {
            _controller = state.controller;
            flashOn = state.flashOn;
          } else if (state is HeartRateUpdated) {
            flashOn = state.flashOn;
          } else if (state is HeartRateFlashToggled) {
            flashOn = state.flashOn;
          }

          return SafeArea(
            child: Stack(
              children: [
                // Center BPM display
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
                          child: Text(
                            _latestBpm > 0 ? '$_latestBpm BPM' : 'Measuring...',
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: BlocBuilder<HeartRateBloc, HeartRateState>(
                            builder: (context, state) {
                              if (state is HeartRateMeasuring) {
                                return buildRedIntensityChart(state.redSamples);
                              } else {
                                return const Center(
                                    child: Text("Initializing..."));
                              }
                            },
                          )),
                    ],
                  ),
                ),

                // Theme toggle
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

                // Flash toggle
                Positioned(
                  top: 20,
                  left: 20,
                  child: IconButton(
                    icon: Icon(
                      flashOn ? Icons.flash_on : Icons.flash_off,
                      color: textColor,
                      size: 28,
                    ),
                    onPressed: () {
                      context.read<HeartRateBloc>().add(ToggleFlash());
                    },
                  ),
                ),

                // Camera preview only if controller is initialized
                if (_showCamera &&
                    _controller != null &&
                    _controller!.value.isInitialized)
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
                        child: ClipOval(child: CameraPreview(_controller!)),
                      ),
                    ),
                  ),

                // FAB to toggle camera visibility
                Positioned(
                  bottom: 30,
                  right: 20,
                  child: FloatingActionButton.extended(
                    backgroundColor: bpmColor,
                    onPressed: () {
                      setState(() => _showCamera = !_showCamera);
                    },
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
          );
        },
      ),
    );
  }
}
