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
      _setAlign(Offset(-currentSelectable.scaledRect.left, 0.0));
    });
  }

  setTopAlign() {
    setState(() {
      _setAlign(Offset(0.0, -currentSelectable.scaledRect.top));
    });
  }

  setRightAlign() {
    setState(() {
      _setAlign(Offset(size.width - currentSelectable.scaledRect.right, 0.0));
    });
  }

  setBottomAlign() {
    setState(() {
      _setAlign(Offset(0.0, size.height - currentSelectable.scaledRect.bottom));
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
      isSelectedMode = false;
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

  handleTapDown(TapDownDetails details) {
    if (isSelectedMode) {
      if (currentSelectable.isCtrling =
          currentSelectable.hitTestControl(details.localPosition)) {
        currentSelectable.handleCtrlStart(details.localPosition);
      }

      currentSelectable.isMoving =
          currentSelectable.hitTest(details.localPosition) &&
              !currentSelectable.isCtrling;
      if (currentSelectable.isMoving) {
        currentSelectable.handleMoveStart(details.localPosition);
      }
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
          break;
      }
    }
  }

  handleTapUpdate(DragUpdateDetails details) {
    setState(() {
      if (isSelectedMode) {
        if (currentSelectable.isCtrling) {
          currentSelectable.handleCtrlUpdate(details.localPosition);
        }
        if (currentSelectable.isMoving) {
          currentSelectable.handleMoveUpdate(details.localPosition);
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
            break;
        }
      }
    });
  }

  handleTapEnd(DragEndDetails details) {
    if (isSelectedMode) {
      currentSelectable.handleCtrlOrMoveEnd();
    } else if (selectables.last.rect == null ||
        selectables.last.rect.width < 2) {
      selectables.removeLast();
      setState(() {});
    }
  }

  var tmpScaleX;
  var tmpScaleY;
  var tmpRadius;

  ///Clockwise(1) or anticlockwise(-1) when start rotate(when set rotating to true), default value is 0.
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
    print('length:' + selectables.length.toString());
    if (!leafToolOffstage) {
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
  bool leafToolOffstage = true;

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
    leafToolOffstage = false;
  }

  hideLeafTool() {
    controller.reverse();
  }

  toggleLeafTool() {
    if (leafToolOffstage) {
      showLeafTool();
    } else if (currentLeafTool != lastLeafTool) {
      setState(() {});
    } else {
      hideLeafTool();
    }
  }

  List<SelectableImageFile> cacheImgFiles = [];

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
          leafToolOffstage = true;
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
    cacheImgFiles = [];
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
