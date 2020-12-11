import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:wallpaper_maker/utils.dart';

abstract class Selectable {
  Rect rect;
  Rect scaledRect;
  Path selectedPath;
  Path dottedSelectedPath;

  Paint mPaint;
  double tmpScaleX = 1.0;
  double tmpScaleY = 1.0;
  double tmpAngle = 0.0;
  Offset tmpOffset = Offset.zero;

  bool isSelected = false;

  Offset offset = Offset.zero;

  double rotRadians = 0.0;
  double scaleRadioX = 1.0;
  double scaleRadioY = 1.0;

  Map<String, dynamic> toJson() {
    return {
      'offsetX': offset.dx,
      'offsetY': offset.dy,
      'scaleRadioX': scaleRadioX,
      'scaleRadioY': scaleRadioY,
      'rotRadians': rotRadians,
    };
  }

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
  Offset topCtrlStart;
  Offset topCtrlEnd;
  Offset rightCtrlStart;
  Offset rightCtrlEnd;
  Offset bottomCtrlStart;
  Offset bottomCtrlEnd;

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
  Offset lastPosition;

  ///down 事件命中某个控制点
  bool isCtrling;

  ///down 时间命中selectable，但没命中控制点
  bool isMoving;

  ///todo
  Rect rightBottomControlRect;

  bool hitTestControl(Offset offset) {
    // if (leftControlRect.contains(offset)) {
    //   currentControlPoint = 0;
    //   return true;
    // }
    // if (topControlRect.contains(offset)) {
    //   currentControlPoint = 1;
    //   return true;
    // }
    // if (rightControlRect.contains(offset)) {
    //   currentControlPoint = 2;
    //   return true;
    // }
    // if (bottomControlRect.contains(offset)) {
    //   currentControlPoint = 3;
    //   return true;
    // }
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
    ..color = Colors.blue[200]
    ..strokeWidth = 2
    ..style = PaintingStyle.stroke;

  Paint _ctrlPaint = Paint()
    ..color = Colors.blue[400]
    ..strokeWidth = 5
    ..style = PaintingStyle.fill;

  bool hitTest(Offset offset) =>
      selectedPath != null ? selectedPath.contains(offset) : false;

  void drawSelected(Canvas canvas) {
    if (isSelected) {
      canvas.drawPath(toDottedLinePath(selectedPath), _selectedPaint);
      canvas.drawRect(tlControlRect.deflate(3), _ctrlPaint);
      canvas.drawRect(trControlRect.deflate(3), _ctrlPaint);
      canvas.drawRect(blControlRect.deflate(3), _ctrlPaint);
      canvas.drawRect(brControlRect.deflate(3), _ctrlPaint);
    }
  }

//Construct selected rect path.
  Path toPath(Rect rect, double rotAngle, double scaleX, [double scaleY]) {
    scaleY ??= scaleX;

    scaledRect = Rect.fromCenter(
        center: rect.center,
        width: rect.width * scaleX,
        height: rect.height * scaleY);
    rect = scaledRect.inflate(10);

    var a = atan((rect.center.dy - rect.topLeft.dy) /
        (rect.center.dx - rect.topLeft.dx)); //原始弧度
    var c = a + rotAngle; //旋转后弧度
    var r = (rect.center - rect.topLeft).distance; //半径长
    var newTLx = rect.center.dx - cos(c) * r;
    var newTLy = rect.center.dy - sin(c) * r;
    var osNewTL = Offset(newTLx, newTLy);

    var osNewTR = osNewTL + Offset.fromDirection(rotAngle, rect.width);
    var newTRx = osNewTR.dx;
    var newTRy = osNewTR.dy;

    var osNewBR =
        osNewTR + Offset.fromDirection(pi / 2 + rotAngle, rect.height);
    var newBRx = osNewBR.dx;
    var newBRy = osNewBR.dy;

    var osNewBL =
        osNewTL + Offset.fromDirection(pi / 2 + rotAngle, rect.height);
    var newBLx = osNewBL.dx;
    var newBLy = osNewBL.dy;

//CtlrLeft
    var leftCenterPoint = Offset((newTLx + newBLx) / 2, (newTLy + newBLy) / 2);
    var dis0 = (leftCenterPoint - Offset(newBLx, newBLy)).distance;
    var leftCtrlStartX = leftCenterPoint.dx -
        (leftCenterPoint.dx - newBLx) * controllerLength / dis0;
    var leftCtrlStartY = leftCenterPoint.dy +
        (leftCenterPoint.dy - newTLy) * controllerLength / dis0;

    leftCtrlStart = Offset(leftCtrlStartX, leftCtrlStartY);
    leftCtrlEnd = leftCenterPoint * 2 - leftCtrlStart;
    leftControlRect =
        Rect.fromCenter(center: leftCenterPoint, width: 20, height: 20);

//CtlrTop
    var topCenterPoint = Offset((newTLx + newTRx) / 2, (newTLy + newTRy) / 2);
    var dis1 = (topCenterPoint - Offset(newTLx, newTLy)).distance;
    var topCtrlStartX = topCenterPoint.dx -
        (topCenterPoint.dx - newTLx) * controllerLength / dis1;
    var topCtrlStartY = topCenterPoint.dy -
        (topCenterPoint.dy - newTLy) * controllerLength / dis1;

    topCtrlStart = Offset(topCtrlStartX, topCtrlStartY);
    topCtrlEnd = topCenterPoint * 2 - topCtrlStart;
    topControlRect =
        Rect.fromCenter(center: topCenterPoint, width: 20, height: 20);

//CtlrRight
    var rightCenterPoint = Offset((newTRx + newBRx) / 2, (newTRy + newBRy) / 2);
    var rightCtrlStartX = rightCenterPoint.dx +
        (newTRx - rightCenterPoint.dx) * controllerLength / dis0;
    var rightCtrlStartY = rightCenterPoint.dy -
        (rightCenterPoint.dy - newTRy) * controllerLength / dis0;

    rightCtrlStart = Offset(rightCtrlStartX, rightCtrlStartY);
    rightCtrlEnd = rightCenterPoint * 2 - rightCtrlStart;
    rightControlRect =
        Rect.fromCenter(center: rightCenterPoint, width: 20, height: 20);

//CtlrBottom
    var bottomCenterPoint =
        Offset((newBLx + newBRx) / 2, (newBLy + newBRy) / 2);
    var bottomCtrlStartX = bottomCenterPoint.dx -
        (bottomCenterPoint.dx - newBLx) * controllerLength / dis1;
    var bottomCtrlStartY = bottomCenterPoint.dy -
        (bottomCenterPoint.dy - newBLy) * controllerLength / dis1;

    bottomCtrlStart = Offset(bottomCtrlStartX, bottomCtrlStartY);
    bottomCtrlEnd = bottomCenterPoint * 2 - bottomCtrlStart;
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

  Path toDottedLinePath(Path path) {
    Path destPath = Path();
    double totalLength = 0.0;
    ui.PathMetric metric = path.computeMetrics().first;
    double i = 0;
    while (totalLength < metric.length) {
      destPath.addPath(metric.extractPath(i, i + 5), Offset.zero);
      i += 10;
      totalLength += 10;
    }
    return destPath;
  }

  void draw(Canvas canvas);

  void handleCtrlStart(Offset position) {
    tmpScaleX = scaleRadioX;
    tmpScaleY = scaleRadioY;
    tmpOffset = offset;
    lastPosition = position;
  }

  void handleCtrlUpdate(Offset localPosition) {
    int xPre = 1;
    int yPre = 1;

    int xPre2 = 1;
    int yPre2 = 1;

    if (currentControlPoint == 7) {
      xPre = 1;
      yPre = 1;

      xPre2 = 1;
      yPre2 = -1;
    }

    if (currentControlPoint == 4) {
      xPre = -1;
      yPre = -1;

      xPre2 = 1;
      yPre2 = -1;
    }

    if (currentControlPoint == 5) {
      xPre = 1;
      yPre = -1;

      yPre2 = -1;
      xPre2 = 1;
    }

    if (currentControlPoint == 6) {
      xPre = -1;
      yPre = 1;

      xPre2 = 1;
      yPre2 = -1;
    }

    var wScale = 1 +
        (localPosition - lastPosition).distance *
            cos((localPosition - lastPosition).direction - rotRadians) /
            (rect.width * tmpScaleX) *
            xPre;
    var hScale = 1 +
        (localPosition - lastPosition).distance *
            sin((localPosition - lastPosition).direction - rotRadians) /
            (rect.height * tmpScaleY) *
            yPre;

    scaleRadioX = tmpScaleX * wScale;
    scaleRadioY = tmpScaleY * hScale;

    var wOffset = (rect.width) * tmpScaleX * (scaleRadioX / tmpScaleX - 1) / 2;
    var hOffset = (rect.height) * tmpScaleY * (scaleRadioY / tmpScaleY - 1) / 2;
    offset = Offset(
          xPre * wOffset * cos(rotRadians) +
              yPre2 * yPre * hOffset * sin(rotRadians),
          yPre * hOffset * cos(rotRadians) +
              xPre2 * xPre * wOffset * sin(rotRadians),
        ) +
        tmpOffset;
  }

  void handleMoveStart(Offset position) {
    tmpOffset = offset;
    lastPosition = position;
  }

  void handleMoveUpdate(Offset position) {
    offset = tmpOffset + position - lastPosition;
  }

  void handleCtrlOrMoveEnd() {
    isMoving = false;
    isCtrling = false;
    currentControlPoint = -1;
  }
}

class SelectableTypo extends Selectable {
  String text;

  Color textColor;

  TextSpan _ts;

  //字体
  String fontFamily;

  //字重
  int textWeight;

  //最大宽度
  double _maxWidth;

  double fontSize = 0;

  set maxWidth(double value) {
    if (value > 10) {
      _maxWidth = value;
    }
  }

  double get maxWidth => _maxWidth;

  SelectableTypo({this.text, Offset mOffset, double maxWidth}) {
    offset = mOffset;
    this.maxWidth = maxWidth;
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'textColor': textColor.value,
      'fontFamily': fontFamily,
      'textWeight': textWeight,
      'maxWidth': maxWidth,
      'fontSize': fontSize
    }..addAll(super.toJson());
  }

  factory SelectableTypo.fromJson(Map<String, dynamic> map) {
    return SelectableTypo(maxWidth: map['maxWidth'])
      ..text = map['text']
      ..textColor = Color(map['textColor'])
      ..fontFamily = map['fontFamily']
      ..textWeight = map['textWeight']
      ..fontSize = map['fontSize']
      ..offset = Offset(map['offsetX'], map['offsetY'])
      ..scaleRadioX = map['scaleRadioX']
      ..scaleRadioY = map['scaleRadioY']
      ..rotRadians = map['rotRadians'];
  }

  @override
  void draw(Canvas canvas) {
    _ts = TextSpan(
      text: text,
      style: TextStyle(
          // height: 0.8,
          color: textColor,
          //TODO NI.
          fontSize: 30 + 5 * fontSize,
          fontFamily: fontFamily,
          fontWeight: FontWeight.values[textWeight]),
    );
    // totalOffset = offset + totalOffset;
    TextPainter tp = TextPainter(
      text: _ts,
      textDirection: TextDirection.ltr,
    );
    tp.layout(maxWidth: maxWidth);
    rect = Rect.fromCenter(center: offset, width: tp.width, height: tp.height);
    selectedPath = toPath(rect, rotRadians, scaleRadioX, scaleRadioY);

    canvas.save();
    canvas.translate(rect.center.dx, rect.center.dy);
    canvas.rotate(rotRadians);
    canvas.scale(scaleRadioX, scaleRadioY);
    canvas.translate(-rect.center.dx, -rect.center.dy);
    tp.paint(canvas, offset - Offset(tp.size.width / 2, tp.size.height / 2));
    canvas.restore();
  }

  @override
  void drawSelected(ui.Canvas canvas) {
    super.drawSelected(canvas);
    canvas.drawLine(rightCtrlStart, rightCtrlEnd, _ctrlPaint);
  }

  @override
  bool hitTestControl(ui.Offset offset) {
    if (rightControlRect.contains(offset)) {
      currentControlPoint = 8;
      return true;
    }
    return super.hitTestControl(offset);
  }

  @override
  void handleCtrlUpdate(ui.Offset position) {
    if (currentControlPoint == 8) {
      maxWidth = (position.dx - rect.center.dx) * 2;
    } else {
      super.handleCtrlUpdate(position);
    }
  }
}

class SelectableImage extends Selectable {
  ui.Image img;
  // Offset initPosition;
  Rect clipRect;
  double width;

  //The name to find image in dir.
  String name;

  //frame
  bool hasFrame;
  double frameWidth;
  Color frameColor;

  SelectableImage(
      {this.img, Offset mOffset, this.width, this.frameColor, this.frameWidth})
      : clipRect = Rect.fromLTRB(
            0.0, 0.0, img.width.toDouble(), img.height.toDouble()) {
    mPaint = Paint();
    offset = mOffset;
    hasFrame = false;
  }

  SelectableImage.empty() {
    mPaint = Paint();
  }

  Map<String, dynamic> toJson() {
    String name = DateTime.now().millisecondsSinceEpoch.toString();
    saveImgObject(img, name);
    return {
      'imgName': name,
      'clipRectL': clipRect.left,
      'clipRectT': clipRect.top,
      'clipRectR': clipRect.right,
      'clipRectB': clipRect.bottom,
      'width': width,
    }..addAll(super.toJson());
  }

  factory SelectableImage.fromJson(Map<String, dynamic> map) {
    return SelectableImage.empty()
      ..clipRect = Rect.fromLTRB(map['clipRectL'], map['clipRectT'],
          map['clipRectR'], map['clipRectB'])
      ..offset = Offset(map['offsetX'], map['offsetY'])
      ..width = map['width'];
  }

  @override
  void draw(Canvas canvas) {
    var clipRatio = clipRect.height / clipRect.width;

    rect = Rect.fromCenter(
        center: offset, width: width - 40, height: (width - 40) * clipRatio);

    canvas.save();
    canvas.translate(rect.center.dx, rect.center.dy);
    canvas.rotate(rotRadians);
    canvas.scale(scaleRadioX, scaleRadioY);
    canvas.translate(-rect.center.dx, -rect.center.dy);

    if (hasFrame) {
      canvas.drawRect(
          rect.inflate(frameWidth), Paint()..color = frameColor); //Draw frame.
    }

    canvas.drawImageRect(img, clipRect, rect, mPaint);
    canvas.restore();

    if (hasFrame) rect = rect.inflate(frameWidth);

    selectedPath = toPath(rect, rotRadians, scaleRadioX, scaleRadioY);
  }
}

class SelectableShape extends Selectable {
  int shapeType;

  Offset startPoint;
  Offset endPoint;

//startPoint and endPoint will be converted to topLeftPoint and bottomRightPoint， subsequent operation will be easier.
  Offset topLeftPoint;
  Offset bottomRightPoint;

  Offset tlOffset;
  Offset brOffset;
  Offset tmpTLOffset;
  Offset tmpBROffset;

  bool fill;
  Paint fillPaint;

  var tlX, tlY, brX, brY;

  SelectableShape({this.startPoint, this.shapeType, Paint paint}) {
    endPoint = startPoint;
    tlOffset = Offset.zero;
    brOffset = Offset.zero;
    tmpTLOffset = Offset.zero;
    tmpTLOffset = Offset.zero;

    mPaint = paint;
    fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.transparent;
  }

  Map<String, dynamic> toJson() {
    return {
      'shapeType': shapeType,
      'startPointX': startPoint.dx,
      'startPointY': startPoint.dy,
      'endPointX': endPoint.dx,
      'endPointY': endPoint.dy,
      'tlOffsetX': tlOffset.dx,
      'tlOffsetY': tlOffset.dy,
      'brOffsetX': brOffset.dx,
      'brOffsetY': brOffset.dy,
      'shapeWidth': mPaint.strokeWidth,
      'fill': fill,
      'fillColor': fillPaint.color.value,
      'color': mPaint.color.value,
      'strokeWidth': mPaint.strokeWidth
    }..addAll(super.toJson());
  }

  factory SelectableShape.fromJson(Map<String, dynamic> map) {
    var fillPaint = Paint()..color = Color(map['fillColor']);
    return SelectableShape(
        startPoint: Offset(map['startPointX'], map['startPointY']),
        shapeType: map['shapeType'],
        paint: Paint())
      ..endPoint = Offset(map['endPointX'], map['endPointY'])
      ..tlOffset = Offset(map['tlOffsetX'], map['tlOffsetY'])
      ..brOffset = Offset(map['brOffsetX'], map['brOffsetY'])
      ..fill = map['fill']
      ..fillPaint = fillPaint
      ..scaleRadioX = map['scaleRadioX']
      ..scaleRadioY = map['scaleRadioY'];
  }

  @override
  void draw(Canvas canvas) {
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

    rect =
        Rect.fromPoints(topLeftPoint + tlOffset, bottomRightPoint + brOffset);
    selectedPath = toPath(rect, rotRadians, scaleRadioX, scaleRadioY);
    canvas.save();
    canvas.translate(rect.center.dx, rect.center.dy);
    canvas.rotate(rotRadians);
    canvas.scale(scaleRadioX, scaleRadioY);
    canvas.translate(-rect.center.dx, -rect.center.dy);

    switch (shapeType) {
      case 0:
        if (startPoint.dx < endPoint.dx && startPoint.dy < endPoint.dy) {
          canvas.drawLine(startPoint + tlOffset, endPoint + brOffset, mPaint);
        }
        if (startPoint.dx < endPoint.dx && startPoint.dy > endPoint.dy) {
          canvas.drawLine(startPoint + Offset(tlOffset.dx, brOffset.dy),
              endPoint + Offset(brOffset.dx, tlOffset.dy), mPaint);
        }
        if (startPoint.dx > endPoint.dx && startPoint.dy > endPoint.dy) {
          canvas.drawLine(startPoint + brOffset, endPoint + tlOffset, mPaint);
        }
        if (startPoint.dx > endPoint.dx && startPoint.dy < endPoint.dy) {
          canvas.drawLine(startPoint + Offset(brOffset.dx, tlOffset.dy),
              endPoint + Offset(tlOffset.dx, brOffset.dy), mPaint);
        }
        break;
      case 1:
        canvas.drawRect(rect, mPaint);
        canvas.drawRect(rect.deflate(mPaint.strokeWidth / 2), fillPaint);
        break;
      case 2:
        canvas.drawOval(rect, mPaint);
        canvas.drawOval(rect.deflate(mPaint.strokeWidth / 2), fillPaint);
        break;
      default:
    }

    canvas.restore();
  }

  @override
  void handleMoveStart(ui.Offset position) {
    super.handleMoveStart(position);
    tmpTLOffset = tlOffset;
    tmpBROffset = brOffset;
  }

  @override
  void handleMoveUpdate(ui.Offset position) {
    tlOffset = tmpTLOffset + position - lastPosition;
    brOffset = tmpBROffset + position - lastPosition;
  }

  @override
  void handleCtrlStart(ui.Offset position) {
    handleMoveStart(position);
  }

  @override
  void handleCtrlUpdate(ui.Offset position) {
    switch (currentControlPoint) {
      case 4:
        tlOffset = tmpTLOffset + position - lastPosition;
        break;
      case 5:
        tlOffset = tmpTLOffset + Offset(0.0, position.dy - lastPosition.dy);
        brOffset = tmpBROffset + Offset(position.dx - lastPosition.dx, 0.0);
        break;
      case 6:
        tlOffset = tmpTLOffset + Offset(position.dx - lastPosition.dx, 0.0);
        brOffset = tmpBROffset + Offset(0.0, position.dy - lastPosition.dy);
        break;
      case 7:
        brOffset = tmpBROffset + position - lastPosition;
        break;
      default:
        break;
    }
  }
}

class SelectablePath extends Selectable {
  Path path;

  List<MyPoint> points;

  SelectablePath(Paint paint) {
    mPaint = paint;
    path = Path();
    points = [];
  }

  moveTo(double dx, double dy) {
    path.moveTo(dx, dy);
    points.add(MyPoint(dx, dy));
  }

  lineTo(double dx, double dy) {
    path.lineTo(dx, dy);
    points.add(MyPoint(dx, dy));
  }

  Map<String, dynamic> toJson() {
    return {
      'color': mPaint.color.value,
      'strokeWidth': mPaint.strokeWidth,
      'points': points,
      'offsetX': offset.dx,
      'offsetY': offset.dy
    }..addAll(super.toJson());
  }

  factory SelectablePath.fromJson(Map<String, dynamic> map) {
    Path path = Path();
    List<MyPoint> myPoints = [];
    List<Map> points = (map['points'] as List).cast();
    for (var i = 0; i < points.length; i++) {
      if (i == 0) {
        path.moveTo(
            MyPoint.fromJson(points[i]).x, MyPoint.fromJson(points[i]).y);
        myPoints.add(MyPoint.fromJson(points[i]));
      } else {
        path.lineTo(
            MyPoint.fromJson(points[i]).x, MyPoint.fromJson(points[i]).y);
        myPoints.add(MyPoint.fromJson(points[i]));
      }
    }
    return SelectablePath(Paint())
      ..path = path
      ..points = myPoints
      ..offset = Offset(map['offsetX'], map['offsetY'])
      ..scaleRadioX = map['scaleRadioX']
      ..scaleRadioY = map['scaleRadioY']
      ..rotRadians = map['rotRadians'];
  }

  @override
  void draw(Canvas canvas) {
    canvas.save();
    canvas.translate(path.getBounds().center.dx + offset.dx,
        path.getBounds().center.dy + offset.dy);
    canvas.rotate(rotRadians);
    canvas.scale(scaleRadioX, scaleRadioY);
    canvas.translate(-path.getBounds().center.dx, -path.getBounds().center.dy);
    canvas.drawPath(path, mPaint);
    canvas.restore();
    rect = path.getBounds();
    rect = rect.translate(offset.dx, offset.dy);
    selectedPath = toPath(rect, rotRadians, scaleRadioX, scaleRadioY);
  }
}

class MyPoint {
  MyPoint(this.x, this.y);

  double x;
  double y;

  Map<String, dynamic> toJson() {
    return {'x': x, 'y': y};
  }

  factory MyPoint.fromJson(Map<String, dynamic> map) {
    return MyPoint(map['x'], map['y']);
  }
}

class SelectableImageFile {
  SelectableImageFile({this.imgPath, this.date, this.isSelected = false}) {
    jsonPath = getJsonPath(imgPath);
  }

  bool isSelected;

  String imgPath;
  String jsonPath;

  DateTime date;

  Future delete() async {
    String content = await File(jsonPath).readAsString();
    if (content.contains('imgName')) {
      List<Map<String, dynamic>> list = (jsonDecode(content) as List).cast();
      list.forEach((element) {
        element.forEach((key, value) {
          if (key.contains('SelectableImage')) {
            var imgName = value['imgName'];
            String imgPath = getImgPath(imgName);
            File(imgPath).delete();
          }
        });
      });
    }
    await File(imgPath).delete();
    await File(jsonPath).delete();
  }

  String getJsonPath(String imgPath) {
    var list = imgPath.split('/');
    String name = list.last.split('.').first;
    list.removeLast();
    return list.join('/') + '/jsons/' + name + '.json';
  }

  String getImgPath(String imgName) {
    var list = imgPath.split('/');
    list.removeLast();
    return list.join('/') + '/jsons/' + imgName + '.png';
  }
}
