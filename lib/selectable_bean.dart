import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart' hide Image;
import 'package:vector_math/vector_math_64.dart' hide Colors;

abstract class Selectable {
  Rect rect;
  Path selectedPath;

  Paint mPaint;
  double tmpScale = 1.0;
  double tmpAngle = 0.0;

  bool isSelected = false;
  bool isRot = false;
  bool isTrans = false;
  bool isScale = false;

  Offset offset = Offset(0, 0);
  double rotRadians = 0.0;
  double scaleRadio = 1.0;

  double lastScale = 1.0;
  double lastAngle = 0.0;

  Offset ctrlTopStartPoint;
  Offset ctrlTopEndPoint;

//------------------Draw Controller------------------
  var controllerLength = 10;

  Rect leftControlRect;
  Rect topControlRect;
  Rect rightControlRect;
  Rect bottomControlRect;

  ///todo
  Rect rightBottomControlRect;

  /// Return which controller user has touched.
  /// 0: left
  /// 1: top
  /// 2: right
  /// 3: bottom
  /// -1: none
  int hitTestControl(Offset offset) {
    if (leftControlRect.contains(offset)) return 0;
    if (topControlRect.contains(offset)) return 1;
    if (rightControlRect.contains(offset)) return 2;
    if (bottomControlRect.contains(offset)) return 3;
    return -1;
  }

  bool hitTest(Offset offset) => selectedPath.contains(offset);

  void draw(Canvas canvas);

  void drawSelected(Canvas canvas) {
    rect = Rect.fromCenter(
        center: rect.center,
        width: rect.width * scaleRadio,
        height: rect.height * scaleRadio);

    if (isSelected) {
      canvas.drawPath(
          selectedPath,
          Paint()
            ..color = Colors.grey
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke);
      canvas.drawLine(
          ctrlTopStartPoint,
          ctrlTopEndPoint,
          Paint()
            ..color = Colors.grey
            ..strokeWidth = 4
            ..style = PaintingStyle.stroke);
    }
  }

//Construct selected rect path.
  Path toPath(Rect rect, double rotAngle, double scaleX, [double scaleY]) {
    scaleY ??= scaleX;
    rect = Rect.fromCenter(
        center: rect.center,
        width: rect.width * scaleX,
        height: rect.height * scaleY);

    ///TODO: Code optimization
    var a = atan((rect.center.dy - rect.topLeft.dy) /
        (rect.center.dx - rect.topLeft.dx)); //原始弧度
    var c = a + rotAngle; //旋转后弧度
    var r = (rect.center - rect.topLeft).distance; //半径长
    var newTLx = rect.center.dx - cos(c) * r;
    var newTLy = rect.center.dy - sin(c) * r;

    var a1 = atan((rect.center.dy - rect.topRight.dy) /
        -(rect.center.dx - rect.topRight.dx));
    var c1 = a1 - rotAngle;
    var newTRx = rect.center.dx + cos(c1) * r;
    var newTRy = rect.center.dy - sin(c1) * r;

    var a2 = atan((rect.center.dy - rect.bottomRight.dy) /
        (rect.center.dx - rect.bottomRight.dx));
    var c2 = a2 + rotAngle;
    var newBRx = rect.center.dx + cos(c2) * r;
    var newBRy = rect.center.dy + sin(c2) * r;

    var a3 = atan(-(rect.center.dy - rect.bottomLeft.dy) /
        (rect.center.dx - rect.bottomLeft.dx));
    var c3 = a3 - rotAngle;
    var newBLx = rect.center.dx - cos(c3) * r;
    var newBLy = rect.center.dy + sin(c3) * r;

    var topCenterPoint = Offset((newTLx + newTRx) / 2, (newTLy + newTRy) / 2);

    var ctlrTopStartX = topCenterPoint.dx -
        (topCenterPoint.dx - newTLx) * controllerLength / (rect.width / 2);
    var ctlrTopStartY = topCenterPoint.dy -
        (topCenterPoint.dy - newTLy) * controllerLength / (rect.width / 2);

    var ctlrTopEndX = topCenterPoint.dx +
        (topCenterPoint.dx - newTLx) * controllerLength / (rect.width / 2);
    var ctlrTopEndY = topCenterPoint.dy +
        (topCenterPoint.dy - newTLy) * controllerLength / (rect.width / 2);

    ctrlTopStartPoint = Offset(ctlrTopStartX, ctlrTopStartY);
    ctrlTopEndPoint = Offset(ctlrTopEndX, ctlrTopEndY);

    return Path()
      ..moveTo(newTLx, newTLy)
      ..lineTo(newTRx, newTRy)
      ..lineTo(newBRx, newBRy)
      ..lineTo(newBLx, newBLy)
      ..close();
  }
}

class SelectableText extends Selectable {
  String text;

  Color textColor;

  TextSpan ts;

  Offset totalOffset;

  String fontFamily;

  int textWeight;

  SelectableText({this.text, this.totalOffset}) {
    textWeight = 3;
  }

  @override
  void draw(Canvas canvas) {
    ts = TextSpan(
      text: text,
      style: TextStyle(
          color: textColor,
          fontSize: 50,
          fontFamily: fontFamily ?? null,
          fontWeight: FontWeight.values[textWeight]),
    );
    totalOffset = offset * 2 + totalOffset;
    TextPainter tp = TextPainter(text: ts, textDirection: TextDirection.ltr,);
    tp.layout(minWidth: 50);
    rect = Rect.fromCenter(
        center: totalOffset, width: tp.width, height: tp.height);
    selectedPath = toPath(rect, rotRadians, scaleRadio, scaleRadio);

    canvas.save();
    canvas.translate(rect.center.dx, rect.center.dy);
    canvas.rotate(rotRadians);
    canvas.scale(scaleRadio);
    canvas.translate(-rect.center.dx, -rect.center.dy);
    tp.paint(
        canvas, totalOffset - Offset(tp.size.width / 2, tp.size.height / 2));
    canvas.restore();
  }
}

class SelectableImage extends Selectable {
  Image img;

  Offset totalOffset;

  SelectableImage(this.img, this.totalOffset);

  @override
  void draw(Canvas canvas) {
    totalOffset = offset * 2 + totalOffset;
    rect = Rect.fromCenter(
        center: totalOffset,
        width: img.width.toDouble(),
        height: img.height.toDouble());
    selectedPath = toPath(rect, rotRadians, scaleRadio, scaleRadio);
    canvas.save();
    canvas.translate(rect.center.dx, rect.center.dy);
    canvas.rotate(rotRadians);
    canvas.scale(scaleRadio);
    canvas.translate(-rect.center.dx, -rect.center.dy);
    //TODO: Too small rect will cause pixel compression.
    paintImage(canvas: canvas, rect: rect, image: img);
    canvas.restore();
  }
}

class SelectableShape extends Selectable {
  // Rect rect;

  int shapeType;

  Offset startPoint;
  Offset endPoint;

  Offset totalOffset;

  bool fill;
  Color fillColor;
  Paint fillPaint;

  SelectableShape(this.startPoint, this.shapeType, Paint paint)
      : totalOffset = Offset.zero, endPoint = startPoint{
    fill = false;
    mPaint = paint;
    fillColor = mPaint.color;
    fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = fillColor;
  }

  @override
  void draw(Canvas canvas) {
    totalOffset = offset + totalOffset;

    print('startPoint: $startPoint');
    print('totalOffset: $totalOffset');
    print('endPOint: $endPoint');
    rect = Rect.fromPoints(
            startPoint + totalOffset * 2, endPoint + totalOffset * 2)
        .inflate(10);
    selectedPath = toPath(rect, rotRadians, scaleRadio, scaleRadio);
    canvas.save();
    canvas.translate(rect.center.dx, rect.center.dy);
    canvas.rotate(rotRadians);
    canvas.scale(scaleRadio);
    canvas.translate(-rect.center.dx, -rect.center.dy);

    switch (shapeType) {
      case 0:
        canvas.drawLine(
            startPoint + totalOffset * 2, endPoint + totalOffset * 2, mPaint);
        break;
      case 1:
        canvas.drawRect(rect.deflate(10), mPaint);
        if (fill) {
          canvas.drawRect(rect.deflate(10 + mPaint.strokeWidth / 2), fillPaint);
        }
        break;
      case 2:
        canvas.drawOval(rect.deflate(10), mPaint);
        if (fill) {
          canvas.drawOval(rect.deflate(10 + mPaint.strokeWidth / 2), fillPaint);
        }
        break;
      default:
    }

    canvas.restore();
  }
}

class SelectablePath extends Selectable {
  // Paint mPaint;
  Path path;

  SelectablePath(this.path, Paint paint) {
    mPaint = paint;
  }

  @override
  void draw(Canvas canvas) {
    //TODO: This implementation is more concise and easy-handle.But the path did not behave as expected.
    // path = path.transform(Matrix4.compose(
    //         Vector3.zero(),
    //         Quaternion.fromRotation(
    //             Matrix3.identity()..setRotationZ(rotRadians)),
    //         Vector3.all(1.0))
    //     .storage);
    // var m = Matrix4.identity()..rotateZ(rotRadians * 3.1415927 / 180);
    // path = path.transform(m.storage);
    // canvas.drawPath(path, mPaint);

    ///TODO: These code can produce interesting effect, try later.
    // Matrix4 m = Matrix4.identity()..setEntry(3, 2, 0.1);
    // m.rotateX(scaleRadio);
    // path = path.transform(m.storage);
    // canvas.drawPath(path, mPaint);

    //TODO: why need double offset to match the fingner moving.
    path = path.transform(
        Matrix4.translationValues(offset.dx * 2, offset.dy * 2, 0).storage);

    canvas.save();
    canvas.translate(path.getBounds().center.dx, path.getBounds().center.dy);
    canvas.rotate(rotRadians);

    canvas.scale(scaleRadio);
    canvas.translate(-path.getBounds().center.dx, -path.getBounds().center.dy);
    canvas.drawPath(path, mPaint);
    canvas.restore();
    rect = path.getBounds();
    selectedPath = toPath(rect, rotRadians, scaleRadio, scaleRadio);
  }
}
