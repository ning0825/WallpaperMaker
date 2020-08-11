import 'dart:ui';
import 'package:flutter/material.dart' hide SelectableText;
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

    return Container(
      color: Colors.amber,
      child: CanvasGestureDetector(
        child: RepaintBoundary(
          key: widget.rKey,
          child: CustomPaint(
            size: data.size,
            painter: MyCanvas(data: data),
          ),
        ),
        onTapDownCallback: (details) => data.handleTapDown(details),
        onDragUpdateCallback: (details) => data.handleTapUpdate(details),
        ondragEndCallback: (details) => data.handleTapEnd(details),
        onScaleStartCallback: (details) => data.handleScaleStart(details),
        onScaleUpdateCallback: (details) => data.handleScaleUpdate(details),
        onScaleEndCallback: (details) => data.handleScaleEnd(details),
        onTapUpCallback: (details) => data.handleTapUp(details),
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

    //draw background
    canvas.drawColor(data.config.bgColor, BlendMode.src);

    //draw selectables
    //TODO: draw select rect over other items, but iterate twice can cause performance issue.
    for (var item in data.selectables) {
      item.draw(canvas);
    }
    for (var item in data.selectables) {
      item.drawSelected(canvas);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => oldDelegate != this;
}

class WidthPicker extends CustomPainter {
  WidthPicker(this.width);

  double width;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(
        Offset(5, size.height / 2),
        Offset(size.width - 5, size.height / 2),
        Paint()
          ..color = Colors.green
          ..strokeWidth = width);
  }

  @override
  bool shouldRepaint(WidthPicker oldDelegate) => oldDelegate.width != width;
}
