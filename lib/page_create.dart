import 'dart:ui';

import 'package:flutter/material.dart';

import 'page_edit.dart';

class CreateRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CreatePage(),
    );
  }
}

class CreatePage extends StatefulWidget {
  @override
  _CreatePageState createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  GlobalKey ttDetectedKey = GlobalKey();
  GlobalKey ttCustomKey = GlobalKey();
  GlobalKey formKey = GlobalKey();

  double top = 0.0;
  double left = 0.0;

  var width;
  var height;

  ///0: detected
  ///1: custom
  int selected = 0;

  @override
  void initState() {
    super.initState();
    width = window.physicalSize.width;
    height = window.physicalSize.height;
    WidgetsBinding.instance.addPersistentFrameCallback((timeStamp) {
      setState(() {
        top = ttDetectedKey.currentContext.size.height / 2;
        left = ttDetectedKey.currentContext.size.width / 2;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  Spacer(),
                  _buildDetected(),
                  _buildCustom(),
                  _buildStart(),
                ],
              ),
            )
          ],
        ),
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
                //点击auto时隐藏软键盘
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
                          autofocus: false,
                          style: TextStyle(fontSize: 32),
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(),
                            ),
                          ),
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
                          autofocus: false,
                          style: TextStyle(fontSize: 32),
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )),
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

  _buildStart() {
    return InkWell(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => EditRouteHome(),
      )),
      child: Hero(
        tag: 'herotag',
        child: Container(
          margin: EdgeInsets.only(left: left, bottom: 10, right: 20),
          padding: EdgeInsets.all(20),
          color: Colors.black,
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
    );
  }
}

// class CusPageRoute extends PageRouteBuilder {
//   Widget child;

//   CusPageRoute({this.child})
//       : super(
//             pageBuilder: (_, a1, a2) => child,
//             transitionDuration: Duration(seconds: 1),
//             transitionsBuilder: (_, a1, a2, w) => );
// }
