import 'package:flutter/material.dart' hide SelectableText;
import 'package:flutter/rendering.dart';
import 'package:wallpaper_maker/configuration.dart';
import 'package:wallpaper_maker/utils.dart';

import 'selectable_bean.dart';

class ConfigWidget extends StatefulWidget {
  final Widget child;

  ConfigWidget({@required this.child});

  @override
  ConfigWidgetState createState() => ConfigWidgetState();

  static ConfigWidgetState of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<InheritedConfig>().data;
  }
}

class ConfigWidgetState extends State<ConfigWidget> {
  Configuration config;

  bool isSelectedMode;
  List<Selectable> selectables;
  int selectedIndex;
  Selectable currentSelectable;

  BuildContext mContext;

  //size of canvas.
  Size size;
  //size of stage area.
  Size stageSize;

  int currentMainTool = 0;

  bool isScaling = false;

  // void rebuildAll(Element el) {
  //   el.markNeedsBuild();
  //   el.visitChildren(rebuildAll);
  // }

  ///0: Pen
  ///1: Shape
  ///2: Text
  ///3: Image
  ///4: BackgroundColor
  ///5: AlignTool
  ///6: RotationTool
  setCurrentMainTool(int index) {
    setState(() {
      currentMainTool = index;
    });
  }

  //---------------------------------------------------------------------------------
  //Selectable
  //---------------------------------------------------------------------------------
  addSelectable(Selectable selectable) {
    setState(() {
      selectables.add(selectable);
    });
  }

  setSelected(int index) {
    setState(() {
      isSelectedMode = true;
      selectedIndex = index;
      currentSelectable = selectables[index];
      currentSelectable.isSelected = true;

      switch (currentSelectable.runtimeType.toString()) {
        case 'SelectablePath':
          currentMainTool = 0;
          break;
        case 'SelectableShape':
          currentMainTool = 1;
          break;
        case 'SelectableText':
          currentMainTool = 2;
          break;
        case 'SelectableImage':
          currentMainTool = 3;
          break;
        default:
      }
    });
  }

  setSeleteLast() {
    setState(() {
      if (isSelectedMode) {
        currentSelectable.isSelected = false;
      }
      isSelectedMode = true;
      selectedIndex = selectables.length - 1;
      currentSelectable = selectables.last;
      currentSelectable.isSelected = true;
    });
  }

  removeSelectable(int index) {
    setState(() {
      selectables.removeAt(index);
    });
  }

  setUnselected() {
    setState(() {
      currentSelectable.isSelected = false;
      currentSelectable = null;
      isSelectedMode = false;
      selectedIndex = -1;
    });
  }

  //---------------------------------------------------------------------------------
  //Size
  //---------------------------------------------------------------------------------
  setSize({double height, double ratio}) {
    setState(() {
      size = Size(height / ratio, height);
    });
  }

  //---------------------------------------------------------------------------------
  //Align
  //---------------------------------------------------------------------------------
  setLeftAlign() {
    setState(() {
      _setAlign(Offset(-currentSelectable.rect.left, 0.0));
    });
  }

  setTopAlign() {
    setState(() {
      _setAlign(Offset(0.0, -currentSelectable.rect.top));
    });
  }

  setRightAlign() {
    setState(() {
      _setAlign(Offset(size.width - currentSelectable.rect.right, 0.0));
    });
  }

  setBottomAlign() {
    setState(() {
      _setAlign(Offset(0.0, size.height - currentSelectable.rect.bottom));
    });
  }

  setCenterHorizonAlign() {
    setState(() {
      _setAlign(Offset(size.width / 2 - currentSelectable.rect.center.dx, 0.0));
    });
  }

  setCenterVerticalAlign() {
    setState(() {
      _setAlign(
          Offset(0.0, size.height / 2 - currentSelectable.rect.center.dy));
    });
  }

  _setAlign(Offset transOffset) {
    if (currentSelectable.runtimeType.toString() == 'SelectablePath') {
      (currentSelectable as SelectablePath).path =
          (currentSelectable as SelectablePath).path.shift(transOffset);
    }
    if (currentSelectable.runtimeType.toString() == 'SelectableShape') {
      (currentSelectable as SelectableShape).startPoint =
          (currentSelectable as SelectableShape).startPoint + transOffset;
      (currentSelectable as SelectableShape).endPoint =
          (currentSelectable as SelectableShape).endPoint + transOffset;
    }
  }

  //---------------------------------------------------------------------------------
  //Rotation
  //---------------------------------------------------------------------------------
  resetRotation() {
    setState(() {
      currentSelectable.rotRadians = 0;
    });
  }

  rotate(double radians) {
    setState(() {
      currentSelectable.rotRadians = currentSelectable.rotRadians + radians;
    });
  }

  //---------------------------------------------------------------------------------
  //Undo
  //---------------------------------------------------------------------------------
  //TODO undo action, not selectable.
  undo() {
    setState(() {
      selectables.removeLast();
    });
  }

  //---------------------------------------------------------------------------------
  //clean
  //---------------------------------------------------------------------------------
  clear() {
    setState(() {
      selectables.clear();
    });
  }

  //---------------------------------------------------------------------------------
  //save image
  //---------------------------------------------------------------------------------
  save(GlobalKey key) {
    saveImage(key);
  }

  //---------------------------------------------------------------------------------
  //Background
  //---------------------------------------------------------------------------------
  setBackgroundColor(Color color) {
    setState(() {
      config.bgColor = color;
    });
  }

  Color getBackroundColor() {
    return config.bgColor;
  }

  //---------------------------------------------------------------------------------
  //Pen
  //---------------------------------------------------------------------------------
  Paint getCurrentPen() {
    return Paint()
      ..color = config.penColor
      ..strokeWidth = config.penWidth
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke;
  }

  setPenColor(Color color) {
    setState(() {
      isSelectedMode
          ? (currentSelectable as SelectablePath).mPaint.color = color
          : config.penColor = color;
    });
  }

  Color getPenColor() {
    return isSelectedMode
        ? (currentSelectable as SelectablePath).mPaint.color
        : config.penColor;
  }

  setPenWidth(double width) {
    setState(() {
      isSelectedMode
          ? (currentSelectable as SelectablePath).mPaint.strokeWidth = width
          : config.penWidth = width;
    });
  }

  double getPenWidth() {
    return isSelectedMode
        ? (currentSelectable as SelectablePath).mPaint.strokeWidth
        : config.penWidth;
  }

  //---------------------------------------------------------------------------------
  //Shape
  //---------------------------------------------------------------------------------
  Paint getCurrentShape() {
    return Paint()
      ..color = config.shapeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = config.shapeWidth;
  }

  setShapeType(int type) {
    setState(() {
      config.shapeType = type;
    });
  }

  int getShapeType() {
    return isSelectedMode
        ? (currentSelectable as SelectableShape).shapeType
        : config.shapeType;
  }

  setShapeColor(Color color) {
    setState(() {
      isSelectedMode
          ? (currentSelectable as SelectableShape).mPaint.color = color
          : config.shapeColor = color;
    });
  }

  Color getShapeColor() {
    return isSelectedMode
        ? (currentSelectable as SelectableShape).mPaint.color
        : config.shapeColor;
  }

  setShapeStyle(PaintingStyle style) {
    setState(() {
      isSelectedMode
          ? (currentSelectable as SelectableShape).fill =
              style == PaintingStyle.fill
          : config.shapeStyle = style;
    });
  }

  bool getShapeStyle() {
    return isSelectedMode
        ? (currentSelectable as SelectableShape).fill
        : config.shapeStyle == PaintingStyle.fill;
  }

  setShapeFillColor(Color color) {
    if (isSelectedMode) {
      setState(() {
        (currentSelectable as SelectableShape).fillPaint.color = color;
      });
    }
  }

  Color getShapeFillColor() {
    return isSelectedMode
        ? (currentSelectable as SelectableShape).fillPaint.color
        : null;
  }

  setShapeWidth(double width) {
    setState(() {
      isSelectedMode
          ? (currentSelectable as SelectableShape).mPaint.strokeWidth = width
          : config.shapeWidth = width;
    });
  }

  double getShapeWidth() {
    return isSelectedMode
        ? (currentSelectable as SelectableShape).mPaint.strokeWidth
        : config.shapeWidth;
  }

  //---------------------------------------------------------------------------------
  //Text
  //---------------------------------------------------------------------------------
  SelectableText assembleSelectableText(String text, Offset offset) {
    return SelectableText(text: text, totalOffset: offset)
      ..textColor = config.textColor
      ..textWeight = 3;
  }

  setText(String text) {
    setState(() {
      isSelectedMode
          ? (currentSelectable as SelectableText).text = text
          : config.text = text;
    });
  }

  String getText() {
    return isSelectedMode ? (currentSelectable as SelectableText).text : 'text';
  }

  setTextFont(String font) {
    setState(() {
      isSelectedMode
          ? (currentSelectable as SelectableText).fontFamily = font
          : config.font = font;
    });
  }

  String getTextFont() {
    return isSelectedMode
        ? (currentSelectable as SelectableText).fontFamily
        : 'default';
  }

  setTextColor(Color color) {
    setState(() {
      isSelectedMode
          ? (currentSelectable as SelectableText).textColor = color
          : config.textColor = color;
    });
  }

  Color getTextColor() {
    return isSelectedMode
        ? (currentSelectable as SelectableText).textColor
        : config.textColor;
  }

  setTextWeight(double weight) {
    setState(() {
      isSelectedMode
          ? (currentSelectable as SelectableText).textWeight = weight.round()
          : config.typoWeight = weight.round();
    });
  }

  int getTextWeight() {
    return isSelectedMode
        ? (currentSelectable as SelectableText).textWeight
        : config.typoWeight.round();
  }

  var lastPoint = Offset.zero;
  var tmpOffset = Offset.zero;
  var tmpTLOffset = Offset.zero;
  var tmpBROffset = Offset.zero;

  handleTapDown(TapDownDetails details) {
    if (isSelectedMode) {
      currentSelectable.isCtrling =
          currentSelectable.hitTestControl(details.localPosition);
      currentSelectable.isMoving =
          currentSelectable.hitTest(details.localPosition) &&
              !currentSelectable.isCtrling;

      lastPoint = details.localPosition;
    } else {
      switch (config.currentMode) {
        case 0:
          selectables.add(
            SelectablePath(
                Path()
                  ..moveTo(details.localPosition.dx, details.localPosition.dy),
                getCurrentPen()),
          );
          break;
        case 1:
          selectables.add(SelectableShape(
              Offset(details.localPosition.dx, details.localPosition.dy),
              config.shapeType,
              getCurrentShape()));
          break;

        default:
      }
    }
  }

  handleTapUpdate(DragUpdateDetails details) {
    setState(() {
      if (isSelectedMode) {
        if (currentSelectable.isCtrling) {
          var ctrlIndex = currentSelectable.currentControlPoint;
          switch (ctrlIndex) {
            case 0:
              if (currentSelectable is SelectableShape) {
                (currentSelectable as SelectableShape).tlOffset =
                    Offset(details.delta.dx, 0.0);
              }
              break;
            case 1:
              if (currentSelectable is SelectableShape) {
                (currentSelectable as SelectableShape).tlOffset =
                    Offset(0.0, details.delta.dy);
              }
              break;
            case 2:
              if (currentSelectable is SelectableShape) {
                (currentSelectable as SelectableShape).brOffset =
                    Offset(details.delta.dx, 0.0);
              }
              if (currentSelectable is SelectableText) {
                (currentSelectable as SelectableText).maxWidth =
                    (details.localPosition.dx -
                            currentSelectable.rect.center.dx) *
                        2;
              }
              break;
            case 3:
              if (currentSelectable is SelectableShape) {
                (currentSelectable as SelectableShape).brOffset =
                    Offset(0.0, details.delta.dy);
              }
              break;
            case 4:
              if (currentSelectable is SelectableShape) {
                (currentSelectable as SelectableShape).tlOffset =
                    Offset(details.delta.dx, details.delta.dy);
              }
              break;
            case 5:
              if (currentSelectable is SelectableShape) {
                (currentSelectable as SelectableShape).tlOffset =
                    Offset(0.0, details.delta.dy);
                (currentSelectable as SelectableShape).brOffset =
                    Offset(details.delta.dx, 0.0);
              }
              break;
            case 6:
              if (currentSelectable is SelectableShape) {
                (currentSelectable as SelectableShape).tlOffset =
                    Offset(details.delta.dx, 0.0);
                (currentSelectable as SelectableShape).brOffset =
                    Offset(0.0, details.delta.dy);
              }
              break;
            case 7:
              if (currentSelectable is SelectableShape) {
                (currentSelectable as SelectableShape).brOffset =
                    Offset(details.delta.dx, details.delta.dy);
              }
              break;
            default:
          }
        }
        if (currentSelectable.isMoving) {
          if (currentSelectable is SelectableShape) {
            var sshape = currentSelectable as SelectableShape;
            sshape.tlOffset =
                sshape.lastTLOffset + details.localPosition - lastPoint;
            sshape.brOffset =
                sshape.lastBROffset + details.localPosition - lastPoint;

            tmpTLOffset = sshape.tlOffset;
            tmpBROffset = sshape.brOffset;
          } else {
            // currentSelectable.offset = details.delta;
            currentSelectable.offset = currentSelectable.lastOffset +
                details.localPosition -
                lastPoint;
            tmpOffset = currentSelectable.offset;
          }
        }
      } else {
        switch (config.currentMode) {
          case 0:
            (selectables[selectables.length - 1] as SelectablePath)
                .path
                .lineTo(details.localPosition.dx, details.localPosition.dy);
            break;
          case 1:
            (selectables[selectables.length - 1] as SelectableShape).endPoint =
                Offset(details.localPosition.dx, details.localPosition.dy);
            break;
          default:
        }
      }
    });
  }

  handleTapEnd(DragEndDetails dragEndDetails) {
    if (isSelectedMode) {
      currentSelectable.currentControlPoint = -1;
      if (currentSelectable is SelectableShape) {
        // (currentSelectable as SelectableShape).tlOffset = Offset.zero;
        // (currentSelectable as SelectableShape).brOffset = Offset.zero;
        (currentSelectable as SelectableShape).lastTLOffset = tmpTLOffset;
        (currentSelectable as SelectableShape).lastBROffset = tmpBROffset;
      }
      if (currentSelectable is SelectablePath ||
          currentSelectable is SelectableText) {
        // currentSelectable.offset = Offset.zero;
        currentSelectable.lastOffset = tmpOffset;
      }
    }
  }

  handleScaleStart(ScaleStartDetails details) {
    // if (isSelectedMode) {
    //   if (currentSelectable.hitTestControl(details.localFocalPoint)) {
    //     isScaling = true;
    //   }
    //   lastPoint = details.localFocalPoint;
    // }
  }

  handleScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      if (isSelectedMode && details.scale != 1.0) {
        //Scale
        currentSelectable.scaleRadioX =
            currentSelectable.lastScaleX * details.scale;
        currentSelectable.scaleRadioY =
            currentSelectable.lastScaleY * details.scale;
        currentSelectable.tmpScaleX =
            currentSelectable.lastScaleX * details.scale;
        currentSelectable.tmpScaleY =
            currentSelectable.lastScaleY * details.scale;

        //Rotation
        currentSelectable.isRot = true;

        currentSelectable.rotRadians =
            details.rotation + currentSelectable.lastAngle;
        currentSelectable.tmpAngle =
            details.rotation + currentSelectable.lastAngle;
      }
    });
  }

  handleScaleEnd(ScaleEndDetails details) {
    if (isSelectedMode) {
      currentSelectable.lastScaleX = currentSelectable.tmpScaleX;
      currentSelectable.lastScaleY = currentSelectable.tmpScaleY;

      currentSelectable.lastAngle = currentSelectable.tmpAngle;

      // currentSelectable.offset = Offset.zero;

      if (isScaling) isScaling = false;
    }
  }

  handleTapUp(TapUpDetails details) {
    if (selectables.last.selectedPath == null) {
      selectables.removeLast();
    }

    var newSelectables = selectables.reversed;
    var selectDone = false;

    for (var i = 0; i < newSelectables.length; i++) {
      var item = newSelectables.elementAt(i);

      if (selectDone) {
        setState(() {
          item.isSelected = false;
        });
      } else if (item.hitTest(details.localPosition)) {
        setSelected(newSelectables.length - 1 - i);
        selectDone = true;
      } else {
        setState(() {
          item.isSelected = false;
        });
      }
    }

    //All selectables failed in hittest.
    if (!selectDone && isSelectedMode) {
      setUnselected();
    }
  }

  @override
  void initState() {
    super.initState();
    config = Configuration()
      ..bgColor = Colors.red
      ..currentMode = 0
      ..penColor = Colors.red
      ..penWidth = 5
      ..shapeType = 0
      ..shapeColor = Colors.red
      ..shapeStyle = PaintingStyle.stroke
      ..shapeFillColor = Colors.red
      ..shapeWidth = 5
      ..font = 'default'
      ..typoWeight = 3
      ..textColor = Colors.red;

    selectables = List();
    isSelectedMode = false;

    size = Size(0.0, 0.0);
  }

  @override
  Widget build(BuildContext context) {
    mContext = context;
    return InheritedConfig(
      data: this,
      child: widget.child,
    );
  }
}

class InheritedConfig extends InheritedWidget {
  final ConfigWidgetState data;

  InheritedConfig({this.data, Widget child}) : super(child: child);

  @override
  bool updateShouldNotify(InheritedConfig oldWidget) => true;
}
