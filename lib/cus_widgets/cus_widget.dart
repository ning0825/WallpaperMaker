import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

enum MessageBoxDirection { left, right, top, bottom }

///A rectangular border with a triangle indicator at bottom.
///
///@param position: indicator
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

typedef OnColorPick = void Function(Color color);

class PaletteWidget extends LeafRenderObjectWidget {
  PaletteWidget({this.onColorPick});

  final OnColorPick onColorPick;
  @override
  PaletteRenderBox createRenderObject(BuildContext context) =>
      PaletteRenderBox(onColorPick);

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {
    (renderObject as PaletteRenderBox).onColorPick = this.onColorPick;
  }
}

class PaletteRenderBox extends RenderBox {
  PaletteRenderBox(this.onColorPick);

  OnColorPick onColorPick;

  double pieceWidth;
  double pieceHeight;

  double ratio = window.devicePixelRatio;

  Size pieceSize;

  var colorlist = [
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
    int row = (event.localPosition.dy / (size.width / 10)).floor();
    int col = (event.localPosition.dx / (size.width / 12)).floor();

    //第一行是黑白
    if (row == 0) {
      onColorPick(Color.fromARGB(
          255, 23 * (11 - col), 23 * (11 - col), 23 * (11 - col)));
    } else {
      onColorPick(colorlist[col][(10 - row) * 100]);
    }
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
        context.canvas.drawRect(
            Offset(offset.dx + pieceWidth * j, offset.dy + pieceHeight * i) &
                pieceSize,
            Paint()..color = colorlist[j][100 * (10 - i)]);
      }
    }
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
