import 'dart:ui' as ui;

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

  // void rebuildAll(Element el) {
  //   el.markNeedsBuild();
  //   el.visitChildren(rebuildAll);
  // }

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
    });
    // (context as Element).visitChildren(rebuildAll);
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
      currentSelectable.offset.translate(-currentSelectable.offset.dx, 0.0);
    });
  }

  setTopAlign() {
    setState(() {
      currentSelectable.offset.translate(0.0, -currentSelectable.offset.dy);
    });
  }

  setRightAlign() {
    setState(() {
      currentSelectable.offset
          .translate(size.width - currentSelectable.offset.dx, 0.0);
    });
  }

  setBottomAlign() {
    setState(() {
      currentSelectable.offset
          .translate(0.0, size.height - currentSelectable.offset.dy);
    });
  }

  //---------------------------------------------------------------------------------
  //Rotation
  //---------------------------------------------------------------------------------
  resetRotation(){
    setState(() {
      currentSelectable.rotRadians = 0;
    });
  }

  rotate(double radians){
    setState(() {
      currentSelectable.rotRadians = currentSelectable.rotRadians + radians;
    });
  }

  //---------------------------------------------------------------------------------
  //Undo
  //---------------------------------------------------------------------------------
  //TODO undo action, not selectable.
  undo(){
    setState(() {
      selectables.removeLast();
    });
  }

  //---------------------------------------------------------------------------------
  //clean
  //---------------------------------------------------------------------------------
  clear(){
    setState(() {
      selectables.clear();
    });
  }

    //---------------------------------------------------------------------------------
  //save image
  //---------------------------------------------------------------------------------
  save(GlobalKey key){
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
    setit() {
      setState(() {
        (currentSelectable as SelectablePath).mPaint.color = color;
      });
    }

    isSelectedMode ? setit() : config.penColor = color;
  }

  Color getPenColor() {
    return isSelectedMode
        ? (currentSelectable as SelectablePath).mPaint.color
        : config.penColor;
  }

  setPenWidth(double width) {
    // setit() {
    //   setState(() {
    //     ;
    //   });
    // }

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
    setit() {
      setState(() {
        (currentSelectable as SelectableShape).mPaint.color = color;
      });
    }

    isSelectedMode ? setit() : config.shapeColor = color;
  }

  Color getShapeColor() {
    return isSelectedMode
        ? (currentSelectable as SelectableShape).mPaint.color
        : config.shapeColor;
  }

  setShapeStyle(PaintingStyle style) {
    setit() {
      setState(() {
        (currentSelectable as SelectableShape).fill =
            style == PaintingStyle.fill;
      });
    }

    isSelectedMode ? setit() : config.shapeStyle = style;
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
    setit() {
      setState(() {
        (currentSelectable as SelectableText).text = text;
      });
    }

    isSelectedMode ? setit() : config.text = text;
  }

  String getText() {
    return isSelectedMode ? (currentSelectable as SelectableText).text : 'text';
  }

  setTextFont(String font) {
    setit() {
      setState(() {
        (currentSelectable as SelectableText).fontFamily = font;
      });
    }

    isSelectedMode ? setit() : config.font = font;
  }

  String getTextFont() {
    return isSelectedMode
        ? (currentSelectable as SelectableText).fontFamily
        : 'default';
  }

  setTextColor(Color color) {
    setit() {
      setState(() {
        (currentSelectable as SelectableText).textColor = color;
      });
    }

    isSelectedMode ? setit() : config.textColor = color;
  }

  Color getTextColor() {
    return isSelectedMode
        ? (currentSelectable as SelectableText).textColor
        : config.textColor;
  }

  setTextWeight(double weight) {
    setit() {
      setState(() {
        (currentSelectable as SelectableText).textWeight = weight.round();
      });
    }

    isSelectedMode ? setit() : config.typoWeight = weight.round();
  }

  int getTextWeight() {
    return isSelectedMode
        ? (currentSelectable as SelectableText).textWeight
        : config.typoWeight.round();
  }

  @override
  void initState() {
    super.initState();
    config = Configuration()
      ..bgColor = Colors.white
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
