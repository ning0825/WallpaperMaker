import 'package:flutter/material.dart' hide SelectableText;
import 'package:wallpaper_maker/configuration.dart';

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
  //---------------------------------------------------------------------------------
  //Selectables
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
  }

  setSeleteLast() {
    setState(() {
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
    setit() {
      setState(() {
        (currentSelectable as SelectablePath).mPaint.strokeWidth = width;
      });
    }

    isSelectedMode ? setit() : config.penWidth = width;
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
    config.shapeType = type;
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
    setit() {
      setState(() {
        (currentSelectable as SelectableShape).fillColor = color;
      });
    }

    isSelectedMode ? setit() : config.shapeColor = color;
  }

  Color getShapeFillColor() {
    return isSelectedMode
        ? (currentSelectable as SelectableShape).fillColor
        : config.shapeFillColor;
  }

  setShapeWidth(double width) {
    setit() {
      setState(() {
        (currentSelectable as SelectableShape).mPaint.strokeWidth = width;
      });
    }

    isSelectedMode ? setit() : config.shapeWidth = width;
  }

  double getShapeWidth() {
    return isSelectedMode
        ? (currentSelectable as SelectableShape).mPaint.strokeWidth
        : config.shapeWidth;
  }

  //---------------------------------------------------------------------------------
  //Text
  //---------------------------------------------------------------------------------
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
      ..penColor = Colors.black
      ..penWidth = 5
      ..shapeType = 0
      ..shapeColor = Colors.black
      ..shapeStyle = PaintingStyle.stroke
      ..shapeWidth = 5
      ..font = 'default'
      ..typoWeight = 3
      ..textColor = Colors.black;

    selectables = List();
    isSelectedMode = false;
  }

  @override
  Widget build(BuildContext context) {
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
  bool updateShouldNotify(InheritedConfig oldWidget) => oldWidget != this;
}
