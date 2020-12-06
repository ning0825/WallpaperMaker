import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:image_picker/image_picker.dart';
import 'package:wallpaper_maker/selectable_bean.dart';
import 'package:wallpaper_maker/inherited_config.dart';
import 'package:wallpaper_maker/routes/route_clip.dart';
import 'package:wallpaper_maker/cus_widget.dart';
import 'package:wallpaper_maker/utils.dart';

GlobalKey rpbKey = GlobalKey();

GlobalKey backgroundBtKey = GlobalKey();

GlobalKey alignBtKey = GlobalKey();
GlobalKey rotBtKey = GlobalKey();

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

GlobalKey keyStack = GlobalKey();
GlobalKey topToolBarKey = GlobalKey();
GlobalKey bottomToolBarKey = GlobalKey();

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
      data.canvasTop =
          (topToolBarKey.currentContext.findRenderObject() as RenderBox)
              .size
              .height;

      data.canvasBottom =
          (bottomToolBarKey.currentContext.findRenderObject() as RenderBox)
              .size
              .height;

      data.setCanvasSize(
          height: keyStack.currentContext.size.height -
              data.canvasTop -
              data.canvasBottom,
          ratio: data.size2Save.aspectRatio);
    });
  }

  @override
  Widget build(BuildContext context) {
    data = ConfigWidget.of(context);

    return SafeArea(
      child: WillPopScope(
        onWillPop: () {
          data.reset();
          return Future.value(true);
        },
        child: Scaffold(
          body: Stack(
            key: keyStack,
            alignment: Alignment.center,
            children: [
              //Give size to this stack.
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: Colors.grey[200],
              ),
              Positioned(
                top: data.canvasTop,
                bottom: data.canvasBottom,
                child: CanvasGestureDetector(
                  onTapDownCallback: data.handleTapDown,
                  onDragUpdateCallback: data.handleTapUpdate,
                  ondragEndCallback: data.handleTapEnd,
                  onScaleStartCallback: data.handleScaleStart,
                  onScaleUpdateCallback: data.handleScaleUpdate,
                  onScaleEndCallback: data.handleScaleEnd,
                  onTapUpCallback: data.handleTapUp,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Center(
                      child: CanvasPanel(rpbKey),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                child: TopToolbar(
                  key: topToolBarKey,
                ),
              ),
              Positioned(
                bottom: 0,
                child: BottomToolbar(
                  key: bottomToolBarKey,
                ),
              ),
              Positioned(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.centerLeft,
                  child: _buildAnimatedLeafTools(),
                ),
                bottom: data.bottom,
                top: data.top,
              ),
            ],
          ),
        ),
      ),
    );
  }

  _buildAnimatedLeafTools() {
    return Offstage(
      offstage: data.leafToolOffstage,
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
            child: PaletteWidget(
              onColorPick: (color) {
                data.setBackgroundColor(color);
              },
              selectColor: data.getBackroundColor(),
            ),
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
            child: PaletteWidget(
              onColorPick: (color) {
                data.setPenColor(color);
              },
              selectColor: data.getPenColor(),
            ),
          );
          break;
        case LeafTool.pen_width:
          result = WidthWidget(toolNum: penToolNum);
          break;
        case LeafTool.shape_type:
          result = Row(
            mainAxisSize: MainAxisSize.min,
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
            child: PaletteWidget(
              onColorPick: (color) {
                data.setShapeColor(color);
              },
              selectColor: data.getShapeColor(),
            ),
          );
          break;
        case LeafTool.shape_style:
          result = Column(
            children: [
              InkWell(
                onTap: () => data.setShapeFillColor(Colors.transparent),
                child: Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(bottom: 4.0),
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
              ),
              Container(
                width: MediaQuery.of(context).size.width - 36,
                child: PaletteWidget(
                  onColorPick: (color) {
                    data.setShapeFillColor(color);
                  },
                  selectColor: data.getShapeFillColor(),
                ),
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
              child: PaletteWidget(
                onColorPick: (color) {
                  data.setTextColor(color);
                },
                selectColor: data.getTextColor(),
              ));
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
        case LeafTool.rotate:
          result = RotateControllerWidget(
            angle: data.getCurrentRotation(),
            rotateCallback: (angle) => data.rotate(angle),
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
  TopToolbar({Key key}) : super(key: key);

  @override
  _TopToolbarState createState() => _TopToolbarState();
}

class _TopToolbarState extends State<TopToolbar> with TickerProviderStateMixin {
  ConfigWidgetState data;

  OverlayEntry entry;

  @override
  void initState() {
    super.initState();

    entry = OverlayEntry(builder: (context) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: Material(
          type: MaterialType.transparency,
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
            child: Center(
              child: Container(
                width: 100,
                height: 100,
                color: Colors.black,
                alignment: Alignment.center,
                child: FutureBuilder(
                  future: saveBoard(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      _removeEntry();
                      return Icon(
                        Icons.done,
                        color: Colors.white,
                      );
                    } else {
                      return CircularProgressIndicator(
                        valueColor:
                            Tween<Color>(begin: Colors.white, end: Colors.red)
                                .animate(AnimationController(vsync: this)),
                      );
                    }
                  },
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  void _showSaveDialog() {
    Overlay.of(context).insert(entry);
  }

  Future<int> saveBoard() async {
    List<Map<String, dynamic>> list = [
      {
        'background': {'background': data.getBackroundColor().value}
      }
    ];
    data.selectables.forEach((element) {
      list.add({element.runtimeType.toString(): element});
    });

    if (!data.newCanva) {
      await SelectableImageFile(imgPath: data.currentEditImgPath).delete();
    }

    String jsonString = jsonEncode(list);
    String name = DateTime.now().millisecondsSinceEpoch.toString();
    await saveImage(rpbKey, data.size2Save.width / data.size.width, name);
    await saveJson(name, jsonString);
    return 0;
  }

  _removeEntry() async {
    await Future.delayed(Duration(seconds: 1))
        .then((value) => Navigator.popUntil(context, ModalRoute.withName('/')));
    data.reset();
    entry.remove();
  }

  @override
  Widget build(BuildContext context) {
    data = ConfigWidget.of(context);

    return Container(
      color: Colors.black,
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.centerRight,
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // IconButton(
          //   icon: Image.asset(
          //     'assets/icons/eraser.png',
          //     width: 20,
          //     height: 20,
          //     color: Colors.white,
          //   ),
          //   onPressed: () => data.setCurrentMainTool(MainTool.eraser),
          // ),
          //Cancel select mode.
          IconButton(
            color: Colors.white,
            disabledColor: Colors.grey,
            icon: Icon(
              Icons.cancel_sharp,
            ),
            onPressed: data.isSelectedMode ? data.setUnselected : null,
          ),
          IconButton(
              color: Colors.white,
              disabledColor: Colors.grey,
              icon: Icon(
                Icons.fullscreen_exit,
              ),
              onPressed: data.canvasScale > 1.0 ? data.exitScaleMode : null),
          IconButton(
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
          //delete
          IconButton(
            icon: Image.asset(
              'assets/icons/remove.png',
              width: 20,
              height: 20,
              color: data.isSelectedMode ? Colors.white : Colors.grey,
            ),
            onPressed: () =>
                data.isSelectedMode ? data.removeCurrentSelected() : null,
          ),
          //undo
          IconButton(
            icon: Image.asset(
              'assets/icons/undo.png',
              width: 20,
              height: 20,
            ),
            onPressed: () => data.undo(),
          ),
          //clear
          IconButton(
            icon: Image.asset(
              'assets/icons/clear.png',
              width: 20,
              height: 20,
              color: Colors.white,
            ),
            onPressed: () => data.clean(),
          ),
          IconButton(
            icon: Image.asset(
              'assets/icons/save.png',
              width: 20,
              height: 20,
            ),
            onPressed: () {
              data.setUnselected();
              _showSaveDialog();
            },
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
    List<Widget> result;
    switch (mainTool) {
      case MainTool.pen:
        result = [
          SubToolIconWidget(
            akey: penColorKey,
            icon: ColorWidget(data.getPenColor()),
            onPressed: () {
              data.setCurrentLeafTool(LeafTool.pen_color);
              data.setLeafToolBottom();
              data.setIndicatorPosition(penColorKey);
              data.toggleLeafTool();
            },
          ),
          SubToolIconWidget(
            akey: penWidthKey,
            icon: Text(
              data.getPenWidth().toStringAsFixed(1).toString(),
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () {
              data.setCurrentLeafTool(LeafTool.pen_width);
              data.setLeafToolBottom();
              data.setIndicatorPosition(penWidthKey);
              data.toggleLeafTool();
            },
          )
        ];
        break;
      case MainTool.shape:
        result = [
          SubToolIconWidget(
            icon: Padding(
              key: shapeTypeKey,
              padding: EdgeInsets.all(6),
              child: _getShapeIcon(data.getShapeType()),
            ),
            onPressed: () {
              data.setCurrentLeafTool(LeafTool.shape_type);
              data.setLeafToolBottom();
              data.setIndicatorPosition(shapeTypeKey);
              data.toggleLeafTool();
            },
          ),
          SubToolIconWidget(
            akey: shapeColorKey,
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
          SubToolIconWidget(
              akey: shapeFillTypeKey,
              icon: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: data.getShapeFillColor(),
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
          SubToolIconWidget(
            akey: shapeWidthKey,
            icon: Text(
              data.getShapeWidth().toStringAsFixed(1).toString(),
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
          SubToolIconWidget(
            akey: typoTextKey,
            icon: Icon(Icons.space_bar),
            onPressed: () {
              data.setCurrentLeafTool(LeafTool.text_text);
              data.setLeafToolBottom();
              data.setIndicatorPosition(typoTextKey);
              data.toggleLeafTool();
            },
          ),
          SubToolIconWidget(
            akey: typoFontKey,
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
          SubToolIconWidget(
            akey: typoFontWeightKey,
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
          SubToolIconWidget(
            akey: typoColorKey,
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
          SubToolIconWidget(
            icon: Image.asset(
              'assets/icons/image_pick.png',
              width: 30,
              height: 30,
            ),
            onPressed: () {
              _addImage();
            },
          ),
          SubToolIconWidget(
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
          SubToolIconWidget(
            icon: Icon(
              Icons.filter_frames,
              size: 30,
            ),
            onPressed: data.isSelectedMode
                ? () {
                    //TODO add frame
                  }
                : null,
          ),
        ];
        break;
      default:
        break;
    }
    result.addAll([
      SubToolIconWidget(
          akey: alignBtKey,
          icon: Icon(
            Icons.format_align_center,
            size: 30,
          ),
          onPressed: data.isSelectedMode
              ? () {
                  data.setLeafToolBottom();
                  data.setCurrentLeafTool(LeafTool.align);
                  data.setIndicatorPosition(alignBtKey);
                  data.toggleLeafTool();
                }
              : null),
      SubToolIconWidget(
          akey: rotBtKey,
          icon: Icon(
            Icons.rotate_90_degrees_ccw,
            size: 30,
          ),
          onPressed: data.isSelectedMode
              ? () {
                  data.setLeafToolBottom();
                  data.setCurrentLeafTool(LeafTool.rotate);
                  data.setIndicatorPosition(rotBtKey);
                  data.toggleLeafTool();
                }
              : null),
    ]);

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
  var fontList = [
    'default',
    'polingo',
    'PlayfairDisplay',
    '方正黑体',
    '方正宋体',
    '方正黑体',
    '轻松体',
    '优设标题黑'
  ];
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
                style:
                    TextStyle(fontFamily: fontList[index], color: Colors.white),
              ),
              onTap: () {
                data.setTextFont(fontList[index]);
              },
            );
          }),
    );
  }
}

class SubToolIconWidget extends StatelessWidget {
  SubToolIconWidget({this.icon, this.onPressed, this.akey});

  final Widget icon;
  final VoidCallback onPressed;
  final GlobalKey akey;
  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: akey,
      icon: icon,
      onPressed: onPressed,
      color: Colors.white,
      disabledColor: Colors.grey,
      iconSize: 50,
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
      padding: EdgeInsets.all(6),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              autofocus: true,
              style: TextStyle(color: Colors.white, fontSize: 30),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                border: UnderlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white),
                ),
              ),
            ),
          ),
          Material(
            color: Colors.white,
            child: InkWell(
              highlightColor: Colors.black12,
              onTap: () {
                data.addSelectable(
                  data.assembleSelectableTypo(
                      controller.text,
                      Offset(data.size.width / 2, data.size.height / 2),
                      data.size.width - 20),
                );
                data.setSeleteLast();
                data.setCurrentLeafTool(LeafTool.text_text);
                data.toggleLeafTool();

                //Hide soft keyboard
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: Container(
                width: 60,
                height: 30,
                alignment: Alignment.center,
                child: Text('OK'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
