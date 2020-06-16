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
      print('addPersistentFrameCallback');
      setState(() {
        //TODO WARNING 上个界面不先收起键盘再跳转的话，这里获取到的高度是除了键盘的
        //在R1上，期望628，获取到的是297
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
    for (var item in data.selectables) {
      item.draw(canvas);
      item.drawSelected(canvas);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => oldDelegate != this;
}
