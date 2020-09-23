import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:wallpaper_maker/cus_widgets/cus_gesture.dart';
import 'package:wallpaper_maker/inherit/inherited_config.dart';
import 'package:flutter/painting.dart';

class CanvasPanel extends StatefulWidget {
  final GlobalKey rKey;

  CanvasPanel(this.rKey);

  @override
  _CanvasPanelState createState() => _CanvasPanelState();
}

class _CanvasPanelState extends State<CanvasPanel> {
  double widgetHeight = 0;
  ConfigWidgetState data;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        widgetHeight = context.size.height;
        data.setSize(height: widgetHeight, ratio: data.size2Save.aspectRatio);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    data = ConfigWidget.of(context);

    return CanvasGestureDetector(
      onTapDownCallback: (details) => data.handleTapDown(details),
      onDragUpdateCallback: (details) => data.handleTapUpdate(details),
      ondragEndCallback: (details) => data.handleTapEnd(details),
      onScaleStartCallback: (details) => data.handleScaleStart(details),
      onScaleUpdateCallback: (details) => data.handleScaleUpdate(details),
      onScaleEndCallback: (details) => data.handleScaleEnd(details),
      onTapUpCallback: (details) => data.handleTapUp(details),
      child: RepaintBoundary(
        key: widget.rKey,
        child: CustomPaint(
          size: data.size,
          painter: MyCanvas(data: data),
        ),
      ),
    );
  }
}

class MyCanvas extends CustomPainter {
  ConfigWidgetState data;

  MyCanvas({this.data});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(
      Rect.fromCenter(
          center: Offset(size.width / 2, size.height / 2),
          width: size.width,
          height: size.height),
    );

    //draw background.
    canvas.drawColor(data.getBackroundColor(), BlendMode.src);

    //draw selectables.
    for (var item in data.selectables) {
      item.draw(canvas);
    }
    //draw select frame.
    if (data.isSelectedMode) {
      data.currentSelectable?.drawSelected(canvas);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => oldDelegate != this;
}

class WidthPicker extends CustomPainter {
  WidthPicker({this.width, this.color});

  double width;
  Color color;

  @override
  void paint(Canvas canvas, Size size) {
    Path path = Path()
      ..moveTo(0, size.height / 2)
      ..conicTo(size.width / 4, 0, size.width / 2, size.height / 2, 1)
      ..conicTo(
          size.width / 4 * 3, size.height, size.width, size.height / 2, 1);
    canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = width);
  }

  @override
  bool shouldRepaint(WidthPicker oldDelegate) => oldDelegate.width != width;
}
