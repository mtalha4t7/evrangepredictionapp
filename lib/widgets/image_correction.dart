import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:sensors_plus/sensors_plus.dart';


class CorrectlyOrientedImage extends StatefulWidget {
  final String assetPath;
  final BoxFit fit;
  final double opacity;
  final double parallaxIntensity; // How much movement effect (0.0 to 1.0)

  const CorrectlyOrientedImage({
    super.key,
    required this.assetPath,
    this.fit = BoxFit.cover,
    this.opacity = 0.5,
    this.parallaxIntensity = 0.3,
  });

  @override
  State<CorrectlyOrientedImage> createState() => _CorrectlyOrientedImageState();
}

class _CorrectlyOrientedImageState extends State<CorrectlyOrientedImage> {
  ui.Image? _image;
  double _xOffset = 0;
  double _yOffset = 0;
  StreamSubscription<GyroscopeEvent>? _gyroSubscription;

  @override
  void initState() {
    super.initState();
    _loadImage();
    _initGyro();
  }

  @override
  void dispose() {
    _gyroSubscription?.cancel();
    super.dispose();
  }

  void _initGyro() {
    _gyroSubscription = gyroscopeEvents.listen((GyroscopeEvent event) {
      // Use the y-axis gyro data for left/right movement
      setState(() {
        _xOffset = event.y * 20 * widget.parallaxIntensity;
        // _yOffset = event.x * 10 * widget.parallaxIntensity; // Uncomment for vertical movement
      });
    });
  }

  Future<void> _loadImage() async {
    try {
      final ByteData data = await rootBundle.load(widget.assetPath);
      final Uint8List bytes = data.buffer.asUint8List();
      final ui.Image image = await _decodeImage(bytes);

      setState(() {
        _image = image;
      });
    } catch (e) {
      debugPrint('Error loading image: $e');
    }
  }

  Future<ui.Image> _decodeImage(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  @override
  Widget build(BuildContext context) {
    if (_image == null) {
      return const SizedBox.expand(); // Or a placeholder
    }

    return SizedBox.expand(
      child: Transform.translate(
        offset: Offset(_xOffset, _yOffset),
        child: CustomPaint(
          painter: _OrientedImagePainter(
            image: _image!,
            fit: widget.fit,
            opacity: widget.opacity,
          ),
        ),
      ),
    );
  }
}

class _OrientedImagePainter extends CustomPainter {
  final ui.Image image;
  final BoxFit fit;
  final double opacity;

  _OrientedImagePainter({
    required this.image,
    required this.fit,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(opacity)
      ..blendMode = BlendMode.darken;

    final srcSize = Size(image.width.toDouble(), image.height.toDouble());
    final dstRect = _getDestinationRect(size, srcSize);

    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, srcSize.width, srcSize.height),
      dstRect,
      paint,
    );
  }

  Rect _getDestinationRect(Size outputSize, Size inputSize) {
    if (fit == BoxFit.cover) {
      final double scale = max(
        outputSize.width / inputSize.width,
        outputSize.height / inputSize.height,
      );
      final double scaledWidth = inputSize.width * scale;
      final double scaledHeight = inputSize.height * scale;
      final double left = (outputSize.width - scaledWidth) / 2;
      final double top = (outputSize.height - scaledHeight) / 2;
      return Rect.fromLTWH(left, top, scaledWidth, scaledHeight);
    } else {
      return Rect.fromLTWH(0, 0, outputSize.width, outputSize.height);
    }
  }

  @override
  bool shouldRepaint(covariant _OrientedImagePainter oldDelegate) {
    return oldDelegate.image != image ||
        oldDelegate.fit != fit ||
        oldDelegate.opacity != opacity;
  }
}