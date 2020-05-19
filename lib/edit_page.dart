import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart' hide SelectableText;
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'inherited_config.dart';
import 'package:wallpaper_maker/selectable_bean.dart';

import 'cus_painter.dart';
import 'inherited_config.dart';

GlobalKey rpbKey = GlobalKey();
Size size;

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
                  });
                  data.config.currentMode = 0;
                  currentToolWidget = currentTools = PenToolWidget(data);
                },
              ),
              _BuildMainTool(
                color: currentMainToolIndex == 1 ? Colors.black : Colors.grey,
                iconAsset: 'geometry',
                callback: () {
                  setState(() {
                    currentMainToolIndex = 1;
                    data.config.currentMode = 1;
                    currentToolWidget = currentTools = ShapeToolWidget(data);
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
                    currentToolWidget = currentTools = TypoToolWidget(data);
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
            onTap: () => print('tap'),
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
            onTap: () => print('tap'),
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
            onTap: () => print('tap'),
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

class _BuildWidth extends StatefulWidget {
  final SliderCallback sliderCallback;

  _BuildWidth(this.sliderCallback);

  @override
  _BuildWidthState createState() => _BuildWidthState();
}

class _BuildWidthState extends State<_BuildWidth> {
  double sliderValue = 1.0;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      child: Slider(
        value: sliderValue,
        onChanged: (value) {
          widget.sliderCallback(value);
          setState(() {
            sliderValue = value;
            print(value);
          });
        },
        min: 1.0,
        max: 10.0,
        label: sliderValue.toString(),
        activeColor: Colors.black,
        divisions: 9,
      ),
    );
  }
}

typedef CheckboxCallback = void Function(bool b);
typedef ColorCallback = void Function(Color color);

class BuildColorWidget extends StatefulWidget {
  final ConfigWidgetState data;
  final int tool;

  BuildColorWidget({this.data, @required this.tool});

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

  var iconig;

  @override
  Widget build(BuildContext context) {
    iconig = ConfigWidget.of(context);
    print('_BuildColorWidgetState.build');
    return Container(
      height: 100,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          widget.tool == 4
              ? Checkbox(
                  value: widget.data.getShapeStyle(),
                  onChanged: (b) {
                    widget.data.setShapeStyle(
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
    switch (widget.tool) {
      case 0:
        widget.data.setPenColor(colors[index]);
        break;
      case 1:
        widget.data.setShapeColor(colors[index]);
        break;
      case 2:
        widget.data.setTextColor(colors[index]);
        break;
      case 4:
        widget.data.setShapeFillColor(colors[index]);
        break;
      default:
        break;
    }
    setState(() {});
  }

  double getSizeValue(int index) {
    switch (widget.tool) {
      case 0:
        return widget.data.getPenColor().value == colors[index].value ? 60 : 40;
        break;
      case 1:
        return widget.data.getShapeColor().value == colors[index].value
            ? 60
            : 40;
        break;
      case 2:
        return widget.data.getTextColor().value == colors[index].value
            ? 60
            : 40;
        break;
      case 4:
        return widget.data.getShapeFillColor().value == colors[index].value
            ? 60
            : 40;
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
  final ConfigWidgetState data;
  PenToolWidget(this.data);
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
    print('PenTool.build');
    return Container(
      child: Column(
        children: [
          Expanded(
            // child: subToolIndex == 0
            //     ? BuildColorWidget(
            //         data: widget.data,
            //         tool: 0,
            //       )
            //     : _BuildWidth((value) {
            //         setState(() {
            //           widget.data.setPenWidth(value);
            //         });
            //       }),
            child: BuildColorWidget(
              data: widget.data,
              tool: 0,
            ),
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
  final ConfigWidgetState data;
  ShapeToolWidget(this.data);
  @override
  _ShapeToolWidgetState createState() => _ShapeToolWidgetState();
}

class _ShapeToolWidgetState extends State<ShapeToolWidget> {
  int subToolIndex;
  Widget currentSubToolWidget;

  @override
  void initState() {
    super.initState();
    subToolIndex = 0;
    currentSubToolWidget = _buildShapeTypeTool();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Expanded(child: currentSubToolWidget),
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
                      currentSubToolWidget = _buildShapeTypeTool();
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
                      currentSubToolWidget = BuildColorWidget(
                        tool: 1,
                      );
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
                      currentSubToolWidget = BuildColorWidget(
                        data: widget.data,
                        tool: 4,
                      );
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
                    setState(() {
                      subToolIndex = 3;
                      currentSubToolWidget = _BuildWidth((value) {
                        widget.data.setShapeWidth(value);
                      });
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

  _buildShapeTypeTool() {
    return Container(
      height: 70,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            InkWell(
              child: Container(
                width: widget.data.getShapeType() == 0 ? 60 : 40,
                height: widget.data.getShapeType() == 0 ? 60 : 40,
                child: Text('line'),
              ),
              onTap: () => widget.data.setShapeType(0),
            ),
            InkWell(
              child: Container(
                width: widget.data.getShapeType() == 1 ? 60 : 40,
                height: widget.data.getShapeType() == 1 ? 60 : 40,
                child: Text('rect'),
              ),
              onTap: () => widget.data.setShapeType(1),
            ),
            InkWell(
              child: Container(
                width: widget.data.getShapeType() == 2 ? 60 : 40,
                height: widget.data.getShapeType() == 2 ? 60 : 40,
                child: Text('line'),
              ),
              onTap: () => widget.data.setShapeType(2),
            ),
          ],
        ),
      ),
    );
  }
}

class TypoToolWidget extends StatefulWidget {
  final ConfigWidgetState data;

  TypoToolWidget(this.data);
  @override
  _TypoToolWidgetState createState() => _TypoToolWidgetState();
}

class _TypoToolWidgetState extends State<TypoToolWidget> {
  int subToolIndex;
  Widget currentSubToolWidget;

  @override
  void initState() {
    super.initState();
    subToolIndex = 0;
    currentSubToolWidget = _buildTextTool();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Expanded(child: currentSubToolWidget),
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
                    currentSubToolWidget = _buildTextTool();
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
                    currentSubToolWidget = _buildTextFont();
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
                    currentSubToolWidget = _BuildWidth((value) {
                      widget.data.setTextWeight(value);
                    });
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
                    currentSubToolWidget = BuildColorWidget(
                      tool: 2,
                      data: widget.data,
                    );
                  });
                },
              ),
            ],
          )
        ],
      ),
    );
  }

  TextEditingController controller = TextEditingController(text: 'text');
  _buildTextTool() {
    controller.text = widget.data.getText();
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
              widget.data.addSelectable(
                SelectableText(
                  text: controller.text,
                  totalOffset: Offset(size.height / 2 / 2, size.height / 2),
                ),
              );
              widget.data.setSeleteLast();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  var fontList = ['default', 'polingo', 'PlayfairDisplay'];
  _buildTextFont() {
    return Container(
      child: ListView.builder(
          itemCount: fontList.length,
          itemBuilder: (_, index) {
            return ListTile(
              title: Text(fontList[index]),
              onTap: () {
                widget.data.setTextFont(fontList[index]);
              },
            );
          }),
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
          onPressed: () => print('test'),
        ),
        RaisedButton(
          child: Text('frame'),
          onPressed: () => print('test'),
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
