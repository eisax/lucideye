import 'package:flutter/material.dart';

class QRScannerOverlay extends StatefulWidget {
  QRScannerOverlay(
      {Key? key,
      required this.overlayColour,
      required this.lineColor,
      required this.scanAreaHeight,
      required this.scanAreaRadius,
      required this.scanAreaWidth})
      : super(key: key);

  Color overlayColour;
  Color lineColor;
  final double scanAreaHeight;
  final double scanAreaWidth;
  late double scanAreaRadius;

  @override
  State<QRScannerOverlay> createState() => _QRScannerOverlayState();
}

class _QRScannerOverlayState extends State<QRScannerOverlay> {
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      ColorFiltered(
        colorFilter: ColorFilter.mode(widget.overlayColour,
            BlendMode.srcOut), // This one will create the magic
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                  color: Colors.red,
                  backgroundBlendMode: BlendMode
                      .dstOut), // This one will handle background + difference out
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                height: widget.scanAreaHeight,
                width: widget.scanAreaWidth,
                decoration: BoxDecoration(
                  color: Colors.yellow,
                  borderRadius: BorderRadius.circular(widget.scanAreaRadius),
                ),
              ),
            ),
          ],
        ),
      ),
      Align(
        alignment: Alignment.center,
        child: CustomPaint(
          foregroundPainter: BorderPainter(widget.lineColor,widget.scanAreaRadius),
          child: SizedBox(
            width: widget.scanAreaWidth + 25,
            height: widget.scanAreaHeight + 25,
          ),
        ),
      ),
    ]);
  }
}

// Creates the white borders
class BorderPainter extends CustomPainter {
  Color lineColor;
  late double lineRadius;

  BorderPainter(this.lineColor,this.lineRadius);
  @override
  void paint(Canvas canvas, Size size) {
    const width = 1.0;
    final radius = lineRadius;
    final tRadius = 20*3.0;
    final rect = Rect.fromLTWH(
      width,
      width,
      size.width - 2 * width,
      size.height - 2 * width,
    );
    final rrect = RRect.fromRectAndRadius(rect,  Radius.circular(radius));
    final clippingRect0 = Rect.fromLTWH(
      0,
      0,
      tRadius,
      tRadius,
    );
    final clippingRect1 = Rect.fromLTWH(
      size.width - tRadius,
      0,
      tRadius,
      tRadius,
    );
    final clippingRect2 = Rect.fromLTWH(
      0,
      size.height - tRadius,
      tRadius,
      tRadius,
    );
    final clippingRect3 = Rect.fromLTWH(
      size.width - tRadius,
      size.height - tRadius,
      tRadius,
      tRadius,
    );

    final path = Path()
      ..addRect(clippingRect0)
      ..addRect(clippingRect1)
      ..addRect(clippingRect2)
      ..addRect(clippingRect3);

    canvas.clipPath(path);
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = width,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class BarReaderSize {
  static double width = 200;
  static double height = 200;
}

class OverlayWithHolePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black54;
    canvas.drawPath(
        Path.combine(
          PathOperation.difference,
          Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
          Path()
            ..addOval(Rect.fromCircle(
                center: Offset(size.width - 44, size.height - 44), radius: 40))
            ..close(),
        ),
        paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

@override
bool shouldRepaint(CustomPainter oldDelegate) {
  return false;
}
