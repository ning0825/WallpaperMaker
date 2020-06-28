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
  AnimationController imageAnimController;
  Tween<double> tween;
  Animation<double> imageAnimation;

  bool isButtonShow = true;

  double scale = 1.0;
  double tmpScale = 1.0;
  Offset trans = Offset.zero;

  List<Selectable> selectables;
  ConfigWidgetState data;

  @override
  void initState() {
    super.initState();

    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    slideAnimation = Tween(begin: Offset(0.0, 0.0), end: Offset(0.0, 1.0))
        .animate(controller);

    imageAnimController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 700));
    tween = Tween(end: 1.0);
    imageAnimation = tween
        .animate(imageAnimController)
        .drive(CurveTween(curve: Curves.easeIn));
    imageAnimation.addListener(() {
      setState(() {
        scale = imageAnimation.value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    data = ConfigWidget.of(context);
    return Scaffold(
      body: Container(
        child: Stack(
          children: <Widget>[
            GestureDetector(
              onTap: () {
                isButtonShow ? controller.forward() : controller.reverse();
                isButtonShow = !isButtonShow;
              },
              onScaleUpdate: (details) {
                setState(() {
                  scale = tmpScale * details.scale;
                });
              },
              onScaleEnd: (details) {
                if (scale < 1.0) {
                  tween.begin = scale;
                  imageAnimController.forward(from: scale);
                  scale = 1.0;
                }
                tmpScale = scale;
              },
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.diagonal3Values(scale, scale, 1.0),
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
    print(list.toString());
    data.clear();
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
            // data.selectables
            //     .add(SelectablePath.fromJson(value)..mPaint = paint);
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
