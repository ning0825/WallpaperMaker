import 'dart:ui';

import 'package:flutter/material.dart';

enum ShapeType {
  line,
  rect,
  circle,
}

class Configuration {
  //Background color
  Color bgColor;

  // Paint configuration
  Color penColor;
  double penWidth;

  //Shape configuration
  ///0:line.
  ///1:rect
  ///2:cirle
  int shapeType;
  Color shapeColor;
  PaintingStyle shapeStyle;
  Color shapeFillColor;
  double shapeWidth;

  //Typo configuration
  String text;
  String font;
  int typoWeight;
  Color textColor;

  Color frameColor;
  double frameWidth;
}
