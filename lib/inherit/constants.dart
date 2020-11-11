enum MainTool { background, pen, shape, text, image, more }

enum LeafTool {
  backgroundColor,

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
  rotate
}

const penToolNum = 0;
const shapeToolNum = 1;
const typoToolNum = 2;
const shapeFillNum = 3;
const backgroundColorNum = 4;
