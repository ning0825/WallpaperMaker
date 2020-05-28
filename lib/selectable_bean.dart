import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart' hide Image;
import 'package:vector_math/vector_math_64.dart' hide Colors;

abstract class Selectable {
  Rect rect;
  Path selectedPath;

  Paint mPaint;
  double tmpScaleX = 1.0;
  double tmpScaleY = 1.0;
  double tmpAngle = 0.0;

  bool isSelected = false;
  bool isRot = false;
  bool isTrans = false;

  Offset offset = Offset(0, 0);
  double rotRadians = 0.0;
  double scaleRadioX = 1.0;
  double scaleRadioY = 1.0;

  double lastScaleX = 1.0;
  double lastScaleY = 1.0;
  double lastAngle = 0.0;

//------------------Draw Controller------------------
  var controllerLength = 10;

  Rect leftControlRect;
  Rect topControlRect;
  Rect rightControlRect;
  Rect bottomControlRect;
  Rect tlControlRect;
  Rect trControlRect;
  Rect blControlRect;
  Rect brControlRect;

  Offset leftCtrlStart;
  Offset leftCtrlEnd;

  /// Return which controller user has touched.
  /// 0: left
  /// 1: top
  /// 2: right
  /// 3: bottom
  /// 4: tl
  /// 5: tr
  /// 6: bl
  /// 7: br
  /// -1: none
  int currentControlPoint;

  ///down 事件命中某个控制点
  bool isCtrling;

  ///todo
  Rect rightBottomControlRect;

  Offset testPoint = Offset.zero;

  bool hitTestControl(Offset offset) {
    if (leftControlRect.contains(offset)) {
      currentControlPoint = 0;
      return true;
    }
    if (topControlRect.contains(offset)) {
      currentControlPoint = 1;
      return true;
    }
    if (rightControlRect.contains(offset)) {
      currentControlPoint = 2;
      return true;
    }
    if (bottomControlRect.contains(offset)) {
      currentControlPoint = 3;
      return true;
    }
    if (tlControlRect.contains(offset)) {
      currentControlPoint = 4;
      return true;
    }
    if (trControlRect.contains(offset)) {
      currentControlPoint = 5;
      return true;
    }
    if (blControlRect.contains(offset)) {
      currentControlPoint = 6;
      return true;
    }
    if (brControlRect.contains(offset)) {
      currentControlPoint = 7;
      return true;
    }
    return false;
  }

  Paint _selectedPaint = Paint()
    ..color = Colors.black
    ..strokeWidth = 2
    ..style = PaintingStyle.stroke;

  Paint _ctrlPaint = Paint()
    ..color = Colors.black
    ..strokeWidth = 5
    ..style = PaintingStyle.stroke;

  bool hitTest(Offset offset) => selectedPath.contains(offset);

  void draw(Canvas canvas);

  void drawSelected(Canvas canvas) {
    rect = Rect.fromCenter(
        center: rect.center,
        width: rect.width * scaleRadioX,
        height: rect.height * scaleRadioY);

    if (isSelected) {
      canvas.drawPath(selectedPath, _selectedPaint);
      canvas.drawRect(
          Rect.fromCenter(center: leftCtrlStart, width: 10, height: 10),
          _ctrlPaint);
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

//CtlrLeft
    var leftCenterPoint = Offset((newTLx + newBLx) / 2, (newTLy + newBLy) / 2);
    var dis0 = (leftCenterPoint - Offset(newBLx, newBLy)).distance;
    var leftCtrlStartX =
        leftCenterPoint.dx - (leftCenterPoint.dx - newBLx) * 5 / dis0;
    var dis01 = (leftCenterPoint - Offset(newTLx, newTLy)).distance;
    var leftCtrlStartY =
        leftCenterPoint.dy + (leftCenterPoint.dy - newTLy) * 5 / dis01;

    leftCtrlStart = Offset(leftCtrlStartX, leftCtrlStartY);

//CtlrTop
    var topCenterPoint = Offset((newTLx + newTRx) / 2, (newTLy + newTRy) / 2);
    topControlRect =
        Rect.fromCenter(center: topCenterPoint, width: 20, height: 20);

//CtlrRight
    var rightCenterPoint = Offset((newTRx + newBRx) / 2, (newTRy + newBRy) / 2);
    rightControlRect =
        Rect.fromCenter(center: rightCenterPoint, width: 20, height: 20);

//CtlrBottom
    var bottomCenterPoint =
        Offset((newBLx + newBRx) / 2, (newBLy + newBRy) / 2);
    bottomControlRect =
        Rect.fromCenter(center: bottomCenterPoint, width: 20, height: 20);

    tlControlRect =
        Rect.fromCenter(center: Offset(newTLx, newTLy), width: 20, height: 20);
    trControlRect =
        Rect.fromCenter(center: Offset(newTRx, newTRy), width: 20, height: 20);
    blControlRect =
        Rect.fromCenter(center: Offset(newBLx, newBLy), width: 20, height: 20);
    brControlRect =
        Rect.fromCenter(center: Offset(newBRx, newBRy), width: 20, height: 20);

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

  //控制移动
  Offset totalOffset;

  //字体
  String fontFamily;

  //字重
  int textWeight;

  //最大宽度
  double _maxWidth = 100;

  set maxWidth(double value) {
    if (value > 10) {
      _maxWidth = value;
    }
  }

  double get maxWidth => _maxWidth;

  SelectableText({this.text, this.totalOffset});

  @override
  void draw(Canvas canvas) {
    ts = TextSpan(
      text: text,
      style: TextStyle(
          color: textColor,
          fontSize: 50,
          fontFamily: fontFamily,
          fontWeight: FontWeight.values[textWeight]),
    );
    totalOffset = offset * 2 + totalOffset;
    TextPainter tp = TextPainter(
      text: ts,
      textDirection: TextDirection.ltr,
    );
    tp.layout(maxWidth: maxWidth);
    rect = Rect.fromCenter(
        center: totalOffset, width: tp.width, height: tp.height);
    selectedPath = toPath(rect, rotRadians, scaleRadioX, scaleRadioY);

    canvas.save();
    canvas.translate(rect.center.dx, rect.center.dy);
    canvas.rotate(rotRadians);
    canvas.scale(scaleRadioX, scaleRadioY);
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
    selectedPath = toPath(rect, rotRadians, scaleRadioX, scaleRadioY);
    canvas.save();
    canvas.translate(rect.center.dx, rect.center.dy);
    canvas.rotate(rotRadians);
    canvas.scale(scaleRadioX, scaleRadioY);
    canvas.translate(-rect.center.dx, -rect.center.dy);
    //TODO: Too small rect will cause pixel compression.
    paintImage(canvas: canvas, rect: rect, image: img);
    canvas.restore();
  }
}

class SelectableShape extends Selectable {
  int shapeType;

  Offset startPoint;
  Offset endPoint;

//绘制时的startPoint和endPoint在draw中转换成tlpoint和brpoint
  Offset topLeftPoint;
  Offset bottomRightPoint;

  Offset tlOffset;
  Offset brOffset;

  Offset totalTLOffset;
  Offset totalBROffset;

  bool fill;
  Paint fillPaint;

  SelectableShape(this.startPoint, this.shapeType, Paint paint)
      : endPoint = startPoint,
        totalTLOffset = Offset.zero,
        totalBROffset = Offset.zero,
        tlOffset = Offset.zero,
        brOffset = Offset.zero {
    fill = false;
    mPaint = paint;
    fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = mPaint.color;
  }

  @override
  void drawSelected(Canvas canvas) {
    super.drawSelected(canvas);
  }

  @override
  void draw(Canvas canvas) {
    var tlX, tlY, brX, brY;
    if (startPoint.dx > endPoint.dx) {
      tlX = endPoint.dx;
      brX = startPoint.dx;
    } else {
      tlX = startPoint.dx;
      brX = endPoint.dx;
    }

    if (startPoint.dy > endPoint.dy) {
      tlY = endPoint.dy;
      brY = startPoint.dy;
    } else {
      tlY = startPoint.dy;
      brY = endPoint.dy;
    }

    topLeftPoint = Offset(tlX, tlY);
    bottomRightPoint = Offset(brX, brY);

    totalTLOffset = totalTLOffset + tlOffset;
    totalBROffset = totalBROffset + brOffset;

    rect = Rect.fromPoints(
            topLeftPoint + totalTLOffset, bottomRightPoint + totalBROffset)
        .inflate(10);
    selectedPath = toPath(rect, rotRadians, scaleRadioX, scaleRadioY);
    canvas.save();
    canvas.translate(rect.center.dx, rect.center.dy);
    canvas.rotate(rotRadians);
    canvas.scale(scaleRadioX, scaleRadioY);
    canvas.translate(-rect.center.dx, -rect.center.dy);

    switch (shapeType) {
      case 0:
        canvas.drawLine(topLeftPoint + totalTLOffset,
            bottomRightPoint + totalBROffset, mPaint);
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
    canvas.scale(scaleRadioX, scaleRadioY);
    canvas.translate(-path.getBounds().center.dx, -path.getBounds().center.dy);
    canvas.drawPath(path, mPaint);
    canvas.restore();
    rect = path.getBounds();
    selectedPath = toPath(rect, rotRadians, scaleRadioX, scaleRadioY);
  }
}
