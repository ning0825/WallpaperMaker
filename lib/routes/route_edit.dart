import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide Image hide SelectableText;
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wallpaper_maker/beans/selectable_bean.dart';
import 'package:wallpaper_maker/cus_widgets/cus_painter.dart';
import 'package:wallpaper_maker/inherit/constants.dart';
import 'package:wallpaper_maker/inherit/inherited_config.dart';
import 'package:wallpaper_maker/routes/route_clip.dart';
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

  AnimationController controller;
  Animation leafToolAnimation;

  bool offStage = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      size = rpbKey.currentContext.size;
    });

    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    leafToolAnimation = controller.drive(Tween<double>(begin: 0.0, end: 1.0)
        .chain(CurveTween(curve: Curves.easeInBack)));
    leafToolAnimation.addListener(() {
      if (leafToolAnimation.isCompleted && leafToolAnimation.value == 0.0) {
        setState(() {
          offStage = true;
        });
      }
    });
  }

  //show leaf tool
  startAnima() {
    controller.forward();
    setState(() {
      offStage = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    mContext = context;
    data = ConfigWidget.of(context);
    return Scaffold(
      body: Container(
        child: Stack(children: [
          Column(
            children: [
              Expanded(child: CanvasPanel(rpbKey)),
              BottomToolbar(
                controller: startAnima,
              )
            ],
          ),
          Positioned(
            child: _buildAnimatedLeafTools(),
            bottom: 120,
          )
        ]),
      ),
    );
  }

  _buildAnimatedLeafTools() {
    return Offstage(
      offstage: offStage,
      child: FadeTransition(
        opacity: leafToolAnimation,
        child: _buildLeafTools(),
      ),
    );
  }

  _buildLeafTools() {
    return Container(
      color: Colors.green,
      width: MediaQuery.of(context).size.width - 16,
      margin: EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: _getLeafTool(data.currentLeafTool),
          ),
          IconButton(
            icon: Icon(
              Icons.close,
            ),
            onPressed: () => controller.reverse(),
          ),
        ],
      ),
    );
  }

  Widget _getLeafTool(LeafTool leafTool) {
    var result;
    if (leafTool != null) {
      switch (leafTool) {
        case LeafTool.pen_color:
          result = ColorWidget(toolNum: penToolNum);
          break;
        case LeafTool.pen_width:
          result = WidthWidget(toolNum: penToolNum);
          break;
        case LeafTool.shape_type:
          result = Row(
            children: <Widget>[
              RaisedButton(
                onPressed: () => data.setShapeType(0),
                child: Text('line'),
              ),
              RaisedButton(
                onPressed: () => data.setShapeType(1),
                child: Text('rect'),
              ),
              RaisedButton(
                onPressed: () => data.setShapeType(2),
                child: Text('circle'),
              ),
            ],
          );
          break;
        case LeafTool.shape_color:
          result = ColorWidget(toolNum: shapeToolNum);
          break;
        case LeafTool.shape_style:
          result = ColorWidget(toolNum: shapeFillNum);
          break;
        case LeafTool.shape_width:
          result = WidthWidget(toolNum: shapeToolNum);
          break;
        case LeafTool.text_text:
          result = TypoTextWidget();
          break;
        case LeafTool.text_font:
          result = TypoFontWidget();
          break;
        case LeafTool.text_color:
          result = ColorWidget(toolNum: typoToolNum);
          break;
        case LeafTool.text_weight:
          result = WidthWidget(toolNum: typoToolNum);
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

class BottomToolbar extends StatefulWidget {
  BottomToolbar({Key key, this.controller}) : super(key: key);

  final VoidCallback controller;

  @override
  _BottomToolbarState createState() => _BottomToolbarState();
}

class _BottomToolbarState extends State<BottomToolbar> {
  ConfigWidgetState data;
  var toolIconList = ['palette', 'pen', 'geometry', 'typo', 'image', 'save'];

  @override
  Widget build(BuildContext context) {
    data = ConfigWidget.of(context);
    return Container(
      height: 120,
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
          children: _getSubtool(mainTool),
        ),
      ),
    );
  }

  ClipImageBean clipImageBean;

  List<Widget> _getSubtool(MainTool mainTool) {
    var result;
    switch (mainTool) {
      case MainTool.background:
        result = [ColorWidget(toolNum: backgroundColorNum)];
        break;
      case MainTool.pen:
        result = [
          RaisedButton(
            child: Text('color'),
            onPressed: () {
              data.setCurrentLeafTool(LeafTool.pen_color);
              widget.controller();
            },
          ),
          RaisedButton(
            child: Text('width'),
            onPressed: () {
              data.setCurrentLeafTool(LeafTool.pen_width);
              widget.controller();
            },
          ),
        ];
        break;
      case MainTool.shape:
        result = [
          RaisedButton(
            child: Text('type'),
            onPressed: () {
              data.setCurrentLeafTool(LeafTool.shape_type);
              widget.controller();
            },
          ),
          RaisedButton(
            child: Text('color'),
            onPressed: () {
              data.setCurrentLeafTool(LeafTool.shape_color);
              widget.controller();
            },
          ),
          RaisedButton(
            child: Text('style'),
            onPressed: () {
              data.setCurrentLeafTool(LeafTool.shape_style);
              widget.controller();
            },
          ),
          RaisedButton(
            child: Text('width'),
            onPressed: () {
              data.setCurrentLeafTool(LeafTool.shape_width);
              widget.controller();
            },
          ),
        ];
        break;
      case MainTool.text:
        result = [
          RaisedButton(
            child: Text('text'),
            onPressed: () {
              data.setCurrentLeafTool(LeafTool.text_text);
              widget.controller.call();
            },
          ),
          RaisedButton(
            child: Text('font'),
            onPressed: () {
              data.setCurrentLeafTool(LeafTool.text_font);
              widget.controller.call();
            },
          ),
          RaisedButton(
            child: Text('weight'),
            onPressed: () {
              data.setCurrentLeafTool(LeafTool.text_weight);
              widget.controller.call();
            },
          ),
          RaisedButton(
            child: Text('color'),
            onPressed: () {
              data.setCurrentLeafTool(LeafTool.text_color);
              widget.controller.call();
            },
          ),
        ];
        break;
      case MainTool.image:
        result = [
          RaisedButton(
            child: Text('image'),
            onPressed: () {
              _addImage();
            },
          ),
          RaisedButton(
              child: Text('crop'),
              onPressed: () async {
                if (clipImageBean == null) {
                  clipImageBean = ClipImageBean(
                      (data.currentSelectable as SelectableImage).img);
                }
                clipImageBean =
                    await Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ClipRoute(clipImageBean),
                ));
                data.setImageClip(clipImageBean.clipRect);
              }),
          RaisedButton(
            child: Text('frame'),
            onPressed: null,
          ),
        ];
        break;
      case MainTool.more:
        result = [
          RaisedButton(
            child: Text('save'),
            onPressed: () async {
              List<Map<String, dynamic>> list = [
                {
                  'background': {'background': data.getBackroundColor().value}
                }
              ];
              data.selectables.forEach((element) {
                list.add({element.runtimeType.toString(): element});
              });

              String jsonString = jsonEncode(list);
              String name = DateTime.now().millisecondsSinceEpoch.toString();
              await saveImage(rpbKey, mContext,
                  data.size2Save.width / data.size.width, name);
              await saveJson(name, jsonString);
              data.clear();
            },
          ),
        ];
        break;
      default:
        break;
    }
    return result;
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
          ToolButton(
            icon: toolIconList[0],
            color: data.currentMainTool == MainTool.background
                ? Colors.white
                : Colors.grey,
            onTap: () {
              data.setCurrentMainTool(MainTool.background);
              data.setUnselected();
            },
          ),
          //pen
          ToolButton(
            icon: toolIconList[1],
            color: data.currentMainTool == MainTool.pen
                ? Colors.white
                : Colors.grey,
            onTap: () {
              data.setCurrentMainTool(MainTool.pen);
              data.setUnselected();
            },
          ),
          //shape
          ToolButton(
            icon: toolIconList[2],
            color: data.currentMainTool == MainTool.shape
                ? Colors.white
                : Colors.grey,
            onTap: () {
              data.setCurrentMainTool(MainTool.shape);
              data.setUnselected();
            },
          ),
          //text
          ToolButton(
            icon: toolIconList[3],
            color: data.currentMainTool == MainTool.text
                ? Colors.white
                : Colors.grey,
            onTap: () {
              data.setCurrentMainTool(MainTool.text);
              data.setUnselected();
            },
          ),
          //image
          ToolButton(
            icon: toolIconList[4],
            color: data.currentMainTool == MainTool.image
                ? Colors.white
                : Colors.grey,
            onTap: () {
              data.setCurrentMainTool(MainTool.image);
              data.setUnselected();
            },
          ),
          //more
          ToolButton(
            icon: toolIconList[5],
            color: data.currentMainTool == MainTool.more
                ? Colors.white
                : Colors.grey,
            onTap: () => data.setCurrentMainTool(MainTool.more),
          ),
        ],
      ),
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
      child: InkWell(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SvgPicture.asset(
            'assets/icons/' + icon + '.svg',
            width: 30,
            height: 30,
            color: color,
          ),
        ),
        onTap: onTap,
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
        child: SvgPicture.asset(
          'assets/icons/' + icon + '.svg',
          width: 40,
          height: 40,
          color: Colors.white,
        ),
      ),
      onTap: onTap,
    );
  }
}

class ColorWidget extends StatefulWidget {
  final int toolNum;

  ColorWidget({@required this.toolNum});

  @override
  _ColorWidgetState createState() => _ColorWidgetState();
}

class _ColorWidgetState extends State<ColorWidget> {
  ConfigWidgetState data;

  @override
  Widget build(BuildContext context) {
    data = ConfigWidget.of(context);
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 120,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          widget.toolNum == shapeFillNum
              ? Checkbox(
                  value: data.getShapeStyle(),
                  onChanged: (b) {
                    setState(() {});
                    data.setShapeStyle(
                        b ? PaintingStyle.fill : PaintingStyle.stroke);
                  },
                )
              : SizedBox(
                  width: 0,
                  height: 0,
                ),
          Expanded(
            child: ListView.builder(
              itemCount: colorList.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, index) => InkWell(
                onTap: () => setColorTap(index),
                child: Center(
                  child: Container(
                    margin: EdgeInsets.all(8),
                    width: getSizeValue(index),
                    height: getSizeValue(index),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                      color: colorList[index],
                      border: Border.all(
                          color: Colors.white,
                          width: 5,
                          style: BorderStyle.solid),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void setColorTap(int index) {
    switch (widget.toolNum) {
      case penToolNum:
        data.setPenColor(colorList[index]);
        break;
      case shapeToolNum:
        data.setShapeColor(colorList[index]);
        break;
      case typoToolNum:
        data.setTextColor(colorList[index]);
        break;
      case shapeFillNum:
        data.setShapeFillColor(colorList[index]);
        break;
      case backgroundColorNum:
        data.setBackgroundColor(colorList[index]);
        break;
      default:
        break;
    }
  }

  double getSizeValue(int index) {
    switch (widget.toolNum) {
      case penToolNum:
        return data.getPenColor().value == colorList[index].value ? 60 : 40;
        break;
      case shapeToolNum:
        return data.getShapeColor().value == colorList[index].value ? 60 : 40;
        break;
      case typoToolNum:
        return data.getTextColor().value == colorList[index].value ? 60 : 40;
        break;
      case shapeFillNum:
        if (data.getShapeFillColor() != null &&
            data.getShapeFillColor().value == colorList[index].value) {
          return 60;
        } else {
          return 40;
        }
        break;
      case backgroundColorNum:
        return data.getBackroundColor().value == colorList[index].value
            ? 60
            : 40;
      default:
        break;
    }
    return 10;
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
      height: 70,
      child: Slider(
        value: getToolWidth(),
        onChanged: (value) {
          setToolWidth(value);
        },
        min: 1.0,
        max: 8.0,
        label: sliderValue.toString(),
        activeColor: Colors.black,
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
          itemCount: fontList.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (_, index) {
            return ListTile(
              selected: index == 0 ? true : false,
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
                data.assembleSelectableText(
                  controller.text,
                  Offset(size.height / 2 / 2, size.height / 2),
                ),
              );
              data.setSeleteLast();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
