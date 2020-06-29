import 'package:flutter/material.dart';

enum MainTool { background, pen, shape, text, image, more }

enum LeafTool {
  pen_color,
  pen_width,

  shape_type,
  shape_color,
  shape_style,
  shape_width,

  text_text,
  text_font,
  text_color,
  text_weight,

  align,
}

const penToolNum = 0;
const shapeToolNum = 1;
const typoToolNum = 2;
const shapeFillNum = 3;
const backgroundColorNum = 4;

var colorList = [
  Colors.black,
  Colors.white,
  Colors.red,
  Colors.orange,
  Colors.yellow,
  Colors.green,
  Colors.blue,
  Colors.purple
];
