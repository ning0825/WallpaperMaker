import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:wallpaper_maker/inherited_config.dart';

enum MessageBoxDirection { left, right, top, bottom }

///A rectangular border with a triangle indicator at bottom.
///
///@param position: indicator's position.
class MessageBoxBorder extends OutlinedBorder {
  const MessageBoxBorder(
      {this.color,
      this.position = 20,
      this.direction = MessageBoxDirection.bottom});

  EdgeInsetsGeometry get dimensions => EdgeInsets.all(0.0);

  final Color color;

  final double position;

  final MessageBoxDirection direction;

  final double indicatorHeight = 10;

  @override
  MessageBoxBorder copyWith({BorderSide side}) =>
      MessageBoxBorder(color: this.color);

  @override
  Path getInnerPath(Rect rect, {TextDirection textDirection}) {
    Path trianglePath = Path()
      ..moveTo(rect.left + position - 5, rect.bottom)
      ..lineTo(rect.left + position + 5, rect.bottom)
      ..lineTo(rect.left + position, rect.bottom + indicatorHeight)
      ..close();
    trianglePath.addRect(rect);
    return trianglePath;
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection textDirection}) {
    Path trianglePath = Path()
      ..moveTo(rect.left + position - 5, rect.bottom)
      ..lineTo(rect.left + position + 5, rect.bottom)
      ..lineTo(rect.left + position, rect.bottom + indicatorHeight)
      ..close();
    trianglePath.addRect(rect);
    return trianglePath;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection textDirection}) {
    Path trianglePath;
    if (direction == MessageBoxDirection.bottom) {
      trianglePath = Path()
        ..moveTo(rect.left + position - 5, rect.bottom)
        ..lineTo(rect.left + position + 5, rect.bottom)
        ..lineTo(rect.left + position, rect.bottom + indicatorHeight)
        ..close();
    } else if (direction == MessageBoxDirection.top) {
      trianglePath = Path()
        ..moveTo(rect.left + position - 5, rect.top)
        ..lineTo(rect.left + position + 5, rect.top)
        ..lineTo(rect.left + position, rect.top - indicatorHeight)
        ..close();
    }

    trianglePath.addRect(rect);
    canvas.drawPath(trianglePath, Paint()..color = this.color);
  }

  @override
  ShapeBorder scale(double t) => MessageBoxBorder(color: color);
}

typedef RotateCallback = void Function(double angle);

///Rotate widget
///
///10dp 是 1 度
class RotateWidget extends LeafRenderObjectWidget {
  RotateWidget({this.rotateCallback, this.angle});

  final RotateCallback rotateCallback;
  final double angle;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      RotateRenderBox(rotateCallback: this.rotateCallback, angle: this.angle);

  @override
  void updateRenderObject(
      BuildContext context, covariant RotateRenderBox renderObject) {
    // renderObject.angle = this.angle;
  }
}

class RotateRenderBox extends RenderBox {
  RotateRenderBox({this.rotateCallback, double angle}) {
    this.angle = angle ?? 0;
    linePainter = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    indicatorPainter = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    linePath = Path();

    frac = 0;
  }

  double _angle;
  set angle(double ang) {
    _angle = ang;
    markNeedsPaint();
  }

  RotateCallback rotateCallback;

  double mainLength = 20;
  double subLength = 10;
  //10dp表示1度
  double subGap = 10;

  Path linePath;
  Paint linePainter;
  Paint indicatorPainter;

  double frac;

  @override
  bool get sizedByParent => true;

  @override
  void handleEvent(PointerEvent event, covariant BoxHitTestEntry entry) {
    super.handleEvent(event, entry);
    angle = _angle - event.delta.dx / subGap;
    frac = (frac + event.delta.dx) % subGap;
    rotateCallback(_angle);
    markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    context.canvas.clipRect(offset & size);

    for (int i = 0; i < (size.width - 20) / subGap; i++) {
      var x = offset.dx + 10 + i * subGap;

      linePath.moveTo(x, offset.dy);
      linePath.lineTo(x, offset.dy + subLength);

      var angle2Draw =
          ((_angle.toInt() - size.width / subGap / 2 + i) % 360).toInt();
      if (angle2Draw % 5 == 0) {
        TextSpan ts = TextSpan(
            text: angle2Draw.toString(), style: TextStyle(fontSize: 10));
        TextPainter painter =
            TextPainter(text: ts, textDirection: TextDirection.ltr);
        painter.layout();
        painter.paint(
            context.canvas,
            Offset(offset.dx + i * subGap + frac - painter.width / 2,
                offset.dy + subLength));
      }
    }

    context.canvas.drawPath(linePath, linePainter);
    context.canvas.drawLine(Offset(offset.dx + size.width / 2, offset.dy),
        Offset(offset.dx + size.width / 2, offset.dy + 60), indicatorPainter);

    linePath.reset();
  }

  @override
  bool hitTestSelf(Offset position) => size.contains(position);
}

typedef OnColorPick = void Function(Color color);

class SelectColorRect {
  SelectColorRect(this.row, this.col);
  int row;
  int col;
}

/// Color picker widget.
///
/// When User tap and move on this widget, [onColorPick] will be invoked.
/// [selectColor] is used to set initial color of this widget to show hightlight frame on the color.
class PaletteWidget extends LeafRenderObjectWidget {
  PaletteWidget({this.onColorPick, this.selectColor});

  final OnColorPick onColorPick;
  final Color selectColor;

  @override
  PaletteRenderBox createRenderObject(BuildContext context) =>
      PaletteRenderBox(onColorPick)..selectColor = this.selectColor;

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {
    (renderObject as PaletteRenderBox).onColorPick = this.onColorPick;
    (renderObject as PaletteRenderBox).selectColor = this.selectColor;
  }
}

class PaletteRenderBox extends RenderBox {
  PaletteRenderBox(this.onColorPick);

  OnColorPick onColorPick;

  double pieceWidth;
  double pieceHeight;

  double ratio = window.devicePixelRatio;

  Size pieceSize;

  SelectColorRect selectColorRect;

  int row;
  int col;

  set selectColor(Color color) {
    //找第一行是否匹配 color
    for (var i = 0; i < 12; i++) {
      if (Color.fromARGB(255, 23 * (11 - i), 23 * (11 - i), 23 * (11 - i))
              .value ==
          color.value) {
        row = 0;
        col = i;
      }
    }

    for (var i = 1; i < 10; i++) {
      for (var j = 0; j < 12; j++) {
        if (colorlist[j][100 * (10 - i)] == color) {
          row = i;
          col = j;
        }
      }
    }

    if (row != null && col != null) {
      selectColorRect = SelectColorRect(row, col);
    } else {
      selectColorRect = SelectColorRect(0, 11);
    }
  }

  var colorlist = const [
    Colors.red,
    Colors.deepOrange,
    Colors.orange,
    Colors.amber,
    Colors.yellow,
    Colors.lime,
    Colors.lightGreen,
    Colors.green,
    Colors.lightBlue,
    Colors.blue,
    Colors.purple,
    Colors.deepPurple,
  ];

  @override
  bool get sizedByParent => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    super.handleEvent(event, entry);
    row = (event.localPosition.dy / (size.width / 10)).floor();
    col = (event.localPosition.dx / (size.width / 12)).floor();

    selectColorRect = SelectColorRect(row, col);

    //第一行是黑白
    if (row == 0) {
      onColorPick(Color.fromARGB(
          255, 23 * (11 - col), 23 * (11 - col), 23 * (11 - col)));
    } else {
      onColorPick(colorlist[col][(10 - row) * 100]);
    }
    markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    context.canvas.clipRect(offset & size);

    //第一行
    for (var i = 0; i < 12; i++) {
      context.canvas.drawRect(
        Offset(offset.dx + pieceWidth * i, offset.dy) &
            Size(pieceWidth, pieceHeight),
        Paint()
          ..color =
              Color.fromARGB(255, 23 * (11 - i), 23 * (11 - i), 23 * (11 - i)),
      );
    }

    //后9行
    for (var i = 1; i < 10; i++) {
      for (var j = 0; j < 12; j++) {
        //draw color.
        context.canvas.drawRect(
            Offset(offset.dx + pieceWidth * j, offset.dy + pieceHeight * i) &
                pieceSize + Offset(1, 1),
            Paint()..color = colorlist[j][100 * (10 - i)]);
      }
    }

    //selected color frame.
    context.canvas.drawRect(
        Offset(offset.dx + pieceWidth * selectColorRect.col,
                offset.dy + pieceHeight * selectColorRect.row) &
            pieceSize + Offset(1, 1),
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0);
  }

  @override
  void performResize() {
    size = Size(constraints.biggest.width, constraints.biggest.width);

    //12列
    pieceWidth = size.width / 12;

    //10行
    pieceHeight = size.height / 10;

    pieceSize = Size(pieceWidth, pieceHeight);
  }

  @override
  bool hitTestSelf(Offset position) => size.contains(position);
}

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
  Widget build(BuildContext context) {
    data = ConfigWidget.of(context);
    return CanvasGestureDetector(
      onTapDownCallback: data.handleTapDown,
      onDragUpdateCallback: data.handleTapUpdate,
      ondragEndCallback: data.handleTapEnd,
      onScaleStartCallback: data.handleScaleStart,
      onScaleUpdateCallback: data.handleScaleUpdate,
      onScaleEndCallback: data.handleScaleEnd,
      onTapUpCallback: data.handleTapUp,
      child: Transform(
        alignment: Alignment.center,
        transform:
            Matrix4.diagonal3Values(data.canvasScale, data.canvasScale, 1.0)
              ..translate(data.canvasOffset.dx, data.canvasOffset.dy),
        child: RepaintBoundary(
          key: widget.rKey,
          child: CustomPaint(
            size: data.size,
            painter: MyCanvas(data: data),
          ),
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

class CanvasGestureRecognizer extends OneSequenceGestureRecognizer {
  GestureTapDownCallback onDown;
  GestureDragUpdateCallback onUpdate;
  GestureDragEndCallback onEnd;
  // GestureScaleStartCallback onTransStart;
  // GestureScaleUpdateCallback onTransUpdate;

  Offset currentLocalPosition;
  Offset currentGlobalPosition;

  bool isTracking = false;

  @override
  void addAllowedPointer(PointerDownEvent event) {
    if (!isTracking) {
      startTrackingPointer(event.pointer, event.transform);
      isTracking = true;
    }
  }

  @override
  void handleEvent(PointerEvent event) {
    currentLocalPosition =
        PointerEvent.transformPosition(event.transform, event.position);
    var localDelta = PointerEvent.transformDeltaViaPositions(
        untransformedEndPosition: event.position,
        untransformedDelta: event.delta,
        transform: event.transform);

    if (event is PointerDownEvent) {
      invokeCallback('on tap down',
          () => onDown(TapDownDetails(localPosition: currentLocalPosition)));
    }

    if (event is PointerMoveEvent) {
      invokeCallback(
        'on tap update',
        () => onUpdate(
          DragUpdateDetails(
              localPosition: currentLocalPosition,
              globalPosition: event.position,
              delta: localDelta),
        ),
      );
    }

    if (event is PointerUpEvent) {
      invokeCallback('on tap end', () => onEnd(DragEndDetails()));
      isTracking = false;
    }
  }

  @override
  void didStopTrackingLastPointer(int pointer) {}

  @override
  String get debugDescription => throw UnimplementedError();
}

class CanvasGestureDetector extends StatelessWidget {
  final GestureTapDownCallback onTapDownCallback;
  final GestureDragUpdateCallback onDragUpdateCallback;
  final GestureDragEndCallback ondragEndCallback;
  final GestureScaleStartCallback onScaleStartCallback;
  final GestureScaleUpdateCallback onScaleUpdateCallback;
  final GestureScaleEndCallback onScaleEndCallback;
  final GestureTapUpCallback onTapUpCallback;

  final Widget child;

  CanvasGestureDetector(
      {this.child,
      this.onScaleStartCallback,
      this.onScaleUpdateCallback,
      this.onScaleEndCallback,
      this.onTapDownCallback,
      this.onDragUpdateCallback,
      this.ondragEndCallback,
      this.onTapUpCallback});

  @override
  Widget build(BuildContext context) {
    final Map<Type, GestureRecognizerFactory> gestures =
        <Type, GestureRecognizerFactory>{};

    gestures[TapGestureRecognizer] =
        GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
            () => TapGestureRecognizer(), (TapGestureRecognizer instance) {
      instance..onTapUp = onTapUpCallback;
    });

    gestures[CanvasGestureRecognizer] =
        GestureRecognizerFactoryWithHandlers<CanvasGestureRecognizer>(
            () => CanvasGestureRecognizer(),
            (CanvasGestureRecognizer instance) {
      instance
        ..onDown = onTapDownCallback
        ..onUpdate = onDragUpdateCallback
        ..onEnd = ondragEndCallback;
    });

    gestures[ScaleGestureRecognizer] =
        GestureRecognizerFactoryWithHandlers<ScaleGestureRecognizer>(
            () => ScaleGestureRecognizer(), (ScaleGestureRecognizer instance) {
      instance
        ..onStart = onScaleStartCallback
        ..onUpdate = onScaleUpdateCallback
        ..onEnd = onScaleEndCallback;
    });

    return RawGestureDetector(
      gestures: gestures,
      child: child,
    );
  }
}
