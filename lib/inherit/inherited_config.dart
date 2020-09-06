import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:wallpaper_maker/beans/selectable_bean.dart';
import 'package:wallpaper_maker/cus_widgets/cus_widget.dart';
import 'configuration.dart';
import 'constants.dart';

class ConfigWidget extends StatefulWidget {
  final Widget child;

  ConfigWidget({@required this.child});

  @override
  ConfigWidgetState createState() => ConfigWidgetState();

  static ConfigWidgetState of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<InheritedConfig>().data;
  }
}

class ConfigWidgetState extends State<ConfigWidget>
    with TickerProviderStateMixin {
  Configuration _config;

  bool isSelectedMode;
  List<Selectable> selectables;
  int selectedIndex;
  Selectable currentSelectable;

  List<List<Selectable>> selectableStack;
  int stackIndex;

  BuildContext mContext;

  //Canvas scale and tranlate
  double canvasScale;
  double tmpCanvasScale;
  Offset canvasOffset;
  bool isCanvasScaling;

  Offset tmpCanvasOffset;
  Offset startPoint;

  //分辨率
  Size size2Save = Size(1080, 1920);

  //size of canvas.
  Size size;
  //size of stage area.
  Size stageSize;

  MainTool currentMainTool = MainTool.pen;
  LeafTool currentLeafTool;
  LeafTool lastLeafTool;

  bool isScaling = false;

  String currentEditImgPath;
  bool newCanva;
  bool fromReset = false;

  setCurrentMainTool(MainTool mainTool) {
    setState(() {
      currentMainTool = mainTool;

      if (mainTool == MainTool.pen) _config.currentMode = 0;
      if (mainTool == MainTool.shape) _config.currentMode = 1;
    });
  }

  setCurrentLeafTool(LeafTool leafTool) {
    setState(() {
      lastLeafTool = currentLeafTool;
      currentLeafTool = leafTool;
    });
  }

  //---------------------------------------------------------------------------------
  //SelectableStack
  //---------------------------------------------------------------------------------
  redo() {
    stackIndex++;
    selectables = selectableStack[stackIndex];
    setState(() {});
  }

  undo() {
    stackIndex--;
    if (stackIndex < 0) {
      stackIndex = 0;
    }
    selectables = selectableStack[stackIndex];
    setState(() {});
  }

  pushToStack() {
    selectableStack.add([]..addAll(selectables));
    stackIndex = selectableStack.length - 1;
  }

  //---------------------------------------------------------------------------------
  //Selectable
  //---------------------------------------------------------------------------------
  addSelectable(Selectable selectable) {
    setState(() {
      selectables.add(selectable);
    });
    pushToStack();
  }

  setSelected(int index) {
    setState(() {
      isSelectedMode = true;
      selectedIndex = index;
      currentSelectable = selectables[index];
      currentSelectable.isSelected = true;

      switch (currentSelectable.runtimeType.toString()) {
        case 'SelectablePath':
          currentMainTool = MainTool.pen;
          break;
        case 'SelectableShape':
          currentMainTool = MainTool.shape;
          break;
        case 'SelectableTypo':
          currentMainTool = MainTool.text;
          break;
        case 'SelectableImage':
          currentMainTool = MainTool.image;
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

  removeCurrentSelected() {
    setState(() {
      selectables[selectedIndex].isSelected = false;
      selectables.removeAt(selectedIndex);
      isSelectedMode = false;
    });
    pushToStack();
  }

  setUnselected() {
    setState(() {
      currentSelectable?.isSelected = false;
      currentSelectable = null;
      isSelectedMode = false;
      selectedIndex = -1;
    });
  }

  reset() {
    setState(() {
      fromReset = true;
      _init();
    });
  }

  //---------------------------------------------------------------------------------
  //Size
  //---------------------------------------------------------------------------------
  setSize({double height, double ratio}) {
    setState(() {
      size = Size(height * ratio, height);
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
    if (currentSelectable is SelectableShape) {
      var cs = currentSelectable as SelectableShape;
      cs.startPoint =
          (currentSelectable as SelectableShape).startPoint + transOffset;
      cs.endPoint =
          (currentSelectable as SelectableShape).endPoint + transOffset;
    } else {
      currentSelectable.offset = currentSelectable.offset + transOffset;
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
  //clean
  //---------------------------------------------------------------------------------
  clean() {
    setState(() {
      selectables.clear();
      pushToStack();
    });
  }

  //---------------------------------------------------------------------------------
  //save image
  //---------------------------------------------------------------------------------
  // save(GlobalKey key) {
  //   saveImage(key);
  // }

  //---------------------------------------------------------------------------------
  //Background
  //---------------------------------------------------------------------------------
  setBackgroundColor(Color color) {
    setState(() {
      _config.bgColor = color;
    });
  }

  Color getBackroundColor() {
    return _config.bgColor ?? Colors.white;
  }

  //---------------------------------------------------------------------------------
  //Pen
  //---------------------------------------------------------------------------------
  Paint getCurrentPen() {
    return Paint()
      ..color = _config.penColor
      ..strokeWidth = _config.penWidth
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
  }

  setPenColor(Color color) {
    setState(() {
      isSelectedMode
          ? (currentSelectable as SelectablePath).mPaint.color = color
          : _config.penColor = color;
    });
  }

  Color getPenColor() {
    return isSelectedMode
        ? (currentSelectable as SelectablePath).mPaint.color
        : _config.penColor;
  }

  setPenWidth(double width) {
    setState(() {
      isSelectedMode
          ? (currentSelectable as SelectablePath).mPaint.strokeWidth = width
          : _config.penWidth = width;
    });
  }

  double getPenWidth() {
    return isSelectedMode
        ? (currentSelectable as SelectablePath).mPaint.strokeWidth
        : _config.penWidth;
  }

  //---------------------------------------------------------------------------------
  //Shape
  //---------------------------------------------------------------------------------
  Paint getCurrentShape() {
    return Paint()
      ..color = _config.shapeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = _config.shapeWidth;
  }

  setShapeType(int type) {
    setState(() {
      _config.shapeType = type;
    });
  }

  int getShapeType() {
    return isSelectedMode
        ? (currentSelectable as SelectableShape).shapeType
        : _config.shapeType;
  }

  setShapeColor(Color color) {
    setState(() {
      isSelectedMode
          ? (currentSelectable as SelectableShape).mPaint.color = color
          : _config.shapeColor = color;
    });
  }

  Color getShapeColor() {
    return isSelectedMode
        ? (currentSelectable as SelectableShape).mPaint.color
        : _config.shapeColor;
  }

  setShapeStyle(PaintingStyle style) {
    setState(() {
      isSelectedMode
          ? (currentSelectable as SelectableShape).fill =
              style == PaintingStyle.fill
          : _config.shapeStyle = style;
    });
  }

  bool getShapeStyle() {
    return isSelectedMode
        ? (currentSelectable as SelectableShape).fill
        : _config.shapeStyle == PaintingStyle.fill;
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
          : _config.shapeWidth = width;
    });
  }

  double getShapeWidth() {
    return isSelectedMode
        ? (currentSelectable as SelectableShape).mPaint.strokeWidth
        : _config.shapeWidth;
  }

  //---------------------------------------------------------------------------------
  //Text
  //---------------------------------------------------------------------------------
  SelectableTypo assembleSelectableTypo(
      String text, Offset offset, double maxWidth) {
    return SelectableTypo(text: text, mOffset: offset, maxWidth: maxWidth)
      ..textColor = _config.textColor
      ..textWeight = 3;
  }

  setText(String text) {
    setState(() {
      isSelectedMode
          ? (currentSelectable as SelectableTypo).text = text
          : _config.text = text;
    });
  }

  String getText() {
    return isSelectedMode ? (currentSelectable as SelectableTypo).text : '';
  }

  setTextFont(String font) {
    setState(() {
      isSelectedMode
          ? (currentSelectable as SelectableTypo).fontFamily = font
          : _config.font = font;
    });
  }

  String getTextFont() {
    return isSelectedMode
        ? (currentSelectable as SelectableTypo).fontFamily
        : _config.font;
  }

  setTextColor(Color color) {
    setState(() {
      isSelectedMode
          ? (currentSelectable as SelectableTypo).textColor = color
          : _config.textColor = color;
    });
  }

  Color getTextColor() {
    return isSelectedMode
        ? (currentSelectable as SelectableTypo).textColor
        : _config.textColor;
  }

  setTextWeight(double weight) {
    setState(() {
      isSelectedMode
          ? (currentSelectable as SelectableTypo).textWeight = weight.round()
          : _config.typoWeight = weight.round();
    });
  }

  int getTextWeight() {
    return isSelectedMode
        ? (currentSelectable as SelectableTypo).textWeight
        : _config.typoWeight.round();
  }

  //Image
  setImageClip(Rect clipRect) {
    setState(() {
      (currentSelectable as SelectableImage).clipRect = clipRect;
    });
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

      if (currentSelectable.isMoving) {
        tmpOffset = currentSelectable.offset;
      }

      lastPoint = details.localPosition;
    } else {
      switch (_config.currentMode) {
        case 0:
          addSelectable(SelectablePath(getCurrentPen())
            ..moveTo(details.localPosition.dx, details.localPosition.dy));
          break;
        case 1:
          addSelectable(SelectableShape(
              startPoint:
                  Offset(details.localPosition.dx, details.localPosition.dy),
              shapeType: _config.shapeType,
              paint: getCurrentShape()));
          break;
        default:
      }
    }
  }

  var currentShape;

  handleTapUpdate(DragUpdateDetails details) {
    setState(() {
      if (isSelectedMode) {
        if (currentSelectable.isCtrling) {
          var ctrlIndex = currentSelectable.currentControlPoint;

          if (currentSelectable is SelectableShape) {
            currentShape = currentSelectable as SelectableShape;
            switch (ctrlIndex) {
              case 0:
                currentShape.tlOffset = currentShape.lastTLOffset +
                    Offset(details.localPosition.dx - lastPoint.dx, 0.0);
                tmpTLOffset = currentShape.tlOffset;
                break;
              case 1:
                currentShape.tlOffset = currentShape.lastTLOffset +
                    Offset(0.0, details.localPosition.dy - lastPoint.dy);
                tmpTLOffset = currentShape.tlOffset;
                break;
              case 2:
                currentShape.brOffset = currentShape.lastBROffset +
                    Offset(details.localPosition.dx - lastPoint.dx, 0.0);
                tmpBROffset = currentShape.brOffset;
                break;
              case 3:
                currentShape.brOffset = currentShape.lastBROffset +
                    Offset(0.0, details.localPosition.dy - lastPoint.dy);
                tmpBROffset = currentShape.brOffset;
                break;
              default:
                break;
            }
          }

          if (currentSelectable is SelectableTypo) {
            (currentSelectable as SelectableTypo).maxWidth =
                (details.localPosition.dx - currentSelectable.rect.center.dx) *
                    2;
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
            currentSelectable.offset =
                tmpOffset + details.localPosition - lastPoint;
          }
        }
      } else {
        switch (_config.currentMode) {
          case 0:
            (selectables[selectables.length - 1] as SelectablePath)
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

  handleTapEnd(DragEndDetails details) {
    if (isSelectedMode) {
      currentSelectable.currentControlPoint = -1;
      if (currentSelectable is SelectableShape) {
        (currentSelectable as SelectableShape).lastTLOffset = tmpTLOffset;
        (currentSelectable as SelectableShape).lastBROffset = tmpBROffset;
      }
      currentSelectable.isMoving = false;
      currentSelectable.isCtrling = false;
    } else if (selectables.last.rect == null ||
        selectables.last.rect.width < 2) {
      selectables.removeLast();
      setState(() {});
    }
  }

  var tmpScaleX;
  var tmpScaleY;
  var tmpRadius;
  //Clockwise(1) or anticlockwise(-1) when start rotate(when set rotating to true), default value is 0.
  int rotFlag;

  handleScaleStart(ScaleStartDetails details) {
    if (isSelectedMode) {
      tmpScaleX = currentSelectable.scaleRadioX;
      tmpScaleY = currentSelectable.scaleRadioY;
      tmpRadius = currentSelectable.rotRadians;
    }
  }

  handleScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      if (isSelectedMode && details.scale != 1.0) {
        //Scale
        currentSelectable.scaleRadioX = tmpScaleX * details.scale;
        currentSelectable.scaleRadioY = tmpScaleY * details.scale;

        //Rotation
        if (rotFlag == 0 && details.rotation.abs() > pi / 18) {
          rotFlag = details.rotation >= 0 ? 1 : -1;
        }

        if (rotFlag != 0) {
          currentSelectable.rotRadians =
              details.rotation + tmpRadius - pi / 18 * rotFlag;
          currentSelectable.tmpAngle =
              details.rotation + tmpRadius - pi / 18 * rotFlag;
        }
      }
    });
  }

  handleScaleEnd(ScaleEndDetails details) {
    rotFlag = 0;
  }

  handleTapUp(TapUpDetails details) {
    if (!offStage) {
      hideLeafTool();
      return;
    }

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

  //---------------------------------------------------------------------------------
  //LeafTool Animation
  //---------------------------------------------------------------------------------
  AnimationController controller;
  Animation leafToolAnimation;
  bool offStage = true;

  double bottom = 0;
  double top = 0;
  MessageBoxDirection direction = MessageBoxDirection.bottom;
  double position = 20;

  setIndicatorPosition(GlobalKey key) {
    var box = (key.currentContext.findRenderObject()) as RenderBox;
    position = box.localToGlobal(Offset.zero).dx + box.size.width / 2 - 8;
  }

  setLeafToolTop() {
    bottom = null;
    top = 50;
    direction = MessageBoxDirection.top;
  }

  setLeafToolBottom() {
    bottom = 130;
    top = null;
    direction = MessageBoxDirection.bottom;
  }

  showLeafTool() {
    controller.forward();
    offStage = false;
  }

  hideLeafTool() {
    controller.reverse();
  }

  toggleLeafTool() {
    if (offStage) {
      showLeafTool();
    } else if (currentLeafTool != lastLeafTool) {
      setState(() {});
    } else {
      hideLeafTool();
    }
  }

  @override
  void initState() {
    super.initState();

    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    leafToolAnimation = controller.drive(Tween<double>(begin: 0.0, end: 1.0)
        .chain(CurveTween(curve: Curves.easeInBack)));
    controller.addListener(() {
      if (controller.isDismissed && controller.value == 0.0) {
        setState(() {
          offStage = true;
        });
      }
    });

    _init();
  }

  _init() {
    _config = Configuration()
      ..bgColor = Colors.white
      ..currentMode = 0
      ..penColor = Colors.black
      ..penWidth = 5
      ..shapeType = 0
      ..shapeColor = Colors.black
      ..shapeStyle = PaintingStyle.stroke
      ..shapeFillColor = Colors.black
      ..shapeWidth = 5
      ..font = 'default'
      ..typoWeight = 3
      ..textColor = Colors.black;

    selectables = List();
    isSelectedMode = false;

    newCanva = true;

    if (!fromReset) {
      size = Size.zero;
    } else {
      fromReset = false;
    }

    currentEditImgPath = '';

    selectableStack = [];
    pushToStack();
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
