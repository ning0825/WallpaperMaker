import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'edit_page.dart';
import 'inherited_config.dart';

void main() => runApp(ResolutionApp());

class ResolutionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ConfigWidget(
      child: MaterialApp(
        home: ResolutionPage(),
      ),
    );
  }
}

class ResolutionPage extends StatefulWidget {
  @override
  _ResolutionPageState createState() => _ResolutionPageState();
}

class _ResolutionPageState extends State<ResolutionPage> {
  //传到EditPage最后保存图片使用的分辨率
  double width;
  double height;

  int selectedResolution = 0;

  ConfigWidgetState data;

  @override
  void initState() {
    super.initState();
    _getDeviceDisplaySize();
  }

  _getDeviceDisplaySize() {
    width = window.physicalSize.width;
    height = window.physicalSize.height;
  }

  @override
  Widget build(BuildContext context) {
    data = ConfigWidget.of(context);
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitle(),
                    _buildAutoDetectedOpt(),
                    _buildCustomizeOpt(),
                  ],
                ),
              ),
            ),
            _buildNextButton(context),
          ],
        ),
      ),
    );
  }

  _buildTitle() {
    return Padding(
      padding: EdgeInsets.only(left: 21, top: 83),
      child: Text(
        'Resolution',
        style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
      ),
    );
  }

  _buildAutoDetectedOpt() {
    return InkWell(
      onTap: () {
        setState(() {
          selectedResolution = 0;
        });
        //点击auto时隐藏软键盘
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
        margin: EdgeInsets.only(top: 50),
        color: selectedResolution == 0 ? Color(0xFFFFF792) : Colors.white,
        height: 160,
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Auto detected',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Text('${width.round()}', style: TextStyle(fontSize: 32)),
                  SizedBox(width: 26),
                  Text('x'),
                  SizedBox(width: 26),
                  Text('${height.round()}', style: TextStyle(fontSize: 32))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  GlobalKey formKey = GlobalKey();

  _buildCustomizeOpt() {
    return InkWell(
      onTap: () {
        setState(() {
          selectedResolution = 1;
        });
      },
      child: Container(
        margin: EdgeInsets.only(top: 5),
        color: selectedResolution == 1 ? Color(0xFFFFF792) : Colors.white,
        height: 163,
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Customize',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
              Form(
                key: formKey,
                child: Row(
                  children: [
                    Container(
                      width: 80,
                      child: TextFormField(
                        onTap: () {
                          setState(() {
                            selectedResolution = 1;
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
                            selectedResolution = 1;
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
            ],
          ),
        ),
      ),
    );
  }

  _buildNextButton(BuildContext context) {
    return InkWell(
        child: Container(
          color: Color(0xFF669AFF),
          alignment: Alignment.center,
          child: Text(
            'Next',
            style: TextStyle(fontSize: 30),
          ),
          height: 66,
        ),
        onTap: () {
          (formKey.currentState as FormState).save();
          data.size2Save = Size(width, height);
          FocusScope.of(context).requestFocus(FocusNode());

          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => EditPage()),
          );
        });
  }
}
