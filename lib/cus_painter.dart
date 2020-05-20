import 'dart:ui';
import 'package:flutter/material.dart' hide SelectableText;
import 'package:wallpaper_maker/configuration.dart';
import 'package:wallpaper_maker/inherited_config.dart';
import 'selectable_bean.dart';
import 'package:flutter/services.dart';
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
  AssetBundle rootBundle;

  Offset lastPoint = Offset.zero;

  TextEditingController textEditingController;

  String text;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        widgetHeight = context.size.height;
        data.setSize(height: widgetHeight, ratio: 2);
      });
    });

    textEditingController = TextEditingController();
  }

  // @override
  // void didUpdateWidget(CanvasPanel oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
  //     setState(() {
  //       widgetHeight = context.size.height;
  //     });
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    data = ConfigWidget.of(context);
    rootBundle = DefaultAssetBundle.of(context);

    return Container(
      color: Colors.amber,
      child: GestureDetector(
        child: RepaintBoundary(
          key: widget.rKey,
          child: CustomPaint(
            size: data.size,
            painter: MyCanvas(data: data),
          ),
        ),
        onTapUp: (details) {
          print('on tap up');
          var offset =
              Offset(details.localPosition.dx, details.localPosition.dy);
          var newSelectables = data.selectables.reversed;

          var selectDone = false;

          for (var i = 0; i < newSelectables.length; i++) {
            var item = newSelectables.elementAt(i);

            if (selectDone) {
              setState(() {
                item.isSelected = false;
              });
            } else if (item.hitTest(offset)) {
              if (item.runtimeType.toString() == 'SelectableText' &&
                  item.isSelected) {}
              setState(() {
                data.setSelected(newSelectables.length - 1 - i);
              });
              selectDone = true;
            } else {
              setState(() {
                item.isSelected = false;
              });
            }
          }

          //All selectables failed in hittest.
          if (!selectDone) {
            if (data.isSelectedMode) {
              data.setUnselected();
            } else if (data.config.currentMode == 2) {
              setState(() {
                // data.selectables.add(
                //     SelectableText(data.config.text, details.localPosition));
              });
            }
          }
        },
        onScaleStart: (details) {
          setState(() {
            if (data.isSelectedMode) {
              lastPoint = details.localFocalPoint;
              return;
            }

            switch (data.config.currentMode) {
              case 0:
                data.selectables.add(
                  SelectablePath(
                      Path()
                        ..moveTo(details.localFocalPoint.dx,
                            details.localFocalPoint.dy),
                      data.getCurrentPen()),
                );
                break;
              case 1:
                data.selectables.add(SelectableShape(
                    Offset(
                        details.localFocalPoint.dx, details.localFocalPoint.dy),
                    data.config.shapeType,
                    data.getCurrentShape()));
                break;

              default:
            }
          });
        },
        onScaleUpdate: (details) {
          setState(() {
            if (!data.isSelectedMode) {
              switch (data.config.currentMode) {
                case 0:
                  (data.selectables[data.selectables.length - 1]
                          as SelectablePath)
                      .path
                      .lineTo(details.localFocalPoint.dx,
                          details.localFocalPoint.dy);
                  break;
                case 1:
                  (data.selectables[data.selectables.length - 1]
                              as SelectableShape)
                          .endPoint =
                      Offset(details.localFocalPoint.dx,
                          details.localFocalPoint.dy);
                  break;
                default:
              }
            } else if (details.scale != 1.0) {
              //Scale
              data.selectables[data.selectedIndex].isScale = true;
              data.selectables[data.selectedIndex].scaleRadio =
                  data.selectables[data.selectedIndex].lastScale *
                      details.scale;
              data.selectables[data.selectedIndex].tmpScale =
                  data.selectables[data.selectedIndex].lastScale *
                      details.scale;

              //Rotation
              data.selectables[data.selectedIndex].isRot = true;

              data.selectables[data.selectedIndex].rotRadians =
                  details.rotation +
                      data.selectables[data.selectedIndex].lastAngle;
              data.selectables[data.selectedIndex].tmpAngle = details.rotation +
                  data.selectables[data.selectedIndex].lastAngle;
            } else {
              //Translate
              data.selectables[data.selectedIndex].offset =
                  details.localFocalPoint - lastPoint;

              lastPoint = details.localFocalPoint;
            }
          });
        },
        onScaleEnd: (details) {
          if (data.isSelectedMode) {
            data.selectables[data.selectedIndex].lastScale =
                data.selectables[data.selectedIndex].tmpScale;

            data.selectables[data.selectedIndex].lastAngle =
                data.selectables[data.selectedIndex].tmpAngle;

            data.selectables[data.selectedIndex].offset = Offset.zero;
          }
          if (!data.isSelectedMode) {
            data.setSelected(data.selectables.length - 1);
          }
        },
        onDoubleTap: () => print('double tap'),
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
