import 'dart:ui';
import 'package:flutter/material.dart' hide SelectableText;
import 'package:wallpaper_maker/cus_gesture.dart';
import 'package:wallpaper_maker/inherited_config.dart';
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
        data.setSize(height: widgetHeight, ratio: 2);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    data = ConfigWidget.of(context);

    return Container(
      color: Colors.amber,
      // child: GestureDetector(
      //   child: RepaintBoundary(
      //     key: widget.rKey,
      //     child: CustomPaint(
      //       size: data.size,
      //       painter: MyCanvas(data: data),
      //     ),
      //   ),
      //   onTapUp: (details) => data.handleTapUp(details),
      //   onScaleStart: (details) {
      //     data.handleScaleStart(details);
      //   },
      //   onScaleUpdate: (details) {
      //     data.handleScaleUpdate(details);
      //   },
      //   onScaleEnd: (details) => data.handleScaleEnd(details),
      //   onTapDown: (details) => data.handleTapDown(details),
      // ),
      child: CanvasGestureDetector(
        child: RepaintBoundary(
          key: widget.rKey,
          child: CustomPaint(
            size: data.size,
            painter: MyCanvas(data: data),
          ),
        ),
        onTapDownCallback: (details) => data.handleTapDown(details),
        onScaleStartCallback: (details) => data.handleScaleStart(details),
        onScaleUpdateCallback: (details) => print('on SCALE update'),
        onTapUpdateCallback: (details) => printsomething(details),
      ),
    );
  }

  printsomething(DragUpdateDetails details) {
    print('some thing: ${details.globalPosition}');
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
    canvas.drawColor(data.config.bgColor, BlendMode.srcIn);

    //draw selectables
    for (var item in data.selectables) {
      item.draw(canvas);
      item.drawSelected(canvas);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => oldDelegate != this;
}
