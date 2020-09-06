import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:image_picker/image_picker.dart';
import 'package:wallpaper_maker/beans/selectable_bean.dart';
import 'package:wallpaper_maker/cus_widgets/cus_painter.dart';
import 'package:wallpaper_maker/inherit/constants.dart';
import 'package:wallpaper_maker/inherit/inherited_config.dart';
import 'package:wallpaper_maker/routes/route_clip.dart';
import 'package:wallpaper_maker/routes/route_library.dart';
import 'package:wallpaper_maker/cus_widgets/cus_widget.dart';
import 'package:wallpaper_maker/utils/utils.dart';

GlobalKey rpbKey = GlobalKey();
Size size;
BuildContext mContext;

class EditRoute extends StatefulWidget {
  @override
  _EditRouteState createState() => _EditRouteState();
}

class _EditRouteState extends State<EditRoute>
    with SingleTickerProviderStateMixin {
  ConfigWidgetState data;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      size = rpbKey.currentContext.size;
    });
  }

  @override
  Widget build(BuildContext context) {
    mContext = context;
    data = ConfigWidget.of(context);

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Column(
              children: [
                Container(height: 50, child: TopToolbar()),
                Expanded(child: CanvasPanel(rpbKey)),
                BottomToolbar()
              ],
            ),
            Positioned(
              child: Container(
                child: _buildAnimatedLeafTools(),
              ),
              bottom: data.bottom,
              top: data.top,
            ),
          ],
        ),
      ),
    );
  }

  _buildAnimatedLeafTools() {
    return Offstage(
      offstage: data.offStage,
      child: FadeTransition(
        opacity: data.leafToolAnimation,
        child: _buildLeafTools(),
      ),
    );
  }

  _buildLeafTools() {
    return Container(
      decoration: ShapeDecoration(
        shape: MessageBoxBorder(
          color: Colors.black87,
          position: data.position,
          direction: data.direction,
        ),
      ),
      margin: EdgeInsets.all(8.0),
      padding: EdgeInsets.all(10.0),
      child: _getLeafTool(data.currentLeafTool),
    );
  }

  Widget _getLeafTool(LeafTool leafTool) {
    var result;
    if (leafTool != null) {
      switch (leafTool) {
        case LeafTool.backgroundColor:
          result = Container(
            width: MediaQuery.of(context).size.width - 36,
            child: PaletteWidget(onColorPick: (color) {
              data.setBackgroundColor(color);
            }),
          );
          break;
        case LeafTool.align:
          result = Container(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.format_align_left, color: Colors.white),
                  onPressed: () => data.setLeftAlign(),
                ),
                IconButton(
                  icon: Icon(Icons.format_align_right, color: Colors.white),
                  onPressed: () => data.setRightAlign(),
                ),
                IconButton(
                  icon: Icon(Icons.vertical_align_top, color: Colors.white),
                  onPressed: () => data.setTopAlign(),
                ),
                IconButton(
                  icon: Icon(Icons.vertical_align_bottom, color: Colors.white),
                  onPressed: () => data.setBottomAlign(),
                ),
                IconButton(
                  icon: Icon(Icons.vertical_align_center, color: Colors.white),
                  onPressed: () => data.setCenterVerticalAlign(),
                ),
                IconButton(
                  icon: Icon(Icons.border_horizontal, color: Colors.white),
                  onPressed: () => data.setCenterHorizonAlign(),
                ),
              ],
            ),
          );
          break;
        case LeafTool.pen_color:
          result = Container(
            width: MediaQuery.of(context).size.width - 36,
            child: PaletteWidget(onColorPick: (color) {
              data.setPenColor(color);
            }),
          );
          break;
        case LeafTool.pen_width:
          result = WidthWidget(toolNum: penToolNum);
          break;
        case LeafTool.shape_type:
          result = Row(
            children: <Widget>[
              IconButton(
                onPressed: () => data.setShapeType(0),
                icon: Image.asset('assets/icons/shape_line.png'),
              ),
              IconButton(
                onPressed: () => data.setShapeType(1),
                icon: Image.asset('assets/icons/shape_square.png'),
              ),
              IconButton(
                onPressed: () => data.setShapeType(2),
                icon: Image.asset('assets/icons/shape_circle.png'),
              ),
            ],
          );
          break;
        case LeafTool.shape_color:
          result = Container(
            width: MediaQuery.of(context).size.width - 36,
            child: PaletteWidget(onColorPick: (color) {
              data.setShapeColor(color);
            }),
          );
          break;
        case LeafTool.shape_style:
          result = Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4),
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width - 36,
                height: 30,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Text(
                  'transparent',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(
                height: 4,
              ),
              Container(
                width: MediaQuery.of(context).size.width - 36,
                child: PaletteWidget(onColorPick: (color) {
                  data.setShapeFillColor(color);
                }),
              ),
            ],
          );
          break;
        case LeafTool.shape_width:
          result = WidthWidget(toolNum: shapeToolNum);
          break;
        case LeafTool.text_text:
          result = Container(
              width: MediaQuery.of(context).size.width - 36,
              child: TypoTextWidget());
          break;
        case LeafTool.text_font:
          result = Container(
              width: MediaQuery.of(context).size.width - 36,
              child: TypoFontWidget());
          break;
        case LeafTool.text_color:
          result = Container(
            width: MediaQuery.of(context).size.width - 36,
            child: PaletteWidget(onColorPick: (color) {
              data.setTextColor(color);
            }),
          );
          break;
        case LeafTool.text_weight:
          result = WidthWidget(toolNum: typoToolNum);
          break;
        case LeafTool.align:
          result = Container(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                RaisedButton(
                  onPressed: () => data.setTopAlign(),
                  child: Text('top'),
                ),
                RaisedButton(
                  onPressed: () => data.setBottomAlign(),
                  child: Text('bottom'),
                ),
                RaisedButton(
                  onPressed: () => data.setLeftAlign(),
                  child: Text('left'),
                ),
                RaisedButton(
                  onPressed: () => data.setRightAlign(),
                  child: Text('right'),
                ),
                RaisedButton(
                  onPressed: () => data.setCenterHorizonAlign(),
                  child: Text('CenterHorizon'),
                ),
                RaisedButton(
                  onPressed: () => data.setCenterVerticalAlign(),
                  child: Text('CenterVertical'),
                ),
              ],
            ),
          );
          break;
        default:
          break;
      }
    } else {
      result = Container();
    }

    return result;
  }
}

class TopToolbar extends StatefulWidget {
  @override
  _TopToolbarState createState() => _TopToolbarState();
}

class _TopToolbarState extends State<TopToolbar> {
  ConfigWidgetState data;

  GlobalKey backgroundBtKey;
  GlobalKey alignBtKey;

  @override
  void initState() {
    super.initState();

    backgroundBtKey = GlobalKey();
    alignBtKey = GlobalKey();
  }

  @override
  Widget build(BuildContext context) {
    data = ConfigWidget.of(context);

    return Container(
      color: Colors.black,
      width: double.infinity,
      alignment: Alignment.centerRight,
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Spacer(),
          Flexible(
            child: IconButton(
              key: backgroundBtKey,
              onPressed: () {
                data.setLeafToolTop();
                data.setCurrentLeafTool(LeafTool.backgroundColor);
                data.setIndicatorPosition(backgroundBtKey);
                data.toggleLeafTool();
              },
              icon: Container(
                margin: EdgeInsets.all(8),
                width: 20,
                height: 20,
                color: data.getBackroundColor(),
              ),
            ),
          ),
          Expanded(
            child: IconButton(
                key: alignBtKey,
                disabledColor: Colors.grey,
                color: Colors.white,
                icon: Icon(Icons.format_align_center),
                onPressed: data.isSelectedMode
                    ? () {
                        data.setLeafToolTop();
                        data.setCurrentLeafTool(LeafTool.align);
                        data.setIndicatorPosition(alignBtKey);
                        data.toggleLeafTool();
                      }
                    : null),
          ),
          //delete
          Expanded(
            child: IconButton(
              icon: Image.asset(
                'assets/icons/remove.png',
                width: 20,
                height: 20,
                color: data.isSelectedMode ? Colors.white : Colors.grey,
              ),
              onPressed: () =>
                  data.isSelectedMode ? data.removeCurrentSelected() : null,
            ),
          ),
          //undo
          Expanded(
            child: IconButton(
              icon: Image.asset(
                'assets/icons/undo.png',
                width: 20,
                height: 20,
              ),
              onPressed: () => data.undo(),
            ),
          ),
          //clear
          Expanded(
            child: IconButton(
              icon: Image.asset(
                'assets/icons/trash.png',
                width: 20,
                height: 20,
              ),
              onPressed: () => data.clean(),
            ),
          ),
          Expanded(
            child: IconButton(
              icon: Image.asset(
                'assets/icons/save.png',
                width: 20,
                height: 20,
              ),
              onPressed: () async {
                List<Map<String, dynamic>> list = [
                  {
                    'background': {'background': data.getBackroundColor().value}
                  }
                ];
                data.selectables.forEach((element) {
                  list.add({element.runtimeType.toString(): element});
                });

                if (!data.newCanva) {
                  await SeletectableImgFile(imgPath: data.currentEditImgPath)
                      .delete();
                }

                String jsonString = jsonEncode(list);
                String name = DateTime.now().millisecondsSinceEpoch.toString();
                await saveImage(rpbKey, mContext,
                    data.size2Save.width / data.size.width, name);
                await saveJson(name, jsonString);
                data.reset();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class BottomToolbar extends StatefulWidget {
  BottomToolbar({Key key}) : super(key: key);

  @override
  _BottomToolbarState createState() => _BottomToolbarState();
}

class _BottomToolbarState extends State<BottomToolbar> {
  ConfigWidgetState data;
  static const toolIconList = ['pen', 'shape', 'font', 'image'];

  double height = 130;

  GlobalKey penColorKey = GlobalKey();
  GlobalKey penWidthKey = GlobalKey();
  GlobalKey shapeTypeKey = GlobalKey();
  GlobalKey shapeColorKey = GlobalKey();
  GlobalKey shapeFillTypeKey = GlobalKey();
  GlobalKey shapeWidthKey = GlobalKey();
  GlobalKey typoTextKey = GlobalKey();
  GlobalKey typoFontKey = GlobalKey();
  GlobalKey typoFontWeightKey = GlobalKey();
  GlobalKey typoColorKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    data = ConfigWidget.of(context);
    return Container(
      height: height,
      color: Colors.black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildSubtools(data.currentMainTool)),
          _buildMainTools()
        ],
      ),
    );
  }

  _buildSubtools(MainTool mainTool) {
    return Container(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: _getSubtool(mainTool),
        ),
      ),
    );
  }

  ClipImageBean clipImageBean;

  List<Widget> _getSubtool(MainTool mainTool) {
    var result;
    switch (mainTool) {
      case MainTool.pen:
        result = [
          IconButton(
            key: penColorKey,
            iconSize: 50,
            icon: ColorWidget(data.getPenColor()),
            onPressed: () {
              data.setCurrentLeafTool(LeafTool.pen_color);
              data.setLeafToolBottom();
              data.setIndicatorPosition(penColorKey);
              data.toggleLeafTool();
            },
          ),
          IconButton(
            key: penWidthKey,
            icon: Text(
              data.getPenWidth().truncate().toString(),
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () {
              data.setCurrentLeafTool(LeafTool.pen_width);
              data.setLeafToolBottom();
              data.setIndicatorPosition(penWidthKey);
              data.toggleLeafTool();
            },
          ),
        ];
        break;
      case MainTool.shape:
        result = [
          IconButton(
            key: shapeTypeKey,
            icon: _getShapeIcon(data.getShapeType()),
            onPressed: () {
              data.setCurrentLeafTool(LeafTool.shape_type);
              data.setLeafToolBottom();
              data.setIndicatorPosition(shapeTypeKey);
              data.toggleLeafTool();
            },
          ),
          IconButton(
            key: shapeColorKey,
            iconSize: 50,
            icon: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                  color: data.getShapeColor(),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white, width: 1.0)),
            ),
            onPressed: () {
              data.setCurrentLeafTool(LeafTool.shape_color);
              data.setLeafToolBottom();
              data.setIndicatorPosition(shapeColorKey);
              data.toggleLeafTool();
            },
          ),
          IconButton(
              key: shapeFillTypeKey,
              icon: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: data.getShapeStyle()
                      ? data.getShapeFillColor()
                      : Colors.transparent,
                  border: Border.all(color: data.getShapeColor(), width: 5),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                data.setCurrentLeafTool(LeafTool.shape_style);
                data.setLeafToolBottom();
                data.setIndicatorPosition(shapeFillTypeKey);
                data.toggleLeafTool();
              }),
          IconButton(
            key: shapeWidthKey,
            icon: Text(
              data.getShapeWidth().toInt().toString(),
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () {
              data.setCurrentLeafTool(LeafTool.shape_width);
              data.setLeafToolBottom();
              data.setIndicatorPosition(shapeWidthKey);
              data.toggleLeafTool();
            },
          ),
        ];
        break;
      case MainTool.text:
        result = [
          IconButton(
            key: typoTextKey,
            iconSize: 50,
            icon: Icon(Icons.space_bar),
            onPressed: () {
              data.setCurrentLeafTool(LeafTool.text_text);
              data.setLeafToolBottom();
              data.setIndicatorPosition(typoTextKey);
              data.toggleLeafTool();
            },
          ),
          IconButton(
            key: typoFontKey,
            icon: Text(
              'F',
              style: TextStyle(
                  textBaseline: TextBaseline.ideographic,
                  fontFamily: data.getTextFont(),
                  color: Colors.white,
                  fontSize: 28),
            ),
            onPressed: () {
              data.setCurrentLeafTool(LeafTool.text_font);
              data.setLeafToolBottom();
              data.setIndicatorPosition(typoFontKey);
              data.toggleLeafTool();
            },
          ),
          IconButton(
            key: typoFontWeightKey,
            icon: Text(
              data.getTextWeight().toString(),
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () {
              data.setCurrentLeafTool(LeafTool.text_weight);
              data.setLeafToolBottom();
              data.setIndicatorPosition(typoFontWeightKey);
              data.toggleLeafTool();
            },
          ),
          IconButton(
            key: typoColorKey,
            icon: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: data.getTextColor(),
                  border: Border.all(width: 1, color: Colors.white)),
            ),
            onPressed: () {
              data.setCurrentLeafTool(LeafTool.text_color);
              data.setLeafToolBottom();
              data.setIndicatorPosition(typoColorKey);
              data.toggleLeafTool();
            },
          ),
        ];
        break;
      case MainTool.image:
        result = [
          IconButton(
            iconSize: 50,
            icon: Image.asset(
              'assets/icons/image_pick.png',
              width: 30,
              height: 30,
            ),
            onPressed: () {
              _addImage();
            },
          ),
          IconButton(
              iconSize: 50,
              color: Colors.white,
              disabledColor: Colors.grey,
              icon: Icon(
                Icons.crop,
                size: 30,
              ),
              onPressed: data.isSelectedMode
                  ? () async {
                      if (clipImageBean == null) {
                        clipImageBean = ClipImageBean(
                            (data.currentSelectable as SelectableImage).img);
                      }
                      clipImageBean =
                          await Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ClipRoute(clipImageBean),
                      ));
                      data.setImageClip(clipImageBean.clipRect);
                    }
                  : null),
          RaisedButton(
            child: Text('frame'),
            onPressed: null,
          ),
        ];
        break;
      default:
        break;
    }
    return result;
  }

  Widget _getShapeIcon(int shapeType) {
    switch (shapeType) {
      case 0:
        return Image.asset('assets/icons/shape_line.png');
        break;
      case 1:
        return Image.asset('assets/icons/shape_square.png');
        break;
      case 2:
        return Image.asset('assets/icons/shape_circle.png');
        break;
      default:
        break;
    }
    return Container();
  }

  _addImage() async {
    String _filePath = await ImagePicker()
        .getImage(source: ImageSource.gallery)
        .then((value) => value?.path);
    if (_filePath == null) return;
    File _fileImage = File(_filePath);
    if (_fileImage == null) return;
    ui.Image img = await decodeImageFromList(await _fileImage.readAsBytes());
    //Add an image that will be drawn on the center of canvas.
    var size = rpbKey.currentContext.size;
    data.addSelectable(
      SelectableImage(
          img: img,
          mOffset: Offset(size.width / 2, size.height / 2),
          width: size.width),
    );
  }

  _buildMainTools() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: [
          //pen
          ToolButton(
            icon: toolIconList[0],
            color: data.currentMainTool == MainTool.pen
                ? Colors.white
                : Colors.grey[600],
            onTap: () {
              data.setCurrentMainTool(MainTool.pen);
              data.setUnselected();
              data.hideLeafTool();
            },
          ),
          //shape
          ToolButton(
            icon: toolIconList[1],
            color: data.currentMainTool == MainTool.shape
                ? Colors.white
                : Colors.grey,
            onTap: () {
              data.setCurrentMainTool(MainTool.shape);
              data.setUnselected();
              data.hideLeafTool();
            },
          ),
          //text
          ToolButton(
            icon: toolIconList[2],
            color: data.currentMainTool == MainTool.text
                ? Colors.white
                : Colors.grey,
            onTap: () {
              data.setCurrentMainTool(MainTool.text);
              data.setUnselected();
              data.hideLeafTool();
            },
          ),
          //image
          ToolButton(
            icon: toolIconList[3],
            color: data.currentMainTool == MainTool.image
                ? Colors.white
                : Colors.grey,
            onTap: () {
              data.setCurrentMainTool(MainTool.image);
              data.setUnselected();
              data.hideLeafTool();
            },
          ),
        ],
      ),
    );
  }
}

class ColorWidget extends StatelessWidget {
  ColorWidget(this.color);

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 1),
          borderRadius: BorderRadius.circular(15),
          color: color),
    );
  }
}

class ToolButton extends StatelessWidget {
  ToolButton({this.icon, this.onTap, this.color});

  final String icon;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: IconButton(
          icon: Image.asset(
            'assets/icons/' + icon + '.png',
            color: color,
          ),
          onPressed: onTap,
        ),
      ),
    );
  }
}

class SubtoolButton extends StatelessWidget {
  SubtoolButton({this.icon, this.onTap});

  final String icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(
          icon,
          style: TextStyle(color: Colors.white),
        ),
      ),
      onTap: onTap,
    );
  }
}

class WidthWidget extends StatefulWidget {
  final int toolNum;

  WidthWidget({@required this.toolNum});

  @override
  _BuildWidthState createState() => _BuildWidthState();
}

class _BuildWidthState extends State<WidthWidget> {
  double sliderValue = 1.0;
  ConfigWidgetState data;

  @override
  Widget build(BuildContext context) {
    data = ConfigWidget.of(context);
    return Container(
      width: MediaQuery.of(context).size.width - 36,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: MediaQuery.of(context).size.width - 36,
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: CustomPaint(
              painter:
                  WidthPicker(width: getToolWidth(), color: getToolColor()),
              size: Size.fromHeight(60),
            ),
          ),
          Slider(
            value: getToolWidth(),
            onChanged: (value) {
              setToolWidth(value);
            },
            min: 1.0,
            max: 8.0,
            label: sliderValue.toString(),
            activeColor: Colors.yellow,
          ),
        ],
      ),
    );
  }

  setToolWidth(double value) {
    switch (widget.toolNum) {
      case penToolNum:
        data.setPenWidth(value);
        break;
      case shapeToolNum:
        data.setShapeWidth(value);
        break;
      case typoToolNum:
        data.setTextWeight(value);
        break;
      default:
        break;
    }
  }

  double getToolWidth() {
    switch (widget.toolNum) {
      case penToolNum:
        return data.getPenWidth();
      case shapeToolNum:
        return data.getShapeWidth();
      case typoToolNum:
        return data.getTextWeight().toDouble();
      default:
        break;
    }
    return 1.0;
  }

  Color getToolColor() {
    switch (widget.toolNum) {
      case penToolNum:
        return data.getPenColor();
      case shapeToolNum:
        return data.getShapeColor();
      case typoToolNum:
        return data.getTextColor();
      default:
        break;
    }
    return Colors.black;
  }
}

class TypoFontWidget extends StatefulWidget {
  @override
  _TypoFontWidgetState createState() => _TypoFontWidgetState();
}

class _TypoFontWidgetState extends State<TypoFontWidget> {
  ConfigWidgetState data;
  var fontList = ['default', 'polingo', 'PlayfairDisplay'];
  String currentFont;

  @override
  Widget build(BuildContext context) {
    data = ConfigWidget.of(context);
    currentFont = data.getTextFont();
    return Container(
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: fontList.length,
          itemBuilder: (_, index) {
            return ListTile(
              selected: fontList[index] == data.getTextFont(),
              title: Text(
                fontList[index],
                style: TextStyle(fontFamily: fontList[index]),
              ),
              onTap: () {
                data.setTextFont(fontList[index]);
              },
            );
          }),
    );
  }
}

class TypoTextWidget extends StatefulWidget {
  @override
  _TypoTextWidgetState createState() => _TypoTextWidgetState();
}

class _TypoTextWidgetState extends State<TypoTextWidget> {
  TextEditingController controller;
  ConfigWidgetState data;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    data = ConfigWidget.of(context);
    controller.text = data.getText();
    return Container(
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
            ),
          ),
          RaisedButton(
            onPressed: () {
              data.addSelectable(
                data.assembleSelectableTypo(
                    controller.text,
                    Offset(size.height / 2 / 2, size.height / 2),
                    data.size.width - 20),
              );
              data.setSeleteLast();

              //Hide soft keyboard
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
