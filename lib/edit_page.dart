import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart' hide SelectableText;
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'inherited_config.dart';
import 'selectable_bean.dart';
import 'cus_painter.dart';

//Used to get size and save image.
GlobalKey rpbKey = GlobalKey();

GlobalKey stageKey;
Size size;

const penToolNum = 0;
const shapeToolNum = 1;
const typoToolNum = 2;
const shapeFillNum = 3;
const backgroundColorNum = 4;

class EditPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ConfigWidget(
        child: EditHome(),
      ),
    );
  }
}

class EditHome extends StatefulWidget {
  @override
  _EditHomeState createState() => _EditHomeState();
}

class _EditHomeState extends State<EditHome> {
  ConfigWidgetState data;
  Widget currentTools;
  Widget currentSubtools;
  Widget currentToolWidget;

  double sliderValue = 5.0;

  int currentMainToolIndex;

  @override
  void initState() {
    super.initState();

    stageKey = GlobalKey();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      size = rpbKey.currentContext.size;
    });

    currentToolWidget = Text('select a paint type😀');
    currentMainToolIndex = -1;
  }

  @override
  Widget build(BuildContext context) {
    data = ConfigWidget.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
          child: Column(
        key: stageKey,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: CanvasPanel(rpbKey),
          ),
          _buildConsole(),
        ],
      )),
    );
  }

  _buildConsole() {
    return Container(
      width: double.infinity,
      height: 200,
      color: Colors.blue[50],
      child: Row(
        children: <Widget>[
          Column(
            children: <Widget>[
              _BuildMainTool(
                color: currentMainToolIndex == 0 ? Colors.black : Colors.grey,
                iconAsset: 'pen',
                callback: () {
                  setState(() {
                    currentMainToolIndex = 0;
                    if (data.isSelectedMode) {
                      data.setUnselected();
                    }
                  });
                  data.config.currentMode = 0;
                  currentToolWidget = currentTools = PenToolWidget();
                },
              ),
              _BuildMainTool(
                color: currentMainToolIndex == 1 ? Colors.black : Colors.grey,
                iconAsset: 'geometry',
                callback: () {
                  setState(() {
                    currentMainToolIndex = 1;
                    data.config.currentMode = 1;
                    if (data.isSelectedMode) {
                      data.setUnselected();
                    }
                    currentToolWidget = currentTools = ShapeToolWidget();
                  });
                },
              ),
              _BuildMainTool(
                color: currentMainToolIndex == 2 ? Colors.black : Colors.grey,
                iconAsset: 'typo',
                callback: () {
                  setState(() {
                    currentMainToolIndex = 2;
                    data.config.currentMode = 2;
                    if (data.isSelectedMode) {
                      data.setUnselected();
                    }
                    currentToolWidget = currentTools = TypoToolWidget();
                  });
                },
              ),
              _BuildMainTool(
                color: currentMainToolIndex == 3 ? Colors.black : Colors.grey,
                iconAsset: 'image',
                callback: () {
                  setState(() {
                    currentMainToolIndex = 3;
                    data.config.currentMode = 3;
                    if (data.isSelectedMode) {
                      data.setUnselected();
                    }
                    currentToolWidget = currentTools = ImageTool(data: data);
                  });
                },
              ),
            ],
          ),
          Expanded(
            child: Column(
              children: <Widget>[
                _buildGenericTool(),
                Expanded(
                  child: currentToolWidget,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  ///add/undo/align/rotate/clean/save
  _buildGenericTool() {
    return Container(
      width: double.infinity,
      height: 60,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Spacer(),
          InkWell(
            onTap: () {
              setState(() {
                currentToolWidget =
                    BuildColorWidget(toolNum: backgroundColorNum);
              });
            },
            child: Container(
              width: 50,
              height: 40,
              color: Colors.black,
              child: Icon(
                Icons.palette,
                color: Colors.white,
              ),
            ),
          ),
          GapWidget(),
          InkWell(
            onTap: () {
              setState(() {
                currentToolWidget = AlignTool();
              });
            },
            child: Container(
              width: 50,
              height: 40,
              color: Colors.black,
              child: Icon(
                Icons.format_align_center,
                color: Colors.white,
              ),
            ),
          ),
          GapWidget(),
          InkWell(
            onTap: () => print('tap'),
            child: Container(
              width: 50,
              height: 40,
              color: Colors.black,
              child: Icon(
                Icons.settings_backup_restore,
                color: Colors.white,
              ),
            ),
          ),
          GapWidget(),
          InkWell(
            onTap: () => data.undo(),
            child: Container(
              width: 50,
              height: 40,
              color: Colors.black,
              child: Icon(
                Icons.undo,
                color: Colors.white,
              ),
            ),
          ),
          GapWidget(),
          InkWell(
            onTap: () => print('tap'),
            child: Container(
              width: 50,
              height: 40,
              color: Colors.black,
              child: Icon(
                Icons.save,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> svgs = [
    'pen',
    'geometry',
    'typo',
    'image',
  ];
}

typedef SliderCallback = void Function(double value);

class GapWidget extends StatelessWidget {
  const GapWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 8,
    );
  }
}

class BuildWidth extends StatefulWidget {
  final int toolNum;

  BuildWidth({this.toolNum});

  @override
  _BuildWidthState createState() => _BuildWidthState();
}

class _BuildWidthState extends State<BuildWidth> {
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

typedef CheckboxCallback = void Function(bool b);
typedef ColorCallback = void Function(Color color);

class BuildColorWidget extends StatefulWidget {
  final int toolNum;

  BuildColorWidget({@required this.toolNum});

  @override
  _BuildColorWidgetState createState() => _BuildColorWidgetState();
}

class _BuildColorWidgetState extends State<BuildColorWidget> {
  final colors = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue
  ];

  ConfigWidgetState data;

  @override
  Widget build(BuildContext context) {
    data = ConfigWidget.of(context);
    return Container(
      height: 100,
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
                itemCount: colors.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (_, index) {
                  return InkWell(
                    onTap: () {
                      setColorTap(index);
                    },
                    child: Center(
                      child: Container(
                        width: getSizeValue(index),
                        height: getSizeValue(index),
                        color: colors[index],
                      ),
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }

  void setColorTap(int index) {
    switch (widget.toolNum) {
      case penToolNum:
        data.setPenColor(colors[index]);
        break;
      case shapeToolNum:
        data.setShapeColor(colors[index]);
        break;
      case typoToolNum:
        data.setTextColor(colors[index]);
        break;
      case shapeFillNum:
        data.setShapeFillColor(colors[index]);
        break;
      case backgroundColorNum:
        data.setBackgroundColor(colors[index]);
        break;
      default:
        break;
    }
    setState(() {});
  }

  double getSizeValue(int index) {
    switch (widget.toolNum) {
      case penToolNum:
        return data.getPenColor().value == colors[index].value ? 60 : 40;
        break;
      case shapeToolNum:
        return data.getShapeColor().value == colors[index].value ? 60 : 40;
        break;
      case typoToolNum:
        return data.getTextColor().value == colors[index].value ? 60 : 40;
        break;
      case shapeFillNum:
        if (data.getShapeFillColor() != null &&
            data.getShapeFillColor().value == colors[index].value) {
          return 60;
        } else {
          return 40;
        }
        break;
      default:
        break;
    }
    return 10;
  }
}

class _BuildMainTool extends StatelessWidget {
  final Color color;
  final String iconAsset;
  final GestureTapCallback callback;

  _BuildMainTool({this.color, this.iconAsset, this.callback});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        width: 80,
        color: color,
        child: InkWell(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            // child: SvgPicture.asset(
            //   'assets/icons/' + iconAsset + '.svg',
            //   color: Colors.white,
            // ),
            child: Text(iconAsset),
          ),
          onTap: callback,
        ),
      ),
    );
  }
}

class PenToolWidget extends StatefulWidget {
  @override
  _PenToolWidgetState createState() => _PenToolWidgetState();
}

class _PenToolWidgetState extends State<PenToolWidget> {
  int subToolIndex;

  @override
  void initState() {
    super.initState();
    subToolIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Expanded(
            child: subToolIndex == 0
                ? BuildColorWidget(
                    toolNum: penToolNum,
                  )
                : BuildWidth(toolNum: penToolNum),
          ),
          Container(
            child: Row(
              children: [
                InkWell(
                  child: Container(
                    width: 70,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: subToolIndex == 0
                          ? Border.all(color: Colors.black)
                          : null,
                    ),
                    child: Text('Color'),
                  ),
                  onTap: () {
                    setState(() {
                      subToolIndex = 0;
                    });
                  },
                ),
                InkWell(
                  child: Container(
                    width: 70,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: subToolIndex == 1
                          ? Border.all(color: Colors.black)
                          : null,
                    ),
                    child: Text('Width'),
                  ),
                  onTap: () {
                    setState(() {
                      subToolIndex = 1;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ShapeToolWidget extends StatefulWidget {
  @override
  _ShapeToolWidgetState createState() => _ShapeToolWidgetState();
}

class _ShapeToolWidgetState extends State<ShapeToolWidget> {
  int subToolIndex;
  Widget currentSubToolWidget;

  ConfigWidgetState data;

  @override
  void initState() {
    super.initState();
    subToolIndex = 0;
  }

  Widget getCurrentWidget() {
    switch (subToolIndex) {
      case 0:
        return _buildShapeTypeTool();
      case 1:
        return BuildColorWidget(
          toolNum: shapeToolNum,
        );
      case 2:
        return BuildColorWidget(
          toolNum: shapeFillNum,
        );
      case 3:
        return BuildWidth(toolNum: shapeToolNum);

      default:
        return Text('no widget found! check subToolIndex: $subToolIndex');
    }
  }

  @override
  Widget build(BuildContext context) {
    data = ConfigWidget.of(context);
    return Container(
      child: Column(
        children: [
          Expanded(child: getCurrentWidget()),
          Container(
            child: Row(
              children: [
                InkWell(
                  child: Container(
                    width: 70,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: subToolIndex == 0
                          ? Border.all(color: Colors.black)
                          : null,
                    ),
                    child: Text('type'),
                  ),
                  onTap: () {
                    setState(() {
                      subToolIndex = 0;
                    });
                  },
                ),
                InkWell(
                  child: Container(
                    width: 70,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: subToolIndex == 1
                          ? Border.all(color: Colors.black)
                          : null,
                    ),
                    child: Text('color'),
                  ),
                  onTap: () {
                    setState(() {
                      subToolIndex = 1;
                    });
                  },
                ),
                InkWell(
                  child: Container(
                    width: 70,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: subToolIndex == 2
                          ? Border.all(color: Colors.black)
                          : null,
                    ),
                    child: Text('style'),
                  ),
                  onTap: () {
                    setState(() {
                      subToolIndex = 2;
                    });
                  },
                ),
                InkWell(
                  child: Container(
                    width: 70,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: subToolIndex == 3
                          ? Border.all(color: Colors.black)
                          : null,
                    ),
                    child: Text('width'),
                  ),
                  onTap: () {
                    setState(
                      () {
                        subToolIndex = 3;
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _buildShapeTypeTool() {
    return Container(
      height: 70,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            InkWell(
              child: Container(
                color: Colors.grey,
                width: _getSizeValue(0),
                height: _getSizeValue(0),
                child: Text('line'),
              ),
              onTap: () => data.setShapeType(0),
            ),
            InkWell(
              child: Container(
                color: Colors.grey,
                width: _getSizeValue(1),
                height: _getSizeValue(1),
                child: Text('rect'),
              ),
              onTap: () => data.setShapeType(1),
            ),
            InkWell(
              child: Container(
                color: Colors.grey,
                width: _getSizeValue(2),
                height: _getSizeValue(2),
                child: Text('circle'),
              ),
              onTap: () => data.setShapeType(2),
            ),
          ],
        ),
      ),
    );
  }

  double _getSizeValue(int type) {
    switch (type) {
      case 0:
        return data.getShapeType() == 0 ? 60 : 40;
      case 1:
        return data.getShapeType() == 1 ? 60 : 40;
      case 2:
        return data.getShapeType() == 2 ? 60 : 40;
      default:
    }
    return 10;
  }
}

class TypoToolWidget extends StatefulWidget {
  TypoToolWidget();
  @override
  _TypoToolWidgetState createState() => _TypoToolWidgetState();
}

class _TypoToolWidgetState extends State<TypoToolWidget> {
  int subToolIndex;

  @override
  void initState() {
    super.initState();
    subToolIndex = 0;
  }

  Widget _getCurrentWidget() {
    switch (subToolIndex) {
      case 0:
        return TypoTextWidget();
      case 1:
        return TypoFontWidget();
      case 2:
        return BuildWidth(toolNum: typoToolNum);
      case 3:
        return BuildColorWidget(toolNum: typoToolNum);
      default:
    }
    return Text('No widget found! check TypoTool\'s subToolIndex');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Expanded(child: _getCurrentWidget()),
          Row(
            children: [
              InkWell(
                child: Container(
                  width: 70,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      border: subToolIndex == 0
                          ? Border.all(color: Colors.black)
                          : null),
                  child: Text('text'),
                ),
                onTap: () {
                  setState(() {
                    subToolIndex = 0;
                  });
                },
              ),
              InkWell(
                child: Container(
                  width: 70,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      border: subToolIndex == 1
                          ? Border.all(color: Colors.black)
                          : null),
                  child: Text('font'),
                ),
                onTap: () {
                  setState(() {
                    subToolIndex = 1;
                  });
                },
              ),
              InkWell(
                child: Container(
                  width: 70,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      border: subToolIndex == 2
                          ? Border.all(color: Colors.black)
                          : null),
                  child: Text('weight'),
                ),
                onTap: () {
                  setState(() {
                    subToolIndex = 2;
                  });
                },
              ),
              InkWell(
                child: Container(
                  width: 70,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      border: subToolIndex == 3
                          ? Border.all(color: Colors.black)
                          : null),
                  child: Text('color'),
                ),
                onTap: () {
                  setState(() {
                    subToolIndex = 3;
                  });
                },
              ),
            ],
          )
        ],
      ),
    );
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
          itemBuilder: (_, index) {
            return ListTile(
              title: Text(fontList[index]),
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

class ImageTool extends StatefulWidget {
  final ConfigWidgetState data;

  ImageTool({@required this.data});
  @override
  _ImageToolState createState() => _ImageToolState();
}

class _ImageToolState extends State<ImageTool> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Row(
      children: [
        RaisedButton(
          child: Text('image'),
          onPressed: () => _addImage(),
        ),
        RaisedButton(
          child: Text('crop'),
          onPressed: () => print('TODO: navigate to crop route.'),
        ),
        RaisedButton(
          child: Text('frame'),
          onPressed: () => print('TODO: add frame for image.'),
        ),
      ],
    ));
  }

  _addImage() async {
    File _fileImage = await ImagePicker.pickImage(source: ImageSource.gallery);
    ui.Image img = await decodeImageFromList(await _fileImage.readAsBytes());
    setState(() {
      var size = rpbKey.currentContext.size;
      widget.data.selectables
          .add(SelectableImage(img, Offset(size.width / 2, size.height / 2)));
    });
  }
}

class AlignTool extends StatefulWidget {
  @override
  _AlignToolState createState() => _AlignToolState();
}

class _AlignToolState extends State<AlignTool> {
  ConfigWidgetState data;

  @override
  Widget build(BuildContext context) {
    data = ConfigWidget.of(context);
    return Container(
      child: Row(
        children: [
          RawMaterialButton(
            constraints: BoxConstraints(maxWidth: 30),
            onPressed: () {
              print('set left align');
              setState(() {
                data.stageSize = stageKey.currentContext.size;
                data.setLeftAlign();
              });
            },
            child: Text('left'),
          ),
          RaisedButton(
            onPressed: () {
              setState(() {
                data.setTopAlign();
              });
            },
            child: Text('top'),
          ),
          RaisedButton(
            onPressed: () {
              setState(() {
                data.setRightAlign();
              });
            },
            child: Text('right'),
          ),
          RaisedButton(
            onPressed: () {
              setState(() {
                data.setBottomAlign();
              });
            },
            child: Text('bottom'),
          ),
          RaisedButton(
            onPressed: () {
              setState(() {
                data.setCenterHorizonAlign();
              });
            },
            child: Text('centerH'),
          ),
        RaisedButton(
            onPressed: () {
              setState(() {
                data.setCenterVerticalAlign();
              });
            },
            child: Text('centerV'),
          ),
        
        ],
      ),
    );
  }
}

class RotationTool extends StatefulWidget {
  @override
  _RotationToolState createState() => _RotationToolState();
}

class _RotationToolState extends State<RotationTool> {
  ConfigWidgetState data;
  @override
  Widget build(BuildContext context) {
    data = ConfigWidget.of(context);
    return Container();
  }
}
