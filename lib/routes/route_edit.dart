import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide Image hide SelectableText;
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
      if (leafToolAnimation.isDismissed && leafToolAnimation.value == 0.0) {
        setState(() {
          offStage = true;
        });
      }
    });
  }

  //show leaf tool
  showLeafTool() {
    controller.forward();
    setState(() {
      offStage = false;
    });
  }

  hideLeafTool() {
    controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    mContext = context;
    data = ConfigWidget.of(context);
    return SafeArea(
      child: Scaffold(
        body: Container(
          child: Stack(
            children: [
              Column(
                children: [
                  TopToolbar(showLeafTool),
                  Expanded(child: CanvasPanel(rpbKey)),
                  BottomToolbar(
                    showLeafTool: showLeafTool,
                    hideLeafTool: hideLeafTool,
                  )
                ],
              ),
              Positioned(
                child: Container(
                  child: _buildAnimatedLeafTools(),
                ),
                bottom: 130,
                // top: 50,
              ),
            ],
          ),
        ),
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

  double position = 20;
  MessageBoxDirection direction = MessageBoxDirection.bottom;

  _buildLeafTools() {
    return Container(
      decoration: ShapeDecoration(
        shape: MessageBoxBorder(
          color: Colors.yellow[300],
          position: position,
          direction: direction,
        ),
      ),
      width: MediaQuery.of(context).size.width - 16,
      margin: EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(child: _getLeafTool(data.currentLeafTool)),
          IconButton(
            icon: Icon(
              Icons.close,
              color: Colors.green,
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
        case LeafTool.backgroundColor:
          result = Container(
            width: 350,
            height: 350,
            child: ColorPicker((color) {
              data.setBackgroundColor(color);
            }),
          );
          break;
        case LeafTool.align:
          result = Container(
            child: Row(
              children: [
                IconButton(
                    icon: Icon(Icons.format_align_left), onPressed: null),
                IconButton(
                    icon: Icon(Icons.format_align_right), onPressed: null),
                IconButton(
                    icon: Icon(Icons.vertical_align_top), onPressed: null),
                IconButton(
                    icon: Icon(Icons.vertical_align_bottom), onPressed: null),
                IconButton(
                    icon: Icon(Icons.vertical_align_center), onPressed: null),
                IconButton(
                    icon: Icon(Icons.border_horizontal), onPressed: null),
              ],
            ),
          );
          break;
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
  TopToolbar(this.showLeafTool);

  final VoidCallback showLeafTool;

  @override
  _TopToolbarState createState() => _TopToolbarState();
}

class _TopToolbarState extends State<TopToolbar> {
  ConfigWidgetState data;

  GlobalKey key;

  @override
  void initState() {
    super.initState();

    key = GlobalKey();
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
            child: InkWell(
              onTap: () {
                data.setCurrentLeafTool(LeafTool.backgroundColor);
                widget.showLeafTool();
                String s = (key.currentContext.findRenderObject() as RenderBox)
                    .paintBounds
                    .bottom
                    .toString();
                print('background bottom' + s);
              },
              child: Container(
                key: key,
                margin: EdgeInsets.all(8),
                width: 20,
                height: 30,
                color: data.getBackroundColor(),
              ),
            ),
          ),
          Expanded(
            child: IconButton(
                icon: Image.asset(
                  'assets/icons/align_left.png',
                  width: 20,
                  height: 20,
                ),
                onPressed: () {
                  data.setCurrentLeafTool(LeafTool.align);
                  widget.showLeafTool();
                }),
          ),
          //delete
          Expanded(
            child: IconButton(
              icon: Image.asset(
                'assets/icons/remove.png',
                width: 20,
                height: 20,
              ),
              onPressed: () => data.removeCurrentSelected(),
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
              onPressed: () => data.reset(),
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
  BottomToolbar({Key key, this.showLeafTool, this.hideLeafTool})
      : super(key: key);

  final VoidCallback showLeafTool;
  final VoidCallback hideLeafTool;

  @override
  _BottomToolbarState createState() => _BottomToolbarState();
}

class _BottomToolbarState extends State<BottomToolbar> {
  ConfigWidgetState data;
  static const toolIconList = ['pen', 'shape', 'font', 'image'];

  double height = 130;

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
      case MainTool.background:
        result = [ColorWidget(toolNum: backgroundColorNum)];
        break;
      case MainTool.pen:
        result = [
          IconButton(
            icon: Image.asset('assets/icons/pen_color.png'),
            onPressed: () {
              data.setCurrentLeafTool(LeafTool.pen_color);
              widget.showLeafTool();
            },
          ),
          IconButton(
            icon: Text(
              data.getPenWidth().truncate().toString(),
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () {
              data.setCurrentLeafTool(LeafTool.pen_width);
              widget.showLeafTool();
            },
          ),
        ];
        break;
      case MainTool.shape:
        result = [
          IconButton(
            icon: _getShapeIcon(data.getShapeType()),
            onPressed: () {
              data.setCurrentLeafTool(LeafTool.shape_type);
              widget.showLeafTool();
            },
          ),
          IconButton(
            iconSize: 50,
            icon: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: data.getShapeColor(),
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: () {
              data.setCurrentLeafTool(LeafTool.shape_color);
              widget.showLeafTool();
            },
          ),
          IconButton(
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
                widget.showLeafTool();
              }),
          IconButton(
            icon: Text(
              data.getShapeWidth().toInt().toString(),
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () {
              data.setCurrentLeafTool(LeafTool.shape_width);
              widget.showLeafTool();
            },
          ),
        ];
        break;
      case MainTool.text:
        result = [
          IconButton(
            iconSize: 50,
            icon: Image.asset(
              'assets/icons/typo_input.png',
              // width: 50,
              // height: 30,
            ),
            onPressed: () {
              data.setCurrentLeafTool(LeafTool.text_text);
              widget.showLeafTool();
            },
          ),
          RaisedButton(
            child: Text('font'),
            onPressed: () {
              data.setCurrentLeafTool(LeafTool.text_font);
              widget.showLeafTool();
            },
          ),
          IconButton(
            icon: Text(
              data.getTextWeight().toString(),
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () {
              data.setCurrentLeafTool(LeafTool.text_weight);
              widget.showLeafTool();
            },
          ),
          IconButton(
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
              widget.showLeafTool();
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
              icon: Image.asset(
                'assets/icons/image_crop.png',
                width: 30,
                height: 30,
              ),
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
      // case MainTool.more:
      //   result = [
      //     RaisedButton(
      //       onPressed: () {
      //         data.setCurrentLeafTool(LeafTool.align);
      //         widget.showLeafTool();
      //       },
      //       child: Text('align'),
      //     ),
      //     //delete
      //     RaisedButton(
      //       onPressed: () => data.removeCurrentSelected(),
      //       child: Text('delete'),
      //     ),
      //     //undo
      //     RaisedButton(
      //       onPressed: () => data.undo(),
      //       child: Text('undo'),
      //     ),
      //     //clear
      //     RaisedButton(
      //       onPressed: () => data.reset(),
      //       child: Text('clear'),
      //     ),
      //     RaisedButton(
      //       child: Text('save'),
      //       onPressed: () async {
      //         List<Map<String, dynamic>> list = [
      //           {
      //             'background': {'background': data.getBackroundColor().value}
      //           }
      //         ];
      //         data.selectables.forEach((element) {
      //           list.add({element.runtimeType.toString(): element});
      //         });

      //         if (!data.newCanva) {
      //           await SeletectableImgFile(imgPath: data.currentEditImgPath)
      //               .delete();
      //         }

      //         String jsonString = jsonEncode(list);
      //         String name = DateTime.now().millisecondsSinceEpoch.toString();
      //         await saveImage(rpbKey, mContext,
      //             data.size2Save.width / data.size.width, name);
      //         await saveJson(name, jsonString);
      //         data.reset();
      //       },
      //     ),
      //   ];
      //   break;
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
          // ToolButton(
          //   icon: toolIconList[0],
          //   color: data.currentMainTool == MainTool.background
          //       ? Colors.white
          //       : Colors.grey,
          //   onTap: () {
          //     data.setCurrentMainTool(MainTool.background);
          //     data.setUnselected();
          //     widget.hideLeafTool();
          //   },
          // ),
          //pen
          ToolButton(
            icon: toolIconList[0],
            color: data.currentMainTool == MainTool.pen
                ? Colors.white
                : Colors.grey[600],
            onTap: () {
              data.setCurrentMainTool(MainTool.pen);
              data.setUnselected();
              widget.hideLeafTool();
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
              widget.hideLeafTool();
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
              widget.hideLeafTool();
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
              widget.hideLeafTool();
            },
          ),
          //more
          // ToolButton(
          //   icon: toolIconList[5],
          //   color: data.currentMainTool == MainTool.more
          //       ? Colors.white
          //       : Colors.grey,
          //   onTap: () {
          //     data.setCurrentMainTool(MainTool.more);
          //     widget.hideLeafTool();
          //   },
          // ),
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
                    size.width - 20),
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
