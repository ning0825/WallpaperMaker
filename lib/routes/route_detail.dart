import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart' hide SelectableText;
import 'package:path_provider/path_provider.dart';
import 'package:wallpaper_maker/beans/selectable_bean.dart';
import 'package:wallpaper_maker/inherit/inherited_config.dart';
import 'package:wallpaper_maker/routes/route_edit.dart';
import 'package:wallpaper_maker/utils/utils.dart';

class DetailRoute extends StatefulWidget {
  final File image;

  DetailRoute({this.image});
  @override
  _DetailRouteState createState() => _DetailRouteState();
}

class _DetailRouteState extends State<DetailRoute>
    with TickerProviderStateMixin {
  //Bottom buttons animation
  AnimationController controller;
  Animation<Offset> slideAnimation;

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

    scaleAnimController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    scaleTween = Tween(end: 1.0);
    scaleAnimation = scaleTween
        .animate(scaleAnimController)
        .drive(CurveTween(curve: Curves.easeIn));
    scaleAnimation.addListener(() {
      setState(() {
        scale = scaleAnimation.value;
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
        child: Container(
          color: Colors.green,
          child: Stack(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  isButtonShow ? controller.forward() : controller.reverse();
                  isButtonShow = !isButtonShow;
                },
                onScaleStart: (details) => startPoint = details.localFocalPoint,
                onScaleUpdate: (details) {
                  if (details.scale == 1.0) {
                    offset = tmpOffset + (details.localFocalPoint - startPoint);
                  } else {
                    scale = tmpScale * details.scale;
                  }
                  setState(() {});
                },
                onScaleEnd: (details) {
                  if (scale < 1.0) {
                    scaleTween.begin = scale;
                    scaleAnimController.forward(from: scale);
                    scale = 1.0;
                  }

                  if (offset.distance >
                      Offset(size.width * (scale - 1) / 2,
                              size.height * (scale - 1) / 2)
                          .distance) {
                    transTween.begin = offset;

                    var xpre = offset.dx < 0 ? -1 : 1;
                    var ypre = offset.dy < 0 ? -1 : 1;

                    transTween.end = Offset(xpre * size.width * (scale - 1) / 2,
                        ypre * size.height * (scale - 1) / 2);

                    transAnimController.forward(from: 0.0);
                  }
                  tmpScale = scale;
                  tmpOffset = offset;
                },
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.diagonal3Values(scale, scale, 1.0)
                    ..translate(offset.dx / scale, offset.dy / scale),
                  child: Image.file(widget.image),
                ),
              ),
              Positioned(
                bottom: 0.0,
                child: SlideTransition(
                  position: slideAnimation,
                  child: DetailTool(widget.image.path),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

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
        children: <Widget>[
          RaisedButton(
            onPressed: () async {
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
            child: Text('edit'),
          ),
          RaisedButton(
            onPressed: () => saveImage2Local(widget.imageFile),
            child: Text('save'),
          ),
          RaisedButton(
            onPressed: () => setAswallPaper(context, widget.imageFile),
            child: Text('set wallpaper'),
          ),
        ],
      ),
    );
  }

  _getSelectables(String name) async {
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
          case 'SelectableText':
            data.addSelectable(SelectableText.fromJson(value));
            break;
          default:
            break;
        }
      });
    });
  }
}
