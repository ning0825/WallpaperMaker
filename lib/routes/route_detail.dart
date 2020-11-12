import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wallpaper_maker/selectable_bean.dart';
import 'package:wallpaper_maker/inherited_config.dart';
import 'package:wallpaper_maker/routes/route_edit.dart';
import 'package:wallpaper_maker/utils.dart';

class DetailRoute extends StatefulWidget {
  final File image;
  final String heroTag;

  DetailRoute({this.image, this.heroTag});
  @override
  _DetailRouteState createState() => _DetailRouteState();
}

class _DetailRouteState extends State<DetailRoute>
    with TickerProviderStateMixin {
  //Bottom buttons animation
  AnimationController controller;
  Animation<Offset> slideAnimation;
  Animation<Offset> backSlideAnimation;

  //Image scale animation
  AnimationController scaleAnimController;
  Tween<double> scaleTween;
  Animation<double> scaleAnimation;

  AnimationController transAnimController;
  Tween<Offset> transTween;
  Animation<Offset> transAnimation;

  bool isButtonShow = true;

  double scale = 1.0;
  double tmpScale = 1.0;

  Offset offset = Offset.zero;
  Offset tmpOffset = Offset.zero;
  Offset startPoint;

  Size size;

  List<Selectable> selectables;
  ConfigWidgetState data;

  @override
  void initState() {
    super.initState();

    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    slideAnimation = Tween(begin: Offset(0.0, 0.0), end: Offset(0.0, 1.0))
        .animate(controller);
    backSlideAnimation = Tween(begin: Offset(0.0, 0.0), end: Offset(0.0, -1.5))
        .animate(controller);

    scaleAnimController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    scaleTween = Tween(begin: 1.0, end: 5.0);
    // scaleAnimation = scaleTween
    //     .animate(scaleAnimController)
    //     .drive(CurveTween(curve: Curves.linear));
    scaleAnimation =
        scaleAnimController.drive(CurveTween(curve: Curves.easeIn));
    scaleAnimation.addListener(() {
      setState(() {
        scale = scaleTween.evaluate(scaleAnimation);
        tmpScale = scale;
      });
    });

    transAnimController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    transTween = Tween();
    transAnimation = transTween.animate(transAnimController);
    transAnimation.addListener(() {
      setState(() {
        offset = transAnimation.value;
        tmpOffset = offset;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    size = MediaQuery.of(context).size;
  }

  @override
  Widget build(BuildContext context) {
    data = ConfigWidget.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      isButtonShow
                          ? controller.forward()
                          : controller.reverse();
                      isButtonShow = !isButtonShow;
                    },
                    onDoubleTap: () {
                      if (scale == 1.0) {
                        scaleTween.end = 5.0;
                        scaleAnimController.forward(from: 0.0);
                      } else if (scale > 1.0) {
                        scaleTween.end = scale;
                        scaleAnimController.reverse(from: scale);

                        if (offset.distance > 0) {
                          transTween.begin = offset;
                          transTween.end = Offset.zero;
                          transAnimController.forward(from: 0.0);
                        }
                      }
                    },
                    onScaleStart: (details) =>
                        startPoint = details.localFocalPoint,
                    onScaleUpdate: (details) {
                      if (details.scale == 1.0) {
                        offset =
                            tmpOffset + (details.localFocalPoint - startPoint);
                      } else {
                        scale = tmpScale * details.scale;
                      }
                      setState(() {});
                    },
                    onScaleEnd: (details) {
                      if (scale < 1.0) {
                        scaleTween.begin = scale;
                        scaleTween.end = 1;
                        scaleAnimController.forward(from: scale);
                      }

                      if (offset.distance >
                          Offset(size.width * (scale - 1) / 2,
                                  size.height * (scale - 1) / 2)
                              .distance) {
                        transTween.begin = offset;
                        transTween.end = Offset.zero;
                        transAnimController.forward(from: 0.0);
                      }
                      tmpScale = scale;
                      tmpOffset = offset;
                    },
                    child: Center(
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.diagonal3Values(scale, scale, 1.0)
                          ..translate(offset.dx / scale, offset.dy / scale),
                        child: Hero(
                            tag: widget.heroTag,
                            child: Image.file(widget.image)),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0.0,
                    child: SlideTransition(
                      position: slideAnimation,
                      child: DetailTool(widget.image.path),
                    ),
                  ),
                  Positioned(
                    top: 0.0,
                    child: SlideTransition(
                      position: backSlideAnimation,
                      child: IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// class InteractiveWidet extends StatefulWidget {
//   InteractiveWidet(
//       {@required this.child,
//       this.onScaleStart,
//       this.onScaleUpdate,
//       this.onScaleEnd,
//       this.onDragStart,
//       this.onDragUpdate,
//       this.onDragEnd})
//       : hasInternalOperation = onDragUpdate != null;

//   final Widget child;

//   final GestureScaleStartCallback onScaleStart;
//   final GestureScaleUpdateCallback onScaleUpdate;
//   final GestureScaleEndCallback onScaleEnd;
//   final GestureDragStartCallback onPanStart;
//   final GestureDragUpdateCallback onPanUpdate;
//   final GestureDragEndCallback onDragEnd;

//   final hasInternalOperation;

//   @override
//   _InteractiveWidetState createState() => _InteractiveWidetState();
// }

// class _InteractiveWidetState extends State<InteractiveWidet> {
//   double preScale = 1.0;
//   double scale = 1.0;

//   Offset startPoint;
//   Offset preOffset = Offset.zero;
//   Offset offset = Offset.zero;

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onScaleStart: _handleScaleStart,
//       onScaleUpdate: _handleScaleUpdate,
//       onScaleEnd: _handleScaleEnd,
//       child: Transform(
//         transform: _getTransform(),
//         child: widget.child,
//       ),
//     );
//   }

//   Matrix4 _getTransform() => Matrix4.diagonal3Values(scale, scale, 1.0)
//     ..translate(offset.dx, offset.dy);

//   void _handleScaleStart(ScaleStartDetails details) {
//     //有自己操作的话，需要双指拖动，所以需要在 scaleStart 里设置startPoint
//     if (widget.hasInternalOperation) {
//       startPoint = details.localFocalPoint;
//       widget.onScaleStart(details);
//     } else {}
//   }

//   _handleScaleUpdate(ScaleUpdateDetails details) {
//     scale = preScale * details.scale;
//     if (widget.hasInternalOperation) {
//       widget.onScaleUpdate(details);
//     }
//   }

//   void _handleScaleEnd(ScaleEndDetails details) {
//     preScale = scale;
//     if (widget.hasInternalOperation) {
//       widget.onScaleEnd(details);
//     }
//   }
// }

class DetailTool extends StatefulWidget {
  DetailTool(this.imageFile);

  final String imageFile;
  @override
  _DetailToolState createState() => _DetailToolState();
}

class _DetailToolState extends State<DetailTool> {
  ConfigWidgetState data;

  @override
  Widget build(BuildContext context) {
    data = ConfigWidget.of(context);
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          InkWell(
              onTap: () async {
                Directory dir = await getExternalStorageDirectory();
                String jsonDir = dir.path + '/jsons';
                String jsonName = jsonDir +
                    '/' +
                    widget.imageFile.split('/').last.split('.').first +
                    '.json';
                await _getSelectables(jsonName);
                data.newCanva = false;
                data.currentEditImgPath = widget.imageFile;
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => EditRoute(),
                ));
              },
              child: _buildButton('Edit')),
          InkWell(
            onTap: () => saveImage2Local(widget.imageFile),
            child: _buildButton('Save'),
          ),
          InkWell(
            onTap: () => setAswallPaper(context, widget.imageFile),
            child: _buildButton('Set wallpaper'),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String text) {
    return Container(
      height: 50,
      alignment: Alignment.center,
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.symmetric(horizontal: 30),
      decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
              color: Colors.white,
            ),
          ),
          color: Colors.black),
      child: Text(
        text,
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }

  Future<void> _getSelectables(String name) async {
    File file = File(name);
    String string = await file.readAsString();
    List<Map> list = (jsonDecode(string) as List).cast();
    data.clean();
    list.forEach((element) {
      element.forEach((key, value) async {
        switch (key) {
          case 'background':
            data.setBackgroundColor(Color(value['background']));
            break;
          case 'SelectablePath':
            Paint paint = data.getCurrentPen()
              ..color = Color(value['color'])
              ..strokeWidth = value['strokeWidth'];
            data.addSelectable(SelectablePath.fromJson(value)..mPaint = paint);
            break;
          case 'SelectableShape':
            Paint paint = data.getCurrentPen()
              ..color = Color(value['color'])
              ..strokeWidth = value['strokeWidth'];
            data.addSelectable(SelectableShape.fromJson(value)..mPaint = paint);
            break;
          case 'SelectableImage':
            String imgName = value['imgName'];
            ui.Image img = await getImgObject(imgName);
            data.addSelectable(SelectableImage.fromJson(value)..img = img);
            break;
          case 'SelectableTypo':
            data.addSelectable(SelectableTypo.fromJson(value));
            break;
          default:
            break;
        }
      });
    });
  }
}
