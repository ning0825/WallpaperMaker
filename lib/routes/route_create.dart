import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:wallpaper_maker/inherit/inherited_config.dart';
import 'package:wallpaper_maker/routes/route_edit.dart';
import 'package:wallpaper_maker/utils/constants.dart';

class CreateRoute extends StatefulWidget {
  @override
  _CreateRouteState createState() => _CreateRouteState();
}

class _CreateRouteState extends State<CreateRoute>
    with SingleTickerProviderStateMixin {
  GlobalKey ttDetectedKey = GlobalKey();
  GlobalKey ttCustomKey = GlobalKey();
  GlobalKey formKey = GlobalKey();
  ConfigWidgetState data;

  double top = 0.0;
  double left = 100.0;

  var width;
  var height;

  ///0: detected
  ///1: custom
  int selected = 0;

  AnimationController controller;

  static const inputDeco = const InputDecoration(
      focusedBorder: UnderlineInputBorder(borderSide: BorderSide()));

  @override
  void initState() {
    super.initState();
    width = window.physicalSize.width;
    height = window.physicalSize.height;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        top = ttDetectedKey.currentContext.size.height / 2;
        // left = ttDetectedKey.currentContext.size.width / 2;
      });
    });

    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400));
  }

  @override
  Widget build(BuildContext context) {
    data = ConfigWidget.of(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Spacer(),
                  _buildSlideTransition(),
                  _buildStart(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  _buildSlideTransition() {
    return SlideTransition(
      position:
          Tween(begin: Offset.zero, end: Offset(0.0, -2.0)).animate(controller),
      child: Column(
        children: [
          _buildDetected(),
          _buildCustom(),
        ],
      ),
    );
  }

  _buildDetected() {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 200,
        ),
        Positioned(
            top: top,
            left: left,
            right: 20,
            bottom: 20,
            child: InkWell(
              onTap: () {
                setState(() {
                  selected = 0;
                });
                //点击 detected 时隐藏软键盘
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: Container(
                color: selected == 0 ? Color(0xFFFFF792) : Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${width.round()}', style: TextStyle(fontSize: 32)),
                    SizedBox(width: 26),
                    Text('x'),
                    SizedBox(width: 26),
                    Text('${height.round()}', style: TextStyle(fontSize: 32))
                  ],
                ),
              ),
            )),
        Positioned(
          left: 40,
          child: Text(
            'Detected',
            key: ttDetectedKey,
            style: TextStyle(fontSize: 30),
          ),
        ),
      ],
    );
  }

  _buildCustom() {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 200,
        ),
        Positioned(
          top: top,
          left: left,
          right: 20,
          bottom: 20,
          child: InkWell(
            onTap: () {
              setState(() {
                selected = 1;
              });
            },
            child: Container(
              color: selected == 1 ? Color(0xFFFFF792) : Colors.white,
              child: Form(
                key: formKey,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      child: TextFormField(
                        onTap: () {
                          setState(() {
                            selected = 1;
                          });
                        },
                        onSaved: (s) {
                          if (s.isNotEmpty) {
                            width = double.parse(s);
                          }
                        },
                        style: TextStyle(fontSize: 32),
                        cursorColor: Colors.black,
                        decoration: inputDeco,
                      ),
                    ),
                    SizedBox(width: 26),
                    Text('x'),
                    SizedBox(width: 26),
                    Container(
                      width: 80,
                      child: TextFormField(
                        onTap: () {
                          setState(() {
                            selected = 1;
                          });
                        },
                        onSaved: (s) {
                          if (s.isNotEmpty) {
                            height = double.parse(s);
                          }
                        },
                        style: TextStyle(fontSize: 32),
                        cursorColor: Colors.black,
                        decoration: inputDeco,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 40,
          child: Text(
            'Custom',
            key: ttCustomKey,
            style: TextStyle(fontSize: 30),
          ),
        ),
      ],
    );
  }

  bool init = true;

  _buildStart() {
    return InkWell(
      onTap: () {
        setState(() {
          init = false;
          controller.forward(from: 0.0);
        });
      },
      child: Container(
        margin: EdgeInsets.only(
          bottom: 20,
          right: 20,
        ),
        child: Hero(
          tag: herotag_libToCreate,
          child: Material(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: InkWell(
                onTap: () {
                  (formKey.currentState as FormState).save();
                  data.size2Save = Size(width, height);
                  FocusScope.of(context).requestFocus(FocusNode());
                  Navigator.of(context)
                      .push(PageRouteBuilder(pageBuilder: (_, a1, a2) {
                    return AnimatedBuilder(
                      animation: a1,
                      builder: (_, child) => Opacity(
                        opacity: a1.value,
                        child: EditRoute(),
                      ),
                    );
                  }));
                },
                child: Container(
                  width: MediaQuery.of(context).size.width -
                      (left == 0.0 ? 50 : left) -
                      20,
                  padding: EdgeInsets.all(20),
                  color: Colors.black,
                  height: 70,
                  child: Row(
                    children: [
                      Text(
                        'start',
                        style: TextStyle(color: Colors.white, fontSize: 30),
                      ),
                      Spacer(),
                      Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 30,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CusPageRoute extends PageRouteBuilder {
  Widget child;

  CusPageRoute({this.child});

  @override
  get pageBuilder => (_, a1, a2) {
        return AnimatedBuilder(
          animation: a1,
          builder: (_, child) => Opacity(
            opacity: a1.value,
            child: child,
          ),
        );
      };
}
