import 'dart:ui';

import 'package:flutter/material.dart' hide Image;

class ClipRoute extends StatefulWidget {
  ClipRoute(this.clipImageBean);

  final ClipImageBean clipImageBean;

  @override
  _ClipRouteState createState() => _ClipRouteState();
}

class _ClipRouteState extends State<ClipRoute> {
  //the key of painter to get size.
  GlobalKey key;

  ClipImageBean clipImageBean;

  /// size to draw image.
  Size size;

  double padding = 10.0;

  Offset downPosition;
  double tmpClip1;
  double tmpClip2;
  double tmpClip3;
  double tmpClip4;

  Rect finalRect;

  @override
  void initState() {
    super.initState();

    // _loadImage('assetPath');
    clipImageBean = widget.clipImageBean;

    key = GlobalKey();
  }

  // Future<void> _loadImage(String assetPath) async {
  //   ByteData byteData = await rootBundle.load('assets/icons/img3.jpg');
  //   image = await decodeImageFromList(Uint8List.view(byteData.buffer));
  //   clipImageBean = ClipImageBean(image);
  //   size = Size(
  //       MediaQuery.of(context).size.width - padding * 2,
  //       MediaQuery.of(context).size.width *
  //               clipImageBean.clipRect.height /
  //               clipImageBean.clipRect.width -
  //           padding * 2);
  //   setState(() {});
  // }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    size = Size(
        MediaQuery.of(context).size.width - padding * 2,
        (MediaQuery.of(context).size.width - padding * 2) *
            clipImageBean.image.height /
            clipImageBean.image.width);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            child: Center(
              child: Container(
                padding: EdgeInsets.all(padding),
                child: RepaintBoundary(
                  key: key,
                  child: GestureDetector(
                    onPanDown: (details) {
                      clipImageBean.currentCtrl =
                          clipImageBean.hitTestControl(details.localPosition);
                      downPosition = details.localPosition;

                      switch (clipImageBean.currentCtrl) {
                        case 0:
                          tmpClip1 = clipImageBean.topClip;
                          tmpClip2 = clipImageBean.leftClip;
                          break;
                        case 1:
                          tmpClip1 = clipImageBean.topClip;
                          tmpClip2 = clipImageBean.rightClip;
                          break;
                        case 2:
                          tmpClip1 = clipImageBean.bottomClip;
                          tmpClip2 = clipImageBean.leftClip;
                          break;
                        case 3:
                          tmpClip1 = clipImageBean.bottomClip;
                          tmpClip2 = clipImageBean.rightClip;
                          break;
                        case 4:
                          tmpClip1 = clipImageBean.leftClip;
                          tmpClip2 = clipImageBean.topClip;
                          tmpClip3 = clipImageBean.rightClip;
                          tmpClip4 = clipImageBean.bottomClip;
                          break;
                        default:
                      }
                    },
                    onPanUpdate: (details) {
                      setState(() {
                        switch (clipImageBean.currentCtrl) {
                          case 0:
                            clipImageBean.topClip = tmpClip1 +
                                details.localPosition.dy -
                                downPosition.dy;
                            clipImageBean.leftClip = tmpClip2 +
                                details.localPosition.dx -
                                downPosition.dx;
                            break;
                          case 1:
                            clipImageBean.topClip = tmpClip1 +
                                details.localPosition.dy -
                                downPosition.dy;
                            clipImageBean.rightClip = tmpClip2 -
                                (details.localPosition.dx - downPosition.dx);
                            break;
                          case 2:
                            clipImageBean.bottomClip = tmpClip1 -
                                (details.localPosition.dy - downPosition.dy);
                            clipImageBean.leftClip = tmpClip2 +
                                details.localPosition.dx -
                                downPosition.dx;
                            break;
                          case 3:
                            clipImageBean.bottomClip = tmpClip1 -
                                (details.localPosition.dy - downPosition.dy);
                            clipImageBean.rightClip = tmpClip2 -
                                (details.localPosition.dx - downPosition.dx);
                            break;
                          case 4:
                            clipImageBean.leftClip = tmpClip1 +
                                (details.localPosition.dx - downPosition.dx);
                            clipImageBean.topClip = tmpClip2 +
                                (details.localPosition.dy - downPosition.dy);
                            clipImageBean.rightClip = tmpClip3 -
                                (details.localPosition.dx - downPosition.dx);
                            clipImageBean.bottomClip = tmpClip4 -
                                (details.localPosition.dy - downPosition.dy);
                            break;
                          default:
                        }
                      });
                    },
                    onPanEnd: (details) {},
                    child: CustomPaint(
                      painter: ClipImagePainter(clipImageBean),
                      size: size ?? Size.zero,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            color: Colors.blue,
            child: Row(
              children: <Widget>[
                RaisedButton(
                  onPressed: () {
                    var radio = clipImageBean.image.width / size.width;
                    clipImageBean.clipRect = Rect.fromLTRB(
                        clipImageBean.leftClip * radio,
                        clipImageBean.topClip * radio,
                        clipImageBean.image.width -
                            clipImageBean.rightClip * radio,
                        clipImageBean.image.height -
                            clipImageBean.bottomClip * radio);
                    Navigator.of(context).pop<ClipImageBean>(clipImageBean);
                  },
                  child: Text('OK'),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class ClipImagePainter extends CustomPainter {
  ClipImagePainter(this.clipImageBean);

  ClipImageBean clipImageBean;

  @override
  void paint(Canvas canvas, Size size) {
    clipImageBean?.draw(canvas, size);
  }

  @override
  bool shouldRepaint(ClipImagePainter oldDelegate) => oldDelegate != this;
}

class ClipImageBean {
  ClipImageBean(this.image)
      : imagePaint = Paint(),
        operatorPaint = Paint()
          ..color = Colors.white
          ..strokeWidth = 3.0
          ..style = PaintingStyle.stroke,
        leftClip = 0.0,
        topClip = 0.0,
        rightClip = 0.0,
        bottomClip = 0.0,
        clipRect = Rect.fromLTRB(
            0.0, 0.0, image.width.toDouble(), image.height.toDouble()),
        operatorPath = Path(),
        ctrlLength = ctrlSize / 2,
        ctrlPaint = Paint()
          ..color = Colors.white
          ..strokeWidth = 7
          ..style = PaintingStyle.stroke;

  Image image;

  Rect operatorRect;
  Rect tlCtrlRect;
  Rect trCtrlRect;
  Rect blCtrlRect;
  Rect brCtrlRect;
  static double ctrlSize = 60.0;
  int currentCtrl;

  Path operatorPath;
  double ctrlLength;
  Paint ctrlPaint;

  double leftClip;
  double topClip;
  double rightClip;
  double bottomClip;

  Paint imagePaint;
  Paint operatorPaint;

  //the rect to clip image.
  Rect clipRect;

  draw(Canvas canvas, Size size) {
    /// draw image
    canvas.drawImageRect(
        image,
        Rect.fromLTRB(
            0.0, 0.0, image.width.toDouble(), image.height.toDouble()),
        Rect.fromLTRB(
            0.0, 0.0, size.width, size.width * image.height / image.width),
        imagePaint);

    /// draw oprator
    operatorRect = Rect.fromLTRB(
        leftClip, topClip, size.width - rightClip, size.height - bottomClip);
    tlCtrlRect = Rect.fromCenter(
        center: operatorRect.topLeft, width: ctrlSize, height: ctrlSize);
    trCtrlRect = Rect.fromCenter(
        center: operatorRect.topRight, width: ctrlSize, height: ctrlSize);
    blCtrlRect = Rect.fromCenter(
        center: operatorRect.bottomLeft, width: ctrlSize, height: ctrlSize);
    brCtrlRect = Rect.fromCenter(
        center: operatorRect.bottomRight, width: ctrlSize, height: ctrlSize);
    //draw oprator ctrl
    operatorPath = Path()
      ..moveTo(operatorRect.topLeft.dx, operatorRect.topLeft.dy + ctrlLength)
      ..lineTo(operatorRect.topLeft.dx, operatorRect.topLeft.dy)
      ..lineTo(operatorRect.topLeft.dx + ctrlLength, operatorRect.topLeft.dy)
      ..moveTo(operatorRect.topRight.dx - ctrlLength, operatorRect.topRight.dy)
      ..lineTo(operatorRect.topRight.dx, operatorRect.topRight.dy)
      ..lineTo(operatorRect.topRight.dx, operatorRect.topRight.dy + ctrlLength)
      ..moveTo(
          operatorRect.bottomRight.dx, operatorRect.bottomRight.dy - ctrlLength)
      ..lineTo(operatorRect.bottomRight.dx, operatorRect.bottomRight.dy)
      ..lineTo(
          operatorRect.bottomRight.dx - ctrlLength, operatorRect.bottomRight.dy)
      ..moveTo(
          operatorRect.bottomLeft.dx + ctrlLength, operatorRect.bottomLeft.dy)
      ..lineTo(operatorRect.bottomLeft.dx, operatorRect.bottomLeft.dy)
      ..lineTo(
          operatorRect.bottomLeft.dx, operatorRect.bottomLeft.dy - ctrlLength);
    canvas.drawPath(operatorPath, ctrlPaint);

    //draw shadow out of operatorRect
    canvas.clipRect(operatorRect, clipOp: ClipOp.difference);
    canvas.drawColor(Color.fromARGB(200, 0, 0, 0), BlendMode.dstOut);

    canvas.drawRect(operatorRect, operatorPaint);
  }

  @override
  String toString() {
    return 'ClipImageBean: ' + 'clipRect: ${clipRect.toString()}';
  }

  int hitTestControl(Offset offset) {
    if (tlCtrlRect.contains(offset)) return 0;
    if (trCtrlRect.contains(offset)) return 1;
    if (blCtrlRect.contains(offset)) return 2;
    if (brCtrlRect.contains(offset)) return 3;
    if (operatorRect.contains(offset)) return 4;
    return -1;
  }
}
