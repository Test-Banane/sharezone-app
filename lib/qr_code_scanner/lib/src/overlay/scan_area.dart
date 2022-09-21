import 'dart:math';

import 'package:flutter/material.dart';

/// A widget that indicates a scan area in the middle of the screen.
///
/// Technically, everything that is covered by the camera could be scanned. The
/// [ScanArea] is just a visual indicator for the user.
class ScanArea extends StatelessWidget {
  const ScanArea({
    Key? key,
    this.color = Colors.white,
  }) : super(key: key);

  /// The color of the scan selection corners.
  ///
  /// Defaults to [Colors.white].
  final Color color;

  @override
  Widget build(BuildContext context) {
    const width = 250.0;
    return Stack(
      alignment: Alignment.center,
      children: [
        const CustomPaint(
          painter: _ScanSelectionPainter(width: width),
        ),
        _ScanSelectionCorner(
          width: width,
          color: color,
        ),
      ],
    );
  }
}

class _ScanSelectionPainter extends CustomPainter {
  const _ScanSelectionPainter({
    this.width = 250,
  });

  /// The width of the scan selection.
  ///
  /// Defaults to 250.
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    const center = Offset(0, 0);
    final path = Path();
    path.fillType = PathFillType.evenOdd;
    path.addRect(Rect.largest);
    path.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromCircle(center: center, radius: width / 2),
        Radius.circular(width / 10),
      ),
    );
    canvas.drawPath(path, Paint()..color = Colors.black.withOpacity(0.4));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class _ScanSelectionCorner extends StatelessWidget {
  const _ScanSelectionCorner({
    Key? key,
    this.color = Colors.white,
    this.width = 200,
  }) : super(key: key);

  /// The color of the scan selection corners.
  ///
  /// Defaults to [Colors.white].
  final Color color;

  final double width;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          painter: _CornerBorderPainter(
            color: color,
            width: width,
          ),
        ),
        Transform.rotate(
          angle: pi,
          child: CustomPaint(
            painter: _CornerBorderPainter(
              color: color,
              width: width,
            ),
          ),
        ),
        Transform.rotate(
          angle: pi / 2,
          child: CustomPaint(
            painter: _CornerBorderPainter(
              color: color,
              width: width,
            ),
          ),
        ),
        Transform.rotate(
          angle: pi / -2,
          child: CustomPaint(
            painter: _CornerBorderPainter(
              color: color,
              width: width,
            ),
          ),
        ),
      ],
    );
  }
}

/// A painter that draws rounded corners.
class _CornerBorderPainter extends CustomPainter {
  const _CornerBorderPainter({
    this.color = Colors.white,
    this.strokeWidth = 5,
    this.width = 250,
  });

  /// The color of the scan selection corners.
  ///
  /// Defaults to [Colors.white].
  final Color color;

  /// The stroke of the corner border.
  ///
  /// Defaults to 5.
  final double strokeWidth;

  /// The width of the scan selection.
  ///
  /// Is used to calculate the position of the corner border.
  ///
  /// Defaults to 250.
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    final start = Offset(width / -2, width / -2);
    const radius = 20.0;
    const length = 15;

    canvas.drawLine(
      start + const Offset(0, radius),
      start + const Offset(0, radius + length),
      Paint()
        ..color = color
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      start + const Offset(radius, 0),
      start + const Offset(radius + length, 0),
      Paint()
        ..color = color
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawArc(
      Rect.fromCircle(
        center: start + const Offset(radius, radius),
        radius: width / (width / 20),
      ),
      pi,
      pi / 2,
      false,
      Paint()
        ..color = color
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}